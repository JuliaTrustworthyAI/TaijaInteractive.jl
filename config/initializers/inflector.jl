using Inflector: Inflector
using Genie: Genie

if !isempty(Genie.config.inflector_irregulars)
    push!(Inflector.IRREGULAR_NOUNS, Genie.config.inflector_irregulars...)
end
