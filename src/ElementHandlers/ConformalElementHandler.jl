using MLJ
using DataFrames
using ConformalPrediction
using Plots

mutable struct ConformalElementHandler <: AbstractElementHandler
    paramHandler::AbstractParamHandler
    name::String
    function ConformalElementHandler()
        elementHandler = new()

        # Load available conformal prediction methods
        regression_methods = keys(merge(values(ConformalPrediction.available_models[:regression])...))
        classification_methods = keys(merge(values(ConformalPrediction.available_models[:classification])...))
        all_methods = unique(vcat(collect(regression_methods), collect(classification_methods)))
        method_options = vcat("None", string.(all_methods))

        # Add a Model Parameter called :model
        paramHandler = addModelParamHandler(:model, "Model")

        # Add a training Dataset and a Testing Dataset
        paramHandler = addDatasetParamHandler!(
            paramHandler, :trainDataset, "Training Dataset"
        )

        # Add plot customization parameters
        paramHandler = addCustomParamHandler!(paramHandler, "Plot Parameters")
        addFieldParam!(paramHandler, :zoom, "zoom", 0)
        addFieldParam!(paramHandler, :x_axis, "x-axis", "x-axis")
        addFieldParam!(paramHandler, :y_axis, "y-axis", "y-axis")
        addFieldParam!(
            paramHandler, :graph_title, "Title", "Regression Prediction with Uncertainty"
        )

        # Add conformal prediction method parameter as a dropdown
        addSelectorParam!(
            paramHandler,
            :conformalmethod,
            "Conformal Prediction Method",
            "None",
            method_options
        )

        # Build the paramHandler
        paramHandler = buildParamHandler!(paramHandler)

        elementHandler.name = "Conformal Element"
        elementHandler.paramHandler = paramHandler

        return elementHandler
    end
end

"""
    generate!(elementHandler :: ConformalElementHandler, params :: Dict, boardIdentifier :: String)

Generates a new element corresponding to the selected element handler. 
"""
function generate!(
    elementHandler::ConformalElementHandler, params::Dict, boardIdentifier::String
)
    model = params[:model]
    df = params[:trainDataset]
    X = reshape(df[:, 1], :, 1)
    y = df[:, 2]

    train, test = partition(eachindex(y), 0.4, 0.4; shuffle=true)

    method = params[:conformalmethod] == "None" ? nothing : Symbol(params[:conformalmethod])

    conf_model = conformal_model(model; method=method)
    mach = machine(conf_model, X, y)

    ConformalPrediction.fit!(mach; rows=train, verbosity=0)

    show_first = 5
    Xtest = selectrows(X, test)
    ytest = y[test]
    ŷ = ConformalPrediction.predict(mach, Xtest)

    zoom = parse(Float64, params[:zoom])
    plt = plot(
        mach.model,
        mach.fitresult,
        Xtest,
        ytest;
        lw=5,
        zoom=zoom,
        observed_lab="Test points",
        titlefontsize=14,
        title=params[:graph_title],
        xlabel=params[:x_axis],
        ylabel=params[:y_axis],
        xlabelfontsize=12,
        ylabelfontsize=12,
    )

    return Plots.png(plt, string("./public/img/", boardIdentifier))
end

"""
    render(elementHandler :: ConformalElementHandler, element)

Renders the body of the element as HTTP.
"""
function render(elementHandler::ConformalElementHandler, element)
    return Genie.Renderer.Html.div() do
        [img(; src=string("/public/img/", element.id), draggable="false")]
    end
end