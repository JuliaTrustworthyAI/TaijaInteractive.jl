using Flux
using DataFrames
using LaplaceRedux
using Plots
using TaijaPlotting
using Flux.OneHotArrays: onecold, onehotbatch

mutable struct LaplaceElementHandler <: AbstractElementHandler
    paramHandler::AbstractParamHandler
    name::String
    function LaplaceElementHandler()
        elementHandler = new()

        # Add a Model Parameter called :myModel
        paramHandler = addModelParamHandler(:myModel, "Model")

        # Add a Dataset  Parameter called :myDataset
        paramHandler = addDatasetParamHandler!(paramHandler, :myDataset, "Dataset")

        # Add Laplace specific parameters
        paramHandler = addCustomParamHandler!(paramHandler, "Laplace Redux Parameters")
        addSelectorParam!(
            paramHandler,
            :likelihood,
            "Likelihood",
            "regression",
            ["regression", "classification"],
        )

        # Add plot customization parameters
        paramHandler = addCustomParamHandler!(paramHandler, "Plot Parameters")
        addFieldParam!(paramHandler, :x_axis, "x-axis", "x-axis")
        addFieldParam!(paramHandler, :y_axis, "y-axis", "y-axis")
        addFieldParam!(paramHandler, :graph_title, "Title", "Laplace Redux Path")

        # Build the paramHandler
        paramHandler = buildParamHandler!(paramHandler)

        elementHandler.name = "Laplace Redux Element"
    
        elementHandler.paramHandler = paramHandler
        
        return elementHandler
    end
end

"""
    generate!(elementHandler :: LaplaceElementHandler, params :: Dict, boardIdentifier :: String)

Generates a new element corresponding to the selected element handler. 
"""
function generate!(
    elementHandler::LaplaceElementHandler, params::Dict, boardIdentifier::String
)
    nn = params[:myModel]
    data = params[:myDataset]

    X = reshape(data[:, end], :, 1)
    y = data[:, 2]
    likelihood = params[:likelihood]

    if (likelihood == "regression")
        nn = Chain(Dense(1 => 1))
        la = Laplace(nn; likelihood=:regression)

        datapoints = map(x -> [y for y in x], Tuple.(eachrow(data[:, 1])))

        # classifications = data[:,end]

        chosen = data[1, end]

        classifications = map(x -> if (x[1] == chosen)
            1
        else
            0
        end, collect(eachrow(data[:, end])))

        LaplaceRedux.fit!(la, zip(datapoints, classifications))

        optimize_prior!(la)

        Xs = reshape(vcat(reshape(datapoints, 1, :)...), 1, :)
        ys = classifications

        plt = plot(la, Xs, ys; zoom=-5, size=(500, 500))
        Plots.png(plt, string("./public/img/", boardIdentifier))

    else

        #Since this is the classification option, we dont have one "chosen" value and 
        #instead map the current values (which might be strings) to numbers with onehotbatch

        original = nn

        nn = Chain(Upsample(; scale=(2,)), original)

        la = Laplace(nn; likelihood=:classification)

        datapoints = map(x -> [y for y in x], Tuple.(eachrow(data[:, 1:2])))
        # classifications = data[:,end]
        chosen = data[1, end]

        labels = unique(data[:, end])
        classifications = onehotbatch(
            [findfirst(label -> x == label, labels) for x in data[:, end]], 1:3
        )

        LaplaceRedux.fit!(la, zip(datapoints, classifications))

        optimize_prior!(la; n_steps=100)

        Xs = hcat(datapoints...)
        ys = onecold(classifications)

        println(Xs)
        println(ys)

        # Plot the posterior predictive distribution:
        zoom = 0
        plt = plot(la, Xs, ys; title="Plot")

        Plots.png(plt, string("./public/img/", boardIdentifier))
    end
end

"""
    render(elementHandler :: LaplaceElementHandler, element)

Renders the body of the element as HTTP.
"""

function render(elementHandler::LaplaceElementHandler, element)
    return Genie.Renderer.Html.div() do
        [img(; src=string("/public/img/", element.id), draggable="false")]
    end
end
