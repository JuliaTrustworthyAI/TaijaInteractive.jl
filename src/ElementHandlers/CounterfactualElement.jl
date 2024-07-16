using MLJ
using DataFrames
using CounterfactualExplanations
using TaijaPlotting
using Plots


mutable struct CounterfactualElementHandler <: AbstractElementHandler
    paramHandler :: AbstractParamHandler
    name :: String
    CounterfactualElementHandler() = begin 
        elementHandler = new()

        # Define the parameters for the Counterfactual Explanations element handler
        
        # Add a Model Parameter called :model
        paramHandler = addModelParamHandler(:model, "Model")

        # Add a training Dataset and a Testing Dataset
        paramHandler = addDatasetParamHandler!(paramHandler, :dataset, "Structured Dataset")

        # Add General Parameters
        paramHandler = addCustomParamHandler!(paramHandler, "Counterfactual Parameters")
        addFieldParam!(paramHandler, :num_counterfactuals, "Number of Paths", 1)
        addSelectorParam!(paramHandler, :factual, "Factual Class", "", [])
        addSelectorParam!(paramHandler, :target, "Target Class", "", [])

        # Add Generator Parameters
        paramHandler = addCustomParamHandler!(paramHandler, "Generator Parameters")
        addSelectorParam!(paramHandler, :generator, "Generator", "ClaPROAR Generator", collect(keys(stylized_generator_names)))

        # Add Convergence Parameters
        paramHandler = addCustomParamHandler!(paramHandler, "Convergence Parameters")
        addSelectorParam!(paramHandler, :convergence, "Convergence", "Maximum Iterations", collect(keys(stylized_convergence_names)))
        # addFieldParam!(paramHandler, :max_itr, "Maximum Iterations", 100)
        
        # Add plot customization parameters
        paramHandler = addCustomParamHandler!(paramHandler, "Plot Parameters")
        addFieldParam!(paramHandler, :zoom, "zoom", 0)
        addFieldParam!(paramHandler, :x_axis, "x-axis", "x-axis")
        addFieldParam!(paramHandler, :y_axis, "y-axis", "y-axis")
        addFieldParam!(paramHandler, :graph_title, "Title", "Counterfactual Path")
        
        # Build the paramHandler
        paramHandler = buildParamHandler!(paramHandler)
        
        # Initialize the handler's
        elementHandler.name = "Counterfactual Element"
        elementHandler.paramHandler = paramHandler

        return elementHandler
    end
end


"""
    generate!(elementHandler :: CounterfactualElementHandler, params :: Dict, boardIdentifier :: String)

enerates a new element corresponding to the selected element handler. 
"""
function generate!(
    elementHandler :: CounterfactualElementHandler,
    params :: Dict,
    boardIdentifier :: String,
    )

    # The body of the function has been moved to a separate function to ensure testability;
    # Plots png cannot be mocked properly by the SimpleMock package, and so, to ensure that the
    # more important section of the function remains tested, it has been separated from the rest.
    plt = generateCounterfactuals(params)

    Plots.png(plt, string("./public/img/", boardIdentifier))
end


"""
    render(elementHandler :: CounterfactualElementHandler, element)

Renders the body of the element as HTTP.
"""
function render(
    elementHandler :: CounterfactualElementHandler,
    element
    )
    return Genie.Renderer.Html.div(; name=element.title, class="counterFactualElement") do
        [img(; src="/public/img/" * string(element.id), id="elementImg", draggable="false")]
    end
end


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Utility
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Generators can be accessed via the Generator Catalogue provided
# by the CounterfactualExplanations package.

stylized_generator_names = Dict(
    "ClaPROAR Generator" => :claproar,
    "Feature Tweak Generator" => :feature_tweak,
    "Gravitational Generator" => :gravitational,
    "Greedy Generator" => :greedy,
    "Growing Spheres Generator" => :growing_spheres,
    "REVISE Generator" => :revise,
    "DiCE Generator" => :dice,
    "Wachter Generator" => :wachter,
    "Probe Generator" => :probe,
    "CLUE Generator" => :clue,
)

