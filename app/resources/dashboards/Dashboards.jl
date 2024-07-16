module Dashboards

import SearchLight: AbstractModel, DbId, save!
import Base: @kwdef
import Dates: DateTime, now

export Dashboard

@kwdef mutable struct Dashboard <: AbstractModel
    id::DbId = DbId()
    title::String = ""
    creationTime::String = ""
    lastAccessTime::String = ""
    modelKeys::String = ""
    datasetKeys::String = ""

    """
        Dashboard(title::String, creationTime::String, lastAccessTime::String, modelKeys::String, datasetKeys::String)

    Constructs a `Dashboard` object with the specified parameters.

    # Arguments
    - `title::String`: The title of the dashboard.
    - `creationTime::String`: The creation time of the dashboard.
    - `lastAccessTime::String`: The last access time of the dashboard.
    - `modelKeys::String`: The model keys associated with the dashboard.
    - `datasetKeys::String`: The dataset keys associated with the dashboard.

    # Returns
    A `Dashboard` object.
    """
    function Dashboard(
        title::String,
        creationTime::String,
        lastAccessTime::String,
        modelKeys::String,
        datasetKeys::String,
    )
        out = new()
        out.title = title
        out.creationTime = creationTime
        out.lastAccessTime = lastAccessTime
        out.modelKeys = modelKeys
        out.datasetKeys = datasetKeys
        return out
    end

    """
        Dashboard(id::DbId, title::String, creationTime::String, lastAccessTime::String, modelKeys::String, datasetKeys::String)

    Constructs a `Dashboard` object with the specified parameters.

    # Arguments
    - `id::DbId`: The ID of the dashboard.
    - `title::String`: The title of the dashboard.
    - `creationTime::String`: The creation time of the dashboard.
    - `lastAccessTime::String`: The last access time of the dashboard.
    - `modelKeys::String`: The model keys associated with the dashboard.
    - `datasetKeys::String`: The dataset keys associated with the dashboard.

    # Returns
    A `Dashboard` object.
    """
    function Dashboard(
        id::DbId,
        title::String,
        creationTime::String,
        lastAccessTime::String,
        modelKeys::String,
        datasetKeys::String,
    )
        out = new()
        out.id = id
        out.title = title
        out.creationTime = creationTime
        out.lastAccessTime = lastAccessTime
        out.modelKeys = modelKeys
        out.datasetKeys = datasetKeys
        return out
    end
end

end
