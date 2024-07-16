using Aqua

function test_aqua()

    # Ambiguities needs to be tested seperately until the bug in Aqua package (https://github.com/JuliaTesting/Aqua.jl/issues/77) is fixed
    Aqua.test_ambiguities([TaijaInteractive]; recursive=false, broken=false)

    return Aqua.test_all(TaijaInteractive; ambiguities=false)
end
