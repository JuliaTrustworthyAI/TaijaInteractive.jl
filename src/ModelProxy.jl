using Dates

struct ModelProxy
    id::Int
    name::String
    type::String
    parameters::Array{String,1}
    lastChangedTime::Dates.DateTime
    fromHuggingFace::Bool
    key::String
end
