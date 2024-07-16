"""
    getAllElements()

This function returns all of the model objects that are stored in the database.

# Returns
A collection of all model objects.
"""
function getAllModels()
    return all(Models.Model)
end

"""
    getById(identifier)

This function returns the object corresponding to the unique identifier.

# Arguments
- `identifier`: the identifier corresponding to the model instance.

# Returns
The model instance corresponding to the identifier.    
"""
function getById(identifier)
    return find(Models.Model; id=identifier)[end]
end

"""
    create(type, hyperparameters)

This function persists the model instance in the database.
    
# Arguments
- `model`: the model instance to be saved in the database.

# Returns
The saved model instance.
"""
function create(model)
    return save!(model)
end

"""
    create(format::String, type::String, name::String="", description::String="")

This function persists a model instance wit the given parameters in the database.
    
# Arguments
- `format::String`: the file-type of the model.
- `type::String`: the file-type of the model.
- `name::String`: the name of the model.
- `description::String`: additional description of the model.

# Returns
The saved model instance.
"""
function create(format::String, type::String, name::String="", description::String="")
    model = Models.Model(; type=type, format=format, name=name, description=description)
    return create(model)
end

"""
    update(identifier, type :: String, hyperparameters :: String)

This function updates an existing instance in the database with new field values.

# Arguments
- `identifier`: the identifier of the instance to be updated
- `type`: the new type value
"""
function update(identifier, type::String, name::String="")
    model = Models.Model(; id=identifier, type=type, name=name)
    return save!(model)
end

"""
    remove(identifier)

This function removes an existing instance from the database.

# Arguments
- `identifier`: the identifier of the instance to be deleted

# Returns 
the model instance that was deleted.

"""
function remove(identifier)
    model = getById(identifier)
    return delete(model)
end
