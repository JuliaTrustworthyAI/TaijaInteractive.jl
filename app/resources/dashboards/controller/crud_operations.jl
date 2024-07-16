"""
    getAllBoards()

Get all the dashboards.

# Returns
`Array{Dashboards.Dashboard}`: An array of all the dashboards.
"""
function getAllBoards()
    return all(Dashboards.Dashboard)
end

"""
    create()

Create a new dashboard.

# Returns
`Dashboards.Dashboard`: The newly created dashboard.
"""
function create()
    newboard = Dashboards.Dashboard(;
        title="My Board",
        creationTime=format(now(), "yyyy-mm-dd HH:MM:SS"),
        lastAccessTime=format(now(), "yyyy-mm-dd HH:MM:SS"),
        modelKeys="",
        datasetKeys="",
    )
    return save!(newboard)
end

"""
    update(
        my_id,
        title="",
        creationTime=format(now(), "yyyy-mm-dd HH:MM:SS"),
        lastAccessTime=format(now(), "yyyy-mm-dd HH:MM:SS"),
        modelKeys="",
        datasetKeys="",
    )

Update an existing dashboard.

# Arguments
- `my_id`: The ID of the dashboard to update.
- `title`: (optional) The new title for the dashboard.
- `creationTime`: (optional) The new creation time for the dashboard.
- `lastAccessTime`: (optional) The new last access time for the dashboard.
- `modelKeys`: (optional) The new model keys for the dashboard.
- `datasetKeys`: (optional) The new dataset keys for the dashboard.

# Returns
`Dashboards.Dashboard`: The updated dashboard.
"""
function update(
    my_id,
    title="",
    creationTime=format(now(), "yyyy-mm-dd HH:MM:SS"),
    lastAccessTime=format(now(), "yyyy-mm-dd HH:MM:SS"),
    modelKeys="",
    datasetKeys="",
)
    board = Dashboards.Dashboard(
        my_id, title, creationTime, lastAccessTime, modelKeys, datasetKeys
    )
    return save!(board)
end

"""
    remove(my_id)

Remove a dashboard and all its elements.

# Arguments
- `my_id`: The ID of the dashboard to remove.

# Returns
`Dashboards.Dashboard`: The removed dashboard.
"""
function remove(my_id)
    board = find(Dashboards.Dashboard; id=my_id)[end]
    elements = DashboardElementsController.getElementsByDashboardId(my_id)
    for element in elements
        DashboardElementsController.remove(element.id)
    end
    return delete(board)
end

"""
    getById(my_id)

Get a dashboard by its ID.

# Arguments
- `my_id`: The ID of the dashboard to get.

# Returns
`Dashboards.Dashboard`: The dashboard with the specified ID.
"""
function getById(my_id)
    return find(Dashboards.Dashboard; id=my_id)[end]
end

"""
    updateTitle(my_id::Int64, title::String)

Update an existing dashboard.

# Arguments
- `my_id`: The ID of the dashboard to update.
- `title`: The new title for the dashboard.

# Returns
`Dashboards.Dashboard`: The updated dashboard.
"""
function updateTitle(my_id, title::String)
    board = find(Dashboards.Dashboard; id=my_id)[end]
    board.title = title
    board.lastAccessTime = format(now(), "yyyy-mm-dd HH:MM:SS")
    return save!(board)
end
