"""
    getAllElements()

Get all dashboard elements.

# Returns
- An array of all `DashboardElement` objects.
"""
function getAllElements()
    return all(DashboardElements.DashboardElement)
end

"""
    get(dashboardId::Int) :: Union{Vector{Dashboard}, Nothing}

Retrieve a dashboardElement by its ID.

# Arguments
- `dashboardId::Int`: The ID of the dataset to retrieve.

# Returns
- `Union{Vector{Dashboard}, Nothing}`: The dataset with the specified ID, or `nothing` if no dataset is found.

"""
function get(myId)#::Union{Vector{Dashboard},Nothing}
    dashboardelement = find(
        DashboardElements.DashboardElement, SQLWhereExpression("id == ?", myId)
    )
    return isnothing(dashboardelement) || isempty(dashboardelement) ? nothing : dashboardelement[end]
end

"""
    create(title, type, id)

Create a new dashboard element.

Arguments
- `title`: The title of the element.
- `type`: The type of the element.
- `id`: The ID of the dashboard.

Returns
- The newly created `DashboardElement` object.
"""
function create(title, type, posX, posY, dashboardId)
    newElement = DashboardElements.DashboardElement(;
        title=title,
        type=type,
        posX=posX,
        posY=posY,
        lastUpdateTime=format(now(), "yyyy-mm-dd HH:MM:SS"),
        dashboardId=string(dashboardId),
    )
    return save!(newElement)
end

"""
    getElementsByDashboardId(dashboardId)

Get all dashboard elements by dashboard ID.

Arguments:
- `dashboardId`: The ID of the dashboard.

Returns:
- An array of `DashboardElement` objects that belong to the specified dashboard ID.
"""
function getElementsByDashboardId(dashboardId)::Vector{DashboardElements.DashboardElement}
    return find(DashboardElements.DashboardElement; dashboardId=dashboardId)
end

"""
    update(my_id, title, type, dashboardId)

Update a dashboard element.

Arguments:
- `my_id`: The ID of the element to update.
- `title`: The new title of the element.
- `type`: The new type of the element.
- `dashboardId`: The new dashboard ID of the element.

Returns:
- The updated `DashboardElement` object.
"""
function update(my_id, title, type, posX, posY, dashboardId)
    element = DashboardElements.DashboardElement(
        my_id, title, type, posX, posY, format(now(), "yyyy-mm-dd HH:MM:SS"), dashboardId
    )
    return save!(element)
end

"""
    remove(my_id)

Remove a dashboard element.

Arguments:
- `my_id`: The ID of the element to remove.

Returns:
- The deleted `DashboardElement` object.
"""
function remove(my_id)
    element = find(DashboardElements.DashboardElement; id=my_id)[end]
    return delete(element)
end
