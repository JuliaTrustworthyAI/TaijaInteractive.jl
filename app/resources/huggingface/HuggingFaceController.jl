module HuggingFaceController

using Transformers
using Transformers.TextEncoders

import HuggingFaceApi as HF
using BSON: load

"""
    loginHuggingface(token::String) :: Bool

Login to HuggingFace using the provided token.

# Arguments
- `token::String`: The token to be used for authentication.

# Returns
`Bool`: `true` if the login is successful, `false` otherwise.
"""
function loginHuggingface(token::String)::Bool
    HF.save_token(token)

    return isLoggedInHuggingface()
end

"""
    isLoggedInHuggingface() :: Bool

Check whether the user is logged in to Hugging Face.

# Returns
`true` if the user is logged in to Hugging Face.
`false` otherwise.
"""
function isLoggedInHuggingface()::Bool
    try
        print(HF.whoami())
        return true
    catch e
        return false
    end
end

"""
    getHuggingfaceToken()

This function returns the Huggingface token.

# Returns
`token::String`: The Huggingface token.
"""
function getHuggingfaceToken()
    return HF.get_token()
end

"""
    downloadTransformerModel(modelId::String) :: Tuple{Any, Any}

Download a transformer model from HuggingFace.

# Arguments
- `modelId::String`: The ID of the model to download.

# Returns
A tuple containing the downloaded model and tokenizer.
"""
function downloadTransformerModel(modelId::String)::Tuple{Any,Any}
    # Load model and tokenizer from HuggingFace
    return Transformers.HuggingFace.load_model(modelId), Transformers.HuggingFace.load_tokenizer(modelId)
end

"""
    downloadBSONModel(modelId::String)

Download a BSON model from the HuggingFace repository.

# Arguments
- `modelId::String`: The ID of the model in the HuggingFace repository.

# Returns
- `model`: Instance of the downloaded BSON model.

"""
function downloadBSONModel(modelId::String)
    # Load list of files from model's repository from HuggingFace and find file ending with ".bson"
    bson_file = findfirst(endswith(".bson"), HF.list_repo_files(modelId))

    if isnothing(bson_file)
        throw(ErrorException("BSON file not found"))
    end

    # Extract values from the Dict and download BSON model
    return collect(values(load(HF.hf_hub_download(modelId, HF.list_repo_files(modelId)[bson_file]))))[end]
end

"""
    downloadModel(huggingFaceModelId::String, library::String) :: Dict{String, Any}

Download a model from Hugging Face based on the given model ID and library.

# Arguments
- `huggingFaceModelId::String`: The ID of the Hugging Face model to download.
- `library::String`: The library to use for downloading the model. Valid options are "transformers" and any other library.

# Returns
A dictionary containing the downloaded model and tokenizer (if `library` is "transformers"), or just the downloaded model (if `library` is any other library).

"""
function downloadModel(huggingFaceModelId::String, library::String)::Dict{String,Any}
    if library == "transformers"
        model, tokenizer = downloadTransformerModel(huggingFaceModelId)
        return Dict("model" => model, "tokenizer" => tokenizer)
    else
        model = downloadBSONModel(huggingFaceModelId)
        return Dict("model" => model)
    end
end

export isLoggedInHuggingface
export loginHuggingface

end
