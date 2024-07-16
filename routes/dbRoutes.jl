route("/board/get/:id", () -> json(DashboardsController.getById(payload(:id))); method=GET)

route("/element/:id::Int/render") do
    element = DashboardElementsController.create("We did it!", "CE", string(payload(:id)))

    string(ElementsController.renderElement(element))
end

route(
    "/dashboardelements/create",
    DashboardElementsController.create;
    method=POST,
    named=:create_dashboardelement,
)
route(
    "/dashboardelements/:id::Int/update",
    () -> DashboardElementsController.update(payload(:id));
    method=POST,
    named=:update_dashboardelement,
)
route(
    "/dashboardelements/:id::Int/delete",
    () -> DashboardElementsController.remove(payload(:id));
    method=DELETE,
    named=:delete_dashboardelement,
)

route("/dashboardelements/:id::Int/position/:posX::Float64/:posY::Float64") do
    dashboardElement = DashboardElementsController.get(payload(:id))

    DashboardElementsController.update(
        dashboardElement.id,
        dashboardElement.title,
        dashboardElement.type,
        payload(:posX),
        payload(:posY),
        dashboardElement.dashboardId,
    )
end

route(
    "/dashboardelements/:id::Int/position",
    () -> JSON.json(DashboardElementsController.getDashboardElementPositions(payload(:id)));
    method=GET,
    named=:get_dashboardelemnt_position,
)

route(
    "/pool/:id::Int/delete",
    () -> DashboardsController.remove(payload(:id));
    method=DELETE,
    named=:delete_dashboard,
)

route("/board", DatasetsController.create; method=POST)

# Dataset routes
route("/datasets", () -> json(DatasetsController.getAllSets); method=GET)

route("/datasets", () -> json(DatasetsController.getAllSets); method=GET)

route("/labels/:dataset_id::Int") do

    #println(dataset_id)
    dataset_id = payload(:dataset_id)
    println(dataset_id)
    JSON.json(getLabels(dataset_id))
end
