# Route for loging in to Huggingface.
route("/huggingface/login"; method=POST) do
    result = loginHuggingface(payload(:JSON_PAYLOAD)["api_key"])

    if result
        return (200, "Success")
    else
        return (401, "Unauthorized")
    end
end

# Route for checking if the user is logged in to Huggingface.
route("/huggingface/is_logged_in"; method=GET) do
    result = isLoggedInHuggingface()

    if result
        return (200, "Success")
    else
        return (401, "Unauthorized")
    end
end

route("/huggingface/model"; method="GET") do
    print(payload(:JSON_PAYLOAD)["model_name"])
end

route("/huggingface/model/download"; method=POST, named=:huggingface_model_download) do
    try
        model_dict = HuggingFaceController.downloadModel(
            payload(:JSON_PAYLOAD)["huggingFaceModelId"], payload(:JSON_PAYLOAD)["library"]
        )
        ModelsController.registerModel(
            model_dict,
            payload(:JSON_PAYLOAD)["library"],
            payload(:JSON_PAYLOAD)["huggingFaceModelId"],
        )
    catch e
        return (500, e)
    end

    return (200, "Success")
end
