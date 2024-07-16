
route("/pool/:id::Int") do
    id = payload(:id)
    datasets = DatasetsController.getAllSetsForId(id)
    models = ModelsController.getAllModels()
    dashboard = DashboardsController.getById(id)
    renderedElements = DashboardElementsController.renderElementsByDashboardId(id) 
    renderedMenu = ParamHandlers.renderMenu(id, :ConformalPrediction, elementHandlerCatalogue[:ConformalPrediction].paramHandler)
    renderedLaplace = ParamHandlers.renderMenu(id, :LaplaceRedux, elementHandlerCatalogue[:LaplaceRedux].paramHandler)
    renderedCounterfactual = ParamHandlers.renderMenu(id, :CounterfactualExplanations, elementHandlerCatalogue[:CounterfactualExplanations].paramHandler)
    menu = elementHandlerCatalogue
    #println("rendered elements: " * string(renderedElements))
    #concatenated_elements = join(renderedElements, "\n")
    html(Genie.Renderer.filepath("public/views/dashboard_view.jl.html"); 
    id=id, 
    datasets=datasets, 
    models=models,
    elements=renderedElements, 
    dashboard=dashboard,
    renderedMenu=renderedMenu,
    renderedLaplace = renderedLaplace,
    renderedCounterfactual = renderedCounterfactual,
    menu=menu)
end

route(
    "/pool/addModel"; method=POST
) do
    filename = split(filespayload(:ModelFile).name, ".")[1]
    data = IOBuffer(filespayload(:ModelFile).data)
    TaijaInteractive.ModelsController.registerModelFromFile(filename, data)
end

route("pool/addconv") do
    CSV.write("public/files/conv.csv", first(TaijaData.load_linearly_separable()))
end

route(
    "/pool/generateCounterfactual/:nameOfGen::String/:idOfModel::Int/:idOfDataset::Int/:dashBoardId::Int/:factual::String/:target::String",
) do
    nameOfGen = payload(:nameOfGen)
    idOfModel = payload(:idOfModel)
    idOfDataset = payload(:idOfDataset)
    dashBoardId = payload(:dashBoardId)
    factual = payload(:factual)
    target = payload(:target)

    dashboardElement = DashboardElementsController.create(
        "Counterfactual plot", "CE", 0.0, 0.0, dashBoardId
    )

    model = CounterfactualExplanations.Models.Model(
        ModelsController.retrieveModel(idOfModel),
        CounterfactualExplanations.Models.all_models_catalogue[Symbol(
            ModelsController.getById(idOfModel).type
        )]();
        likelihood=:classification_multi,
    )
    dataset = DatasetsController.retrieveDataset(idOfDataset)

    

    DashboardElementsController.registerPlot(counterFactual, dashboardElement)
end

route(
    "/pool/:id::Int/create_dataset",
    TaijaInteractive.DatasetsController.registerDatasetFromFile;
    method=POST,
    named=:create_dataset,
)

route("pool/:dashboardId::Int/createDatasetInfo/:datasetId::Int") do
    pos_start::Float64 = 0.0

    dataset_wrapperElement = DashboardElementsController.create(
        string(payload(:datasetId)),
        "dataset",
        pos_start,
        pos_start,
        string(payload(:dashboardId)),
    )
end

route("pool/:dashboardId::Int/createModelInfo/:modelId::Int") do
    pos_start::Float64 = 0.0
    model_wrapperElement = DashboardElementsController.create(
        string(payload(:modelId)),
        "model",
        pos_start,
        pos_start,
        string(payload(:dashboardId)),
    )
end

route("/public/img/:id") do
    serve_static_file("img/" * payload(:id) * ".png")
end

route("/dashboard/:id::Int/generateElement"; method=POST) do
    DashboardElementsController.generateElement()
end

route("/database/datasets") do
    JSON.json(DatasetsController.getAllSets())
end

route("/database/models") do
    JSON.json(ModelsController.getAllModels())
end
