
include("../../../../src/ElementHandlers/LaplaceElementHandler.jl")

"""
    renderDataset(element)
Renders a div for the corresponding dataset element, displaying the name, source, and size of the datset.

# Arguments
- `element`: DashboardElement which is going to be rendered

# Returns
`String`: The HTMLString representation of the dataset element.
"""
function renderDataset(element)
    k::Int = parse(Int, element.title)

    dataset = DatasetsController.get(k)

    return [
        Genie.Renderer.Html.div(; class="counterfactual") do
            [
                Genie.Renderer.Html.h6() do
                    ["Dataset Name: " * dataset.name]
                end,
                Genie.Renderer.Html.h6() do
                    ["Dataset Source: " * dataset.source]
                end,
                Genie.Renderer.Html.h6() do
                    ["Dataset Size: " * dataset.size]
                end,
            ]
        end,
    ]
end

"""
    renderModel(element)
Renders a div for the corresponding model element, displaying the name, type, and description of the model.

# Arguments
- `element`: ModelElement which is going to be rendered

# Returns
`String`: The HTMLString representation of the model element.
"""
function renderModel(element)
    k::Int = parse(Int, element.title)

    model = ModelsController.getById(k)

    return [
        Genie.Renderer.Html.div(; class="counterfactual") do
            [
                Genie.Renderer.Html.h6() do
                    ["Model Name: " * model.name]
                end,
                Genie.Renderer.Html.h6() do
                    ["Model Type: " * model.type]
                end,
                Genie.Renderer.Html.h6() do
                    ["Model Description: " * model.description]
                end,
            ]
        end,
    ]
end

# Stores the render function corresponding to the given element type
render_element_catalogue = Dict(
    "dataset" => renderDataset, "model" => renderModel, "test" => () -> ""
)

"""
    renderElement(element)

Converts the given element to the corresponding HTML. This function acts as a parent function for all of the
specialized render functions for the individual elements.

# Arguments
- `element`: an element instance

# Returns
The HTML corresponding to the element instance.
"""
function renderElement(element)
    return [
        Genie.Renderer.Html.div(;
            class="draggable",
            data_id=element.id,
            style=" position:absolute; left: $(element.posX)px; top: $(element.posY)px;",
        ) do
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
                            [element.type * " " * element.title]
                        end,
                    ]
                end,
                render_element_catalogue[element.type](element),
            ]
        end,
    ]
end

"""
    renderElementsByDashboardId(dashboardId)
    
This function generates the HTML of every element in the current board.

# Arguments
- `dashboardId`: id of the dashboard whose elements are going to be rendered

# Returns
`String`: The HTMLString representation of the corresponding elements.
"""
function renderElementsByDashboardId(dashboardId)
    renderedElements = []
    elements = getElementsByDashboardId(dashboardId)
    for e in elements
        if (e.type in keys(render_element_catalogue))
            push!(renderedElements, renderElement(e))
        else
            handler = elementHandlerCatalogue[Symbol(e.type)]
            push!(renderedElements, ElementHandlers.renderOuter(handler, e))
        end
    end
    return renderedElements
end

"""
    generateElement()

This function is called to generate a new element according to the payload content of the HTTP POST request
delievered to the end-point. This function handles parameter reading and retrieval, as well as element generation.
"""
function generateElement()

    ### Preparation Stage: Retrieve Parameters

    # Retrieve the Element Type
    handlerType = Symbol(postpayload(Symbol(ParamHandlers.hiddenElementType)))
    handler = elementHandlerCatalogue[handlerType]

    # Read the post Parameters
    params = ElementHandlers.readPayloadForElement(handler)

    # Replace model and dataset parameters with the actual model and dataset
    for modelParam in ElementHandlers.getModelParams(handler)
        ModelsController.retrieveModel!(params, modelParam)
    end

    for datasetParam in ElementHandlers.getDatasetParams(handler)
        # Datasets are always retrieved as dataframes
        DatasetsController.retrieveDataset!(params, datasetParam)
    end

    ### Database Stage: Create a new record in the database
    element = create(handler.name, string(handlerType), 0.0, 0.0, payload(:id))

    ### Generation Stage: 
    return ElementHandlers.generate!(handler, params, string(element.id))
end
