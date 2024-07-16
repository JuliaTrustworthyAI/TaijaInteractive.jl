module ElementHandlers

using ..ParamHandlers
using Genie.Renderer.Html

# Declare an Abstract Type for ParamHandler
abstract type AbstractElementHandler end

# Note that every Abstract Element Must have the following functions implemented
# via multiple dispatch:
#   1. generate!(x :: ConcreteElementHandler <: AbstractElementHandler, y :: DashboardElement)
#   2. render(x :: ConcreteElementHandler <: AbstractElementHandler, y :: DashboardElement)

include("ConformalElementHandler.jl")
include("LaplaceElementHandler.jl")
include("CounterfactualElement.jl")


elementHandlerCatalogue = Dict(
    :ConformalPrediction => ConformalElementHandler(),
    :LaplaceRedux => LaplaceElementHandler(),
    :CounterfactualExplanations => CounterfactualElementHandler()
)

"""
    readPayloadForElement(handler :: AbstractElementHandler)

Reads the payload according to the parameter handler that is defined by the element handler.
"""
function readPayloadForElement(handler::AbstractElementHandler)
    return ParamHandlers.readPostParams(handler.paramHandler)
end

"""
    getModelParams(handler :: AbstractElementHandler) :: Set{Symbol}

Retrieves all parameter names that require a model as a value.
"""
function getModelParams(handler::AbstractElementHandler)::Set{Symbol}
    return ParamHandlers.getModelParams(handler.paramHandler)
end

"""
    getDatasetParams(handler :: AbstractElementHandler) :: Set{Symbol}

Retrieves all parameter names that require a dataset as a value.
"""
function getDatasetParams(handler::AbstractElementHandler)::Set{Symbol}
    return ParamHandlers.getDatasetParams(handler.paramHandler)
end

"""
    renderOuter(handler :: AbstractElementHandler,element)

Renders the HTTP corresponding to the current element handler and element instance.
"""
function renderOuter(handler::AbstractElementHandler, element)
    return [
        Genie.Renderer.Html.div(; id="draggable", class="draggable", data_id=element.id ,
        style=" position:absolute; left: $(element.posX)px; top: $(element.posY)px;") do
            
            [
                Genie.Renderer.Html.div(; class="element-header") do
                    [
                        Genie.Renderer.Html.div(;
                            class="element-button-delete",
                            onclick="deleteElement($(element.id))",
                        ) do
                            [""]
                        end,
                        Genie.Renderer.Html.div(; class="element-title") do
                            [element.title]
                        end,
                        Genie.Renderer.Html.a(;
                            href="/public/img/" * string(element.id),
                            download="plot" * string(element.id) * ".png",
                            class="download-button",
                        ) do
                            [""]
                        end,
                    ]
                end,
                render(handler, element),
            ]
        end,
    ]
end

export AbstractElementHandler
export ConformalElementHandler
export LaplaceElementHandler
export elementHandlerCatalogue

export readPayloadForElement
export generate!
export renderOuter
export getModelParams
export getDatasetParams

end
