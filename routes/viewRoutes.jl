include("model_view/modelRoutes.jl")
include("dashboard_view/dashboardRoutes.jl")
include("pool_view/poolRoutes.jl")

route("/models") do
    models = ModelsController.getAllModels()

    html(Genie.Renderer.filepath("public/views/models.jl.html"); models=models)
end
