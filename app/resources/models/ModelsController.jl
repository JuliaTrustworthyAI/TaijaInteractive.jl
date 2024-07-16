module ModelsController

import CounterfactualExplanations: CounterfactualData
using CounterfactualExplanations.Models

using Genie, Genie.Router, Genie.Renderer, Genie.Renderer.Html, Genie.Requests
import SearchLight: AbstractModel, DbId, save!, all, delete, find
using Flux: Flux
using BSON: BSON, @save, @load, load
using JLD2: JLD2
using JSON
using CounterfactualExplanations
using MLJ
using MLJFlux
using DataFrames
using SymbolicRegression

export loadPretrainedModel
export getAllModels
export registerModelFromFile
export trainCounterfactualModel

export registerModel
export retrieveModel!

include("./Models.jl")
using .Models

include("./controller/crud_operations.jl")
include("./controller/models.jl")

"""
    trainCounterfactualModel(counterfactualData::CounterfactualData, modelType::String)

Trains a model using fit_model from CounterFactualExplanations.

# Arguments
- `counterfactualData::CounterfactualData`: The dataset on which we want to train this model.
- `modelType::String`: The type of the model to train.

# Returns
A dictionary containing true.
"""
function trainCounterfactualModel(counterfactualData::CounterfactualData, modelType::String, modelName::String, modelDescription::String)
    # Check if the model exists
    
    if (haskey(standard_models_catalogue, modelType))
        throw(error("Model $modelType not found."))
    end

    # Train the model
    model = fit_model(counterfactualData, Symbol(modelType)).model

    modelWrapper = ModelsController.create(
        "bson", 
        string(modelType), 
        isempty(modelName) ? string(modelType, " classifier for ", datasetName) : modelName,
        modelDescription
    )
    @save string("public/files/models/", modelWrapper.id, ".bson") model

    return json(Dict("success" => true))
end

end