stylized_convergence_names = Dict(
    "Decision Threshold" => CounterfactualExplanations.Convergence.GeneratorConditionsConvergence,
    "Generator Conditions" => CounterfactualExplanations.Convergence.GeneratorConditionsConvergence,
    "Maximum Iterations" => CounterfactualExplanations.Convergence.InvalidationRateConvergence,
    "Invalidation Rate" => CounterfactualExplanations.Convergence.MaxIterConvergence,
)

# Each parameter requirement is a 3-tuple of the form ("name", type, [constraint functions])
generator_req_parameters = Dict(
    :claproar => [("lambda", AbstractFloat, [(x) -> x > 0])],
    :feature_tweak => [],
    :gravitational => [],
    :greedy => [],
    :growing_spheres => [],
    :revise => [],
    :dice => [],
    :wachter => [],
    :probe => [],
    :clue => [],
)

"""
    getGenerator(generator :: String) :: AbstractGenerator

Returns an instance of the Counterfactual Generator associated with the given symbol.

# Arguments
- `generator`: The stylized Generator name

# Returns
An instance of the Counterfactual Generator
"""
function getGenerator(generator::Union{String,Symbol})

    # Convert to a symbol if necessary
    isa(generator, String) && (generator = stylized_generator_names[generator])

    return CounterfactualExplanations.Generators.generator_catalogue[generator]
end

function getConvergence(conv::String)

    return stylized_convergence_names[conv]
end


"""
    getAllGenerators()

Returns an array containing the stylized names of all Counterfactual Generators.

# Returns
An array containing String Generator names.
"""
function getAllGenerators()
    return stylized_generator_names
end

"""
    getGeneratorRequirements(generator :: Union{String, Symbol})

For the given generator type, this function returns the array of all parameter requirements. Each parameter requirement is defined
as a 3-tuple, where the first component is the (String) parameter name, the second component is the parameter type, and the third 
component is an array of value constraints. Each value constraint is a single-argument function that should validate the proposed
value for the parameter.

# Arguments
- `generator`: the stylized String name or symbol corresponding to the generator.

# Returns
an array of parameter requirements.
"""
function getGeneratorRequirements(generator::Union{String,Symbol})
    # Convert to a symbol if necessary
    isa(generator, String) && (generator = stylized_generator_names[generator])

    return generator_req_parameters[generator]
end

"""
    generateCounterfactuals(params :: Dict)

Generates a plot that depicts the counterfactual path constructed by the generator.
"""
function generateCounterfactuals(params :: Dict)

    model = params[:model]
    dataset = params[:dataset]

    
    # Process the Dataset and Model
    matrix = DataFrames.select(dataset, Not(names(dataset)[end]))
    labels = dataset[:, end]
    
    mmatrix = transpose(Matrix(matrix))
    vlabels = Vector(labels)
    counterfactualData = CounterfactualData(mmatrix, vlabels)

    classification = (length(unique(vlabels)) == 2) ? :classification_binary : :classification_multi
    counterfactualModel = CounterfactualExplanations.Models.Model(
        model,
        CounterfactualExplanations.Models.all_models_catalogue[:MLP](),
        likelihood = classification
    )
   
    chosen = rand(findall(predict_label(counterfactualModel, counterfactualData) .== params[:factual]))
    x = select_factual(counterfactualData, chosen)

    # Process the Generator parameters
    generator = getGenerator(params[:generator])()

    # Process the Convergence parameters
    convergence = getConvergence(params[:convergence])()


    counterfactualExplanationsWrapper = CounterfactualExplanations.generate_counterfactual(
        x, params[:target], counterfactualData, counterfactualModel, generator;
        num_counterfactuals = parse(Int64, params[:num_counterfactuals]), convergence = convergence,
    )

    # Construct the graph
    zoom = parse(Float64, params[:zoom])

    plt = Plots.plot(counterfactualExplanationsWrapper; 
        zoom=zoom, titlefontsize=14, title = params[:graph_title],
        xlabel=params[:x_axis], ylabel = params[:y_axis],
        xlabelfontsize=12, ylabelfontsize=12)

    return plt
end