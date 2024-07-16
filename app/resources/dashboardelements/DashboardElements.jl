module DashboardElements

import SearchLight: AbstractModel, DbId
import Base: @kwdef
import Dates: DateTime, now

export DashboardElement

@kwdef mutable struct DashboardElement <: AbstractModel
    id::DbId = DbId()
    title::String = ""
    type::String = ""
    posX::Float64 = 0.0
    posY::Float64 = 0.0
    lastUpdateTime::String = ""
    dashboardId::String = ""

    """
        DashboardElement(
        title::String,
        type::String,
        posX::Float64,
        posY::Float64,
        lastUpdateTime::String,
        dashboardId::String,
        )

    Constructs a new `DashboardElement` object with the given parameters.

    # Arguments
    - `title::String`: The title of the dashboard element.
    - `type::String`: The type of the dashboard element.
    - `lastUpdateTime::String`: The last update time of the dashboard element.
    - `dashboardId::String`: The ID of the dashboard.

    # Returns
    A new `DashboardElement` object.
    """
    function DashboardElement(
        title::String,
        type::String,
        posX::Float64,
        posY::Float64,
        lastUpdateTime::String,
        dashboardId::String,
    )
        out = new()
        out.title = title
        out.type = type
        out.posX = posX
        out.posY = posY
        out.lastUpdateTime = lastUpdateTime
        out.dashboardId = dashboardId
        return out
    end

    """
        DashboardElement(id::DbId, title::String, type::String, lastUpdateTime::String, dashboardId::String)

    Constructs a new `DashboardElement` object with the given parameters.

    # Arguments
    - `id::DbId`: The ID of the dashboard element.
    - `title::String`: The title of the dashboard element.
    - `type::String`: The type of the dashboard element.
    - `lastUpdateTime::String`: The last update time of the dashboard element.
    - `dashboardId::String`: The ID of the dashboard.

    # Returns
    A new `DashboardElement` object.
    """
    function DashboardElement(
        id::DbId,
        title::String,
        type::String,
        posX::Float64,
        posY::Float64,
        lastUpdateTime::String,
        dashboardId::String,
    )
        out = new()
        out.id = id
        out.title = title
        out.type = type
        out.posX = posX
        out.posY = posY
        out.lastUpdateTime = lastUpdateTime
        out.dashboardId = dashboardId
        return out
    end
end

end
