# Declare an Empty AbstractParamHandler.
mutable struct EmptyParamHandler <: AbstractParamHandler
    root::AbstractParamHandler            # the first ParamHandler in the chain
    # next :: AbstractParamHandler          # the EmptyParamHandler always concludes the chain

    EmptyParamHandler() = begin
        paramHandler = new()
        paramHandler.root = paramHandler

        return paramHandler
    end
    EmptyParamHandler(root) = begin
        return new(root)
    end
end

"""
    isEnd(paramHandler :: EmptyParamHandler) :: Bool

Determines whether the current handler is at the end of the chain.
"""
function isEnd(paramHandler::EmptyParamHandler)::Bool
    return true
end

"""
    getParam(paramHandler :: EmptyParamHandler, name :: Symbol)

Returns the default value of the provided parameter.
"""
function getParam(paramHandler::EmptyParamHandler, name::Symbol)
    throw(ArgumentError(string("Paramater name ", name, " cannot be found.")))
end

"""
    buildParamHandler()

Builds an empty chain of parameter handlers.
"""
function buildParamHandler()
    return EmptyParamHandler()
end

"""
    buildParamHandler!(paramHandler :: AbstractParamHandler)

Builds a chain of parameter handlers. This function should 
always be called last when constructing the chain of parameter handlers.
"""
function buildParamHandler!(paramHandler::AbstractParamHandler)
    paramHandler.next = EmptyParamHandler(paramHandler.root)
    paramHandler = paramHandler.root
    return paramHandler.root
end

"""
    readPostParams(paramHandler :: EmptyParamHandler) :: Dict

Reads the content of an HTTP POST request to retrieve parameter values as a dictionary.
"""
function readPostParams(paramHandler::EmptyParamHandler)::Dict
    # This function is especially important. Every ParamHandler chain terminates with an empty ParamHandler, which,
    # on calling readPostParams, will get a new instance of a Dict from this function.
    return Dict()
end

"""
    getModelParams(paramHandler :: EmptyParamHandler) :: Set{Symbol}

Retrieve all parameters that require a model as value.
"""
function getModelParams(paramHandler::EmptyParamHandler)::Set{Symbol}
    return Set()
end

"""
    getDatasetParams(paramHandler :: EmptyParamHandler) :: Set{Symbol}

Retrieve all parameters that require a dataset as value.
"""
function getDatasetParams(paramHandler::EmptyParamHandler)::Set{Symbol}
    return Set()
end

"""
    render(paramHandler :: EmptyParamHandler)

Renders the HTML of the menu item corresponding to the current parameter handler.
"""
function render(paramHandler::EmptyParamHandler)
    # This function is especially important. Every ParamHandler chain terminates with an empty ParamHandler, which,
    # on calling render, will get a new instance of an empty vector from this function.
    return [
        Genie.Renderer.Html.button(; class="inner-vertical-menu-submit") do
            "Generate New Element"
        end,
    ]
end
