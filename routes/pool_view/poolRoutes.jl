#Homepage: redirects homepage to the pool view
route("/") do
    redirect(:pool)
end

#Pool: directs to the Board Pool view
route("/pool"; named=:pool) do
    dashboards = DashboardsController.getAllBoards()

    html(Genie.Renderer.filepath("public/views/pool_view.jl.html"); dashboards=dashboards)
end

#Performing CRUD operations on pool
route("/pool/create", DashboardsController.create; method=POST, named=:create_dashboard)

route("/pool/:id::Int/update"; method=POST, named=:update_dashboard) do
    DashboardsController.updateTitle(payload(:id), payload(:JSON_PAYLOAD)["title"])
end
