module Datasets

import SearchLight: AbstractModel, DbId, save!
import Base: @kwdef
import Dates: DateTime, now

export Dataset

@kwdef mutable struct Dataset <: AbstractModel
    id::DbId = DbId()
    name::String = ""
    source::String = ""
    format::String = ""
    size::String = ""
    lastChanged::String = ""
    poolId::String = ""

    """
        Dataset(name::String, source::String, format::String, size::Int, lastChanged::String, poolId::String)

    Constructor for creating a Dataset object.

    # Arguments
    - `name::String`: The name of the dataset.
    - `source::String`: The source of the dataset.
    - `format::String`: The format of the dataset.
    - `size::Int`: The size of the dataset.
    - `lastChanged::String`: The date when the dataset was last changed.
    - `poolId::String`: The pool ID of the dataset.

    # Returns
    A new `Dataset` object.
    """
    function Dataset(
        name::String,
        source::String,
        format::String,
        size::String,
        lastChanged::String,
        poolId::String,
    )
        out = new()
        out.name = name
        out.source = source
        out.format = format
        out.size = size
        out.lastChanged = lastChanged
        out.poolId = poolId
        return out
    end

    """
        Dataset(id::DbId, name::String, source::String, format::String, size::Int, lastChanged::String, poolId::String)

    Constructor for creating a Dataset object with an ID.

    # Arguments
    - `id::DbId`: The ID of the dataset.
    - `name::String`: The name of the dataset.
    - `source::String`: The source of the dataset.
    - `format::String`: The format of the dataset.
    - `size::Int`: The size of the dataset.
    - `lastChanged::String`: The date when the dataset was last changed.
    - `poolId::String`: The pool ID of the dataset.

    # Returns
    A new `Dataset` object with an ID.
    """
    function Dataset(
        id::DbId,
        name::String,
        source::String,
        format::String,
        size::String,
        lastChanged::String,
        poolId::String,
    )
        out = new()
        out.id = id
        out.name = name
        out.source = source
        out.format = format
        out.size = size
        out.lastChanged = lastChanged
        out.poolId = poolId
        return out
    end
end
end
