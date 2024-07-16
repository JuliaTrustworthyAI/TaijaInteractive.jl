module DatasetsController

using Genie, Genie.Router, Genie.Renderer.Html, Genie.Requests

using Genie.Router, Genie.Renderer
using CSV
using DataFrames
using Dates
import SearchLight: AbstractModel, DbId, save!, all, delete, find, SQLWhereExpression
import CounterfactualExplanations: CounterfactualData
import Dates: DateTime, now, format

export getAllSets
export generateCounterfactualData
export retrieveDataset!
export getLabels

include("./Datasets.jl")
using .Datasets

include("controller/dataset.jl")
include("controller/crud_operations.jl")

"""
    retrieveDataset(datasetId::Int) :: DataFrame

Retrieve a dataset from the database and return it as a DataFrame.

# Arguments
- `datasetId::Int`: The identifier of the dataset to retrieve.

# Returns
`DataFrame`: The dataset as a DataFrame.

# Errors
- Throws an error if the dataset with the given identifier is not found in the database.
- Throws an error if the dataset file for the given identifier is not found.
"""
function retrieveDataset(datasetId::Int)::DataFrames.DataFrame

    # Retrieve Dataset instance from a Database
    dataset_instance = get(datasetId)

    # Check if dataset is empty
    if dataset_instance === nothing
        throw(error("Dataset with identifier $datasetId not found in the database."))
    end

    # Extract the source file path from the Dataset instance
    identifier = dataset_instance.id

    # Step 2: Find the corresponding file in the `public/files/dataset` directory
    file_path = joinpath("public", "files", string(identifier) * ".csv")

    if !isfile(file_path)
        throw(error("Dataset file for identifier $datasetId not found."))
    end

    # Read the CSV file from the source file path
    dataframe = CSV.read(file_path, DataFrame)

    return dataframe
end

function retrieveDataset!(params::Dict, paramIdentifier::Symbol)
    return params[paramIdentifier] = retrieveDataset(parse(Int, params[paramIdentifier]))
end

"""
    previewDataset(id::Int) :: DataFrame

This function retrieves a dataset with the given ID and returns it as a DataFrame.

# Arguments
- `id::Int`: The ID of the dataset to retrieve.

# Returns
A DataFrame containing the retrieved dataset.
"""
# function previewDataset(id::Int)::DataFrame
#     dataframe = retrieveDataset(id)

# TODO: Implement a preview function to display the ten rows of the dataset

#     return dataframe
# end

"""
    generateCounterfactualData(dataset::DataFrame)::CounterfactualData

This function transforms a DataFrame instance into CounterfactualData by extracting the last column as the labels-vector and the rest as the feature-matrix.

# Arguments
- `dataset::DataFrame`: The DataFrame instance to transform.

# Returns
A CounterFactualData containing the dataset.
"""
function generateCounterfactualData(dataset::DataFrame)::CounterfactualData
    matrix = DataFrames.select(dataset, Not(names(dataset)[end]))
    labels = dataset[:, end]

    mmatrix = transpose(Matrix(matrix))
    vlabels = Vector(labels)

    return CounterfactualData(mmatrix, vlabels)
end

end
