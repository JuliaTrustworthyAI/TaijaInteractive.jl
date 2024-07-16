"""
    registerDatasetFromFile()

Creates and persists a dataset-wrapper corresponding to the dataset file currently in filespayload.
"""
function registerDatasetFromFile()
    if infilespayload(:DatasetFile)
        filename = split(filespayload(:DatasetFile).name, ".")[1]
        filename = string(filename)
        size = countlines(IOBuffer(filespayload(:DatasetFile).data))
        dataset_wrapper = DatasetsController.create(
            "csv", filename, "manually uploaded", string(size), splitpath(currenturl())[3]
        )
        path::String = joinpath(
            "public", "files", string(dataset_wrapper.id) * "." * dataset_wrapper.format
        )

        write(path, IOBuffer(filespayload(:DatasetFile).data))

    else
        "No File was Found!"
    end
end

"""
    createDatasetInfo(dashboardId::Int, datasetId::Int)

Creates and persist a datasetInfoElement corresponding to the dashboard and dataset with the given ids.

# Arguments
- `dashboardId::Int`: The id of the dashboard to which the dataset belongs.
- `datasetId::Int`: The id of the dataset to display information about.


# Returns
The created datasetInformationElement.
"""
function createDatasetInfo(dashboardId::Int, datasetId::Int)
    pos_start::Float64 = 0.0

    return dataset_wrapperElement = DashboardElementsController.create(
        string(datasetId), "dataset", pos_start, pos_start, string(dashboardId)
    )
end

"""
    getLabels(datasetId::Int)

Retrieves the unique labels from the last column of a dataset.

# Arguments
- `datasetId::Int`: The id of the dataset to retrieve labels from.

# Returns
An array of unique labels from the last column of the dataset.
"""
function getLabels(datasetId::Int)
    set = get(datasetId)
    setName = set.name
    path = joinpath("public", "files", string(datasetId) * "." * "csv")
    df = CSV.read(path, DataFrame)
    lastColumn = names(df)[end]
    labels = unique(df[:, lastColumn])
    return labels
end
