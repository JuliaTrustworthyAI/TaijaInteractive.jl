const MODELS_DIRECTORY = "public/files/models/"

"""
    loadPretrainedModel(name::String) :: AbstractModel

Loads one of the twelwe pretrained models.
Note: Currently load_fashion_mnist_mlp, load_mnist_vae() and load_mnist_ensemble() does not work since its not being exported by CounterfactualExplanations package.

# Arguments
- `name`: the short name of the pretrained model
# Returns
the pretrained model whose name was entered
"""
function loadPretrainedModel(name::String)
    if (name == "cifar_mlp")
        return load_cifar_10_mlp()
    elseif (name == "cifar_ensemble")
        return load_cifar_10_ensemble()
    elseif (name == "cifar_vae")
        return load_cifar_10_vae()
    elseif (name == "fashion_ensemble")
        return load_fashion_mnist_ensemble()
    elseif (name == "mnist_mlp")
        return load_mnist_mlp()
    elseif (name == "fashion_mnist_vae")
        return load_fashion_mnist_vae()
    else
        @error("no model found for string: " * name)
    end
end

"""
    registerModel(model, type :: String)

For a given model, this function registers a model wrapper object in the database, and converts the model into a file that
can be stored in the `public/files/models/` file. Currently, this method only supports BSON for flux models.

# Arguments
- `model`: the ML model that needs to be registered.
- `type`: the file format for saving the model.
"""
function registerModel(model, type::String, name::String)

    #print(model)

    # Create the wrapper object and persist in the database.
    modelWrapper = create("bson", "Linear", name, "bbbb")

    # Note: name of the file is the identifier of the wrapper object.
    filename = MODELS_DIRECTORY * string(modelWrapper.id) * "." * modelWrapper.format

    # Save the model as a BSON file.
    BSON.@save filename model
end

"""
    registerModelFromFile()

Creates and persists a model-wrapper corresponding to the model file currently in filespayload.
"""
function registerModelFromFile(filename, modelData; path=nothing)
    #if infilespayload(:ModelFile)
        #filename = split(filespayload(:ModelFile).name, ".")[1]
        filename = string(filename)
        model_wrapper = ModelsController.create(
            "bson", "Linear", filename, "blah blah blah"
        )
        if isnothing(path)
            path::String = joinpath(
            "public",
            "files",
            "models",
            string(model_wrapper.id) * "." * model_wrapper.format,
        )
        end
        println(path)
        #write(path, IOBuffer(filespayload(:ModelFile).data))
        write(path, modelData)

    #else
    #    "No File was Found!"
    #end
end

"""
    retrieveModel(identifier::Integer)

For a given identifier, this function attempts to load the corresponding model as a usable object. This function first 
retrieves the model wrapper from the database, and then attempts to load the associated model file. Currently, this method only
supports BSON for Flux models.

# Arguments
- `identifier`: the identifier of the Flux model.

# Returns
The corresponding usable model object.
"""
function retrieveModel(identifier::Integer)
    # Retrieve the wrapper object from the database
    model_wrapper = ModelsController.getById(identifier)

    # Note: name of the file is the identifier of the wrapper object.
    filename = MODELS_DIRECTORY * string(model_wrapper.id) * "." * model_wrapper.format

    # Load the model
    model = BSON.load(filename, @__MODULE__)

    model = collect(values(model))[end]

    # Get the model from the dictionary
    if isa(model, Dict)
        model = model["model"]
    end

    # Implant the model in the Counterfactual Explanations Wrapper
    # ce_model = CounterfactualExplanations.Models.Model(
    #     model,
    #     CounterfactualExplanations.Models.all_models_catalogue[Symbol(model_wrapper.type)]();
    #     likelihood=:classification_multi,
    # )

    return model
end

function retrieveModel!(params::Dict, paramIdentifier::Symbol)
    return params[paramIdentifier] = retrieveModel(parse(Int, params[paramIdentifier]))
end
