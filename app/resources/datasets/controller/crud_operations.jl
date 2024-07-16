"""
    getAllSets()

Get all sets from the dataset.

# Returns
`Array{Dataset}`: An array of all sets in the dataset.
"""
function getAllSets()
    return all(Datasets.Dataset)
end

"""
    getAllSetsForId(my_id)

Get all sets from the dataset for a specific ID.

# Arguments
- `my_id`: The ID to filter the sets.

# Returns
`Array{Dataset}`: An array of sets that match the given ID.
"""
function getAllSetsForId(my_id)
    return find(Datasets.Dataset, SQLWhereExpression("poolId == ? ", my_id))
end

"""
    get(datasetId::Int) :: Union{Vector{Dataset}, Nothing}

Retrieve a dataset by its ID.

# Arguments
- `datasetId::Int`: The ID of the dataset to retrieve.

# Returns
`Union{Vector{Dataset}, Nothing}`: The dataset with the specified ID, or `nothing` if no dataset is found.
"""
function get(datasetId)
    dataset = find(Datasets.Dataset, SQLWhereExpression("id == ?", DbId(datasetId)))
    if dataset === nothing || isempty(dataset)
        return nothing
    else
        return dataset[end]
    end
end

"""
    create(dataset)

Save the a dataset wrapper in the database.

# Arguments
- `dataset`: The dataset wrapper to save.

# Returns
The dataset_wrapper for the saved dataset file

"""
function create(dataset)
    return save!(dataset)
end

"""
    create(
    fileType::String,
    filename::String,
    source::String,
    size::String,
    poolId::String
    )

Create and save a new dataset wrapper with the specified attributes.

# Arguments
- `fileType::String`: The file type of the dataset, currently only CSV is supported.
- `fileName::String`: The name of the dataset file.
- `source::String`: The filepath to the dataset file.
- `size::String`: The number of lines inside the dataset.
- `poolId::String`: The identifier of the pool to which the dataset belongs.

# Returns
The dataset wrapper with the specified attributes.
"""
function create(
    fileType::String, filename::String, source::String, size::String, poolId::String
)
    dataset = Datasets.Dataset(;
        name=filename,
        source=source,
        format=fileType,
        size=size,
        lastChanged=format(now(), "yyyy-mm-dd HH:MM:SS"),
        poolId=poolId,
    )
    return create(dataset)
end

"""
    update(
        my_id,
        name="MySet",
        source="",
        format="",
        size="0",
        lastChanged=format(now(), "yyyy-mm-dd HH:MM:SS"),
        poolId="",
    )

Update a dataset with the given parameters.

# Arguments
- `my_id`: The ID of the dataset to update.
- `name`: The name of the dataset (default: "MySet").
- `source`: The source of the dataset (default: "").
- `format`: The format of the dataset (default: "").
- `size`: The size of the dataset (default: 0).
- `lastChanged`: The last changed timestamp of the dataset (default: current timestamp).
- `poolId`: The pool ID of the dataset (default: "").

# Returns
The updated dataset.
"""
function update(
    my_id,
    name="MySet",
    source="",
    format="",
    size="0",
    lastChanged=format(now(), "yyyy-mm-dd HH:MM:SS"),
    poolId="",
)
    newset = Dataset(my_id, name, source, format, size, lastChanged, poolId)
    return save!(newset)
end

"""
    remove(my_id)

Remove a dataset with the given ID.

# Arguments
- `my_id`: The ID of the dataset to remove.

# Returns
The removed dataset.
"""
function remove(my_id)
    set = find(Datasets.Dataset; id=my_id)[end]

    return delete(set)
end
