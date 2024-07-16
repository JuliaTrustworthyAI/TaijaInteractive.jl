# Route to render and html for training Counterfactuals models
route("/model/train"; method=GET) do
    html(Genie.Renderer.filepath("public/views/model_training_view.jl.html"))
end

# Route to train a Counterfactuals model
route("/model/train/counterfactuals"; method=POST) do
    # Extract the model type and dataset file from the request payload
    try
        modelType = payload(:modelType)

        datasetPayload = payload(:FILES)["dataset"]
        file = generateCounterfactualData(CSV.read(IOBuffer(String(datasetPayload.data)), DataFrame))
        filename = datasetPayload.name

        # Train the Counterfactuals model
        fittedModel = trainCounterfactualModel(file, modelType, payload(:modelName), payload(:modelDescription))

        return (201, "Model trained successfully")
    catch e
        return (500, e)
    end
    
end
