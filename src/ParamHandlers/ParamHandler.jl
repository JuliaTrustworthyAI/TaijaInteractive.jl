module ParamHandlers

# Declare an Abstract Type for ParamHandler
abstract type AbstractParamHandler end

using Genie.Renderer.Html
using Genie.Requests

include("./EmptyParamHandler.jl")
include("./CustomParamHandler.jl")
include("./SpecialParamHandler.jl")

const hiddenElementType = "hidden-element-type"

"""
    isStart(paramHandler :: AbstractParamHandler) :: Bool

Determines whether the current handler is at the start of the chain.
"""
function isStart(paramHandler::AbstractParamHandler)::Bool
    return paramHandler == paramHandler.root
end

"""
    isEnd(paramHandler :: AbstractParamHandler) :: Bool

Determines whether the current handler is at the end of the chain.
"""
function isEnd(paramHandler::AbstractParamHandler)::Bool
    return isa(paramHandler.next, EmptyParamHandler)
end

"""
    getModelParams(paramHandler :: AbstractParamHandler) :: Set{Symbol}

Retrieve all parameters that require a model as value.

# Arguments
- `paramHandler` : the current ParamHandler

# Returns
The set of parameters that require a model
"""
function getModelParams(paramHandler::AbstractParamHandler)::Set{Symbol}
    return getModelParams(paramHandler.next)
end

"""
    getDatasetParams(paramHandler :: AbstractParamHandler) :: Set{Symbol}

Retrieve all parameters that require a dataset as value.

# Arguments
- `paramHandler` : the current ParamHandler

# Returns
The set of parameters that require a dataset
"""
function getDatasetParams(paramHandler::AbstractParamHandler)::Set{Symbol}
    return getDatasetParams(paramHandler.next)
end

"""
    renderMenu(dashboardId :: Int, handlerIdentifier :: Symbol, root :: AbstractParamHandler)

Renders the menu items for the entire chain of parameter handlers, and wraps it with
an HTML form element.

# Arguments
- `dashboardId` : the ID of the dashboard
- `handlerIdentifier` : the identifier of the handler
- `root` : the root of the chain

# Returns
The rendered menu as an HTML string
"""
function renderMenu(dashboardId::Int, handlerIdentifier::Symbol, root::AbstractParamHandler)
    formIdentifier = string("element-handler-form-", handlerIdentifier)
    generateEndpointPath = string("/dashboard/", dashboardId, "/generateElement")

    Genie.Renderer.Html.form(;
        id=formIdentifier,
        style="display: none",
        enctype="multipart/form-data",
        method="POST",
        action=generateEndpointPath,
        class="right-element-form",
    ) do
        renderedMenu = render(root)

        elementTypeHidden = Genie.Renderer.Html.input(;
            name=hiddenElementType, type="hidden", value=string(handlerIdentifier)
        )

        pushfirst!(renderedMenu, elementTypeHidden)

        return renderedMenu
    end
end

export AbstractParamHandler
export SpecialParamHandler
export CustomParamHandler
export EmptyParamHandler

export hiddenElementType

export renderMenu
export getParam
export addModelParamHandler
export addDatasetParamHandler
export addModelParamHandler!
export addDatasetParamHandler!
export readPostParams
export render
export addCustomParamHandler
export addCustomParamHandler!
export addSelectorParam!
export addFieldParam!
export addCheckboxParam!
export buildParamHandler
export buildParamHandler!
export getModelParams
export getDatasetParams

end
