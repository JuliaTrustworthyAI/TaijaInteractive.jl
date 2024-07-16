mutable struct CustomParamHandler <: AbstractParamHandler
    root::AbstractParamHandler            # the first ParamHandler in the chain
    next::AbstractParamHandler            # the next ParamHandler in the chain

    title::String
    params::Dict{Symbol,NamedTuple}

    CustomParamHandler(title::String) = begin
        paramHandler = new()
        paramHandler.root = paramHandler
        paramHandler.params = Dict()
        paramHandler.title = title
        return paramHandler
    end

    function CustomParamHandler(title::String, root::AbstractParamHandler)
        paramHandler = new()
        paramHandler.root = root
        paramHandler.params = Dict()
        paramHandler.title = title
        return paramHandler
    end
end

"""
    getParam(paramHandler :: CustomParamHandler, name :: Symbol)

Returns the default value of the provided parameter.
"""
function getParam(paramHandler::CustomParamHandler, name::Symbol)
    if name in keys(paramHandler.params)
        return paramHandler.params[name].value
    else
        return getParam(paramHandler.next, name)
    end
end

"""
    addCustomParamHandler(title :: String)

Begins a new chain of parameter handlers. This function creates a custom parameter handler.
"""
function addCustomParamHandler(title::String)
    return CustomParamHandler(title)
end

"""
    addCustomParamHandler!(paramHandler :: AbstractParamHandler, title :: String)

Appends a custom parameter handler.
"""
function addCustomParamHandler!(paramHandler::AbstractParamHandler, title::String)
    paramHandler.next = CustomParamHandler(title, paramHandler.root)
    return paramHandler.next
end

"""
    addSelectorParam!(paramHandler :: CustomParamHandler, identifier :: Symbol, name :: String, defaultValue :: T, possibleValues :: Vector{T}) where T

Adds a selector parameter to the provided custom parameter handler.
"""
function addSelectorParam!(
    paramHandler::CustomParamHandler,
    identifier::Symbol,
    name::String,
    defaultValue::T,
    possibleValues::Vector{T},
) where {T}
    return setindex!(
        paramHandler.params,
        (name=name, type=:selector, value=defaultValue, options=possibleValues),
        identifier,
    )
end

"""
    function addFieldParam!(paramHandler :: CustomParamHandler, identifier :: Symbol, name :: String, defaultValue :: T) where T

Adds a textfield parameter to the provided custom parameter handler.
"""
function addFieldParam!(
    paramHandler::CustomParamHandler, identifier::Symbol, name::String, defaultValue::T
) where {T}
    return setindex!(
        paramHandler.params, (name=name, type=:field, value=defaultValue), identifier
    )
end

"""
    addCheckboxParam!(paramHandler :: CustomParamHandler, identifier :: Symbol, name :: String = "", defaultValue :: Bool = false)

Adds a checkbox parameter to the provided custom parameter handler.
"""
function addCheckboxParam!(
    paramHandler::CustomParamHandler,
    identifier::Symbol,
    name::String="",
    defaultValue::Bool=false,
)
    return setindex!(
        paramHandler.params, (name=name, type=:checkbox, value=defaultValue), identifier
    )
end

"""
    readPostParams(paramHandler :: CustomParamHandler)

Reads the content of an HTTP POST request to retrieve parameter values as a dictionary.
"""
function readPostParams(paramHandler::CustomParamHandler)
    # Retrieve the Parameters of the POST request from later ParamHandlers in the chain
    readParams = readPostParams(paramHandler.next)

    # Read and insert the value of each parameter defined by this special ParamHandler.
    # Note that the read should not raise any errors as the default value is used in case
    # the parameter cannot be found.
    for (key, info) in paramHandler.params
        setindex!(readParams, postpayload(key, info.value), key)
    end

    return readParams
end

"""
    render(paramHandler :: CustomParamHandler)

Renders the HTML of the menu item corresponding to the current parameter handler.
"""
function render(paramHandler::CustomParamHandler)
    # Retrieve the rendered list from later ParamHandlers in the chain
    renderedMenu = render(paramHandler.next)

    section = Genie.Renderer.Html.div(; class="inner-vertical-menu-item") do
        [
            Genie.Renderer.Html.h3(; class="parameter-type") do
                paramHandler.title
            end,
            Genie.Renderer.Html.div() do
                [renderParameter(k, v) for (k, v) in paramHandler.params]
            end,
        ]
    end

    pushfirst!(renderedMenu, section)
    return renderedMenu
end

"""
    renderParameter(identifier :: Symbol, info :: NamedTuple)

Renders the HTML of each parameter in the custom parameter handler. This function
should not be called outside this module. 
"""
function renderParameter(identifier::Symbol, info::NamedTuple)
    # Render the parameter according to the type
    if (info.type == :selector)
        Genie.Renderer.Html.div(; class="label-input form-group") do
            [
                Genie.Renderer.Html.a(; class="form-label") do
                    info.name
                end,
                Genie.Renderer.Html.select(;
                    class="form-input", name=string(identifier)
                ) do
                    [
                        Genie.Renderer.Html.option(; value=opt) do
                            String(opt)
                        end for opt in info.options
                    ]
                end,
            ]
        end

    elseif (info.type == :field)
        Genie.Renderer.Html.div(; class="label-input form-group") do
            [
                Genie.Renderer.Html.a(; class="form-label") do
                    info.name
                end,
                Genie.Renderer.Html.input(;
                    class="form-input",
                    name=string(identifier),
                    type="text",
                    autocomplete="off",
                    value=info.value,
                ),
            ]
        end

    elseif (info.type == :checkbox)
        Genie.Renderer.Html.div(; class="label-input form-group") do
            [
                Genie.Renderer.Html.a(; class="form-label") do
                    info.name
                end,
                Genie.Renderer.Html.input(;
                    class="form-input",
                    name=string(identifier),
                    type="checkbox",
                    value="accepted",
                    autocomplete="off",
                ),
            ]
        end

    else
        throw(ArgumentError("Parameter Type " * string(info.type) * " is not recognized."))
    end
end
