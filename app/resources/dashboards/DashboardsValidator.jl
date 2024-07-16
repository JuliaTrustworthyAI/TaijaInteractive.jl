module DashboardsValidator

using SearchLight, SearchLight.Validation

function not_empty(field::Symbol, m::T)::ValidationResult where {T<:AbstractModel}
    isempty(getfield(m, field)) &&
        return ValidationResult(invalid, :not_empty, "should not be empty")

    return ValidationResult(valid)
end

function is_int(field::Symbol, m::T)::ValidationResult where {T<:AbstractModel}
    isa(getfield(m, field), Int) ||
        return ValidationResult(invalid, :is_int, "should be an int")

    return ValidationResult(valid)
end

function is_unique(field::Symbol, m::T)::ValidationResult where {T<:AbstractModel}
    obj = findone(typeof(m); NamedTuple(field => getfield(m, field))...)
    if (obj !== nothing && !ispersisted(m))
        return ValidationResult(invalid, :is_unique, "already exists")
    end

    return ValidationResult(valid)
end

end
