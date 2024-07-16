mutable struct SpecialParamHandler <: AbstractParamHandler
    # Note: This parameter handler is specially made to handle the selection of a model 
    # or a dataset. The actual structure is the same, but the behaviour should be different.
    # Therefore, the type field was added to distinguish between a model parameter and 
    # a dataset parameter.

    root::AbstractParamHandler            # the first ParamHandler in the chain
    next::AbstractParamHandler            # the next ParamHandler in the chain

    type::Symbol                          # Should be either a :dataset or a :model

    identifier::Symbol
    name::String
    value::Integer

    function SpecialParamHandler(type::Symbol, identifier::Symbol, name::String)
        paramHandler = new()
        paramHandler.root = paramHandler
        paramHandler.type = type
        paramHandler.identifier = identifier
        paramHandler.name = name
        paramHandler.value = -1
        return paramHandler
    end

    function SpecialParamHandler(
        root::AbstractParamHandler, type::Symbol, identifier::Symbol, name::String
    )
        paramHandler = new()
        paramHandler.root = root
        paramHandler.type = type
        paramHandler.identifier = identifier
        paramHandler.name = name
        paramHandler.value = -1
        return paramHandler
    end
end

"""
    getParam(paramHandler :: SpecialParamHandler, name :: Symbol)

Returns the default value of the provided parameter.
"""
function getParam(paramHandler::SpecialParamHandler, name::Symbol)
    if name == paramHandler.identifier
        return paramHandler.value
    else
        return getParam(paramHandler.next, name)
    end
end

"""
    addModelParamHandler(identifier :: Symbol, name  :: String)

Begins a new chain of parameter handlers. This function creates a special parameter handler for a model parameter.
"""
function addModelParamHandler(identifier::Symbol, name::String)
    return SpecialParamHandler(:model, identifier, name)
end

"""
    addModelParamHandler!(paramHandler :: AbstractParamHandler, identifier :: Symbol, name  :: String)

Appends a special parameter handler for a model parameter.
"""
function addModelParamHandler!(
    paramHandler::AbstractParamHandler, identifier::Symbol, name::String
)
    paramHandler.next = SpecialParamHandler(paramHandler.root, :model, identifier, name)
    return paramHandler.next
end

"""
    addDatasetParamHandler(identifier :: Symbol, name  :: String)

Begins a new chain of parameter handlers. This function creates a special parameter handler for a dataset parameter.
"""
function addDatasetParamHandler(identifier::Symbol, name::String)
    return SpecialParamHandler(:dataset, identifier, name)
end

"""
    addDatasetParamHandler!(paramHandler :: AbstractParamHandler,  identifier :: Symbol, name  :: String)

Appends a special parameter handler for a dataset parameter.
"""
function addDatasetParamHandler!(
    paramHandler::AbstractParamHandler, identifier::Symbol, name::String
)
    paramHandler.next = SpecialParamHandler(paramHandler.root, :dataset, identifier, name)
    return paramHandler.next
end

"""
    readPostParams(paramHandler :: SpecialParamHandler)

Reads the content of an HTTP POST request to retrieve parameter values as a dictionary.
"""
function readPostParams(paramHandler::SpecialParamHandler)
    # Retrieve the Parameters of the POST request from later ParamHandlers in the chain
    readParams = readPostParams(paramHandler.next)

    # Read and insert the value of the dataset/model defined by this special ParamHandler.
    # Note that the read should not raise any errors as the default value is used in case
    # the parameter cannot be found.
    setindex!(
        readParams,
        postpayload(paramHandler.identifier, paramHandler.value),
        paramHandler.identifier,
    )

    return readParams
end

"""
    function getModelParams(paramHandler :: SpecialParamHandler) :: Set{Symbol}

Retrieve all parameters that require a model as value.
"""
function getModelParams(paramHandler::SpecialParamHandler)::Set{Symbol}

    # Retrieve all the remaining models
    paramsFound = getModelParams(paramHandler.next)

    # Add the parameter if it represents a model
    if (paramHandler.type == :model)
        push!(paramsFound, paramHandler.identifier)
    end

    return paramsFound
end

"""
    function getDatasetParams(paramHandler :: SpecialParamHandler) :: Set{Symbol}

Retrieve all parameters that require a dataset as value.
"""
function getDatasetParams(paramHandler::SpecialParamHandler)::Set{Symbol}
    # Retrieve all the remaining models
    paramsFound = getDatasetParams(paramHandler.next)

    # Add the parameter if it represents a model
    if (paramHandler.type == :dataset)
        push!(paramsFound, paramHandler.identifier)
    end

    return paramsFound
end

"""
    render(paramHandler :: SpecialParamHandler)

Renders the HTML of the menu item corresponding to the current parameter handler.
"""
function render(paramHandler::SpecialParamHandler)
    # Retrieve the rendered list from later ParamHandlers in the chain
    renderedMenu = render(paramHandler.next)

    section = Genie.Renderer.Html.div(; class="inner-vertical-menu-item") do
        [
            Genie.Renderer.Html.div(; class="label-input") do
                [
                    Genie.Renderer.Html.div(; class="form-group") do
                        [
                            Genie.Renderer.Html.label(; class="form-label") do
                                paramHandler.name
                            end,
                            Genie.Renderer.Html.select(;
                                class=string(paramHandler.type) * " " * "form-input",
                                name=string(paramHandler.identifier),
                            ),
                        ]
                    end,
                ]
            end,
        ]
    end

    pushfirst!(renderedMenu, section)

    return renderedMenu
end
