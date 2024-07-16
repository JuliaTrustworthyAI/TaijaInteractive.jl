module Models

import SearchLight: AbstractModel, DbId
import Base: @kwdef

export Model

@kwdef mutable struct Model <: AbstractModel
    id::DbId = DbId()
    type::String = ""
    format::String = ""
    name::String = ""
    description::String = ""

    """
        Model(id::DbId, type::String, format::String, name::String, description::String)

    Constructor for creating a Model object.

    # Arguments
    - `id::DbId`: The identifier of the model.
    - `type::String`: The filetype of the model.
    - `format::String`: The filetype of the model.
    - `name::String`: The name of the model.
    - `description::String`: Additional description of the model.

    # Returns
    A new Model object.
    """
    function Model(
        id::DbId, type::String, format::String, name::String, description::String
    )
        out = new()
        out.id = id
        out.type = type
        out.format = format
        out.name = name
        out.description = description
        return out
    end

    """
        Model(type::String, format::String, name::String, description::String)

    Constructor for creating a Model object.

    # Arguments
    - `type::String`: The filetype of the model.
    - `format::String`: The filetype of the model.
    - `name::String`: The name of the model.
    - `description::String`: Additional description of the model.

    # Returns
    A new Model object.
    """
    function Model(type::String, format::String, name::String, description::String)
        out = new()
        out.type = type
        out.format = format
        out.name = name
        out.description = description
        return out
    end
end
end
