using TaijaInteractive.ElementHandlers
using CounterfactualExplanations
using CounterfactualExplanations.DataPreprocessing
using CounterfactualExplanations.Models
using CounterfactualExplanations.Generators
using Flux
using MLJ
using TaijaData
using DataFrames
using SimpleMock

@testset "CounterfactualElement" begin
    gen = ElementHandlers.getGenerator("Wachter Generator")

    #@test gen isa Type{WachterGenerator}

    gens = keys(ElementHandlers.getAllGenerators())
    @test "ClaPROAR Generator" in gens
    @test "Feature Tweak Generator" in gens
    @test "Gravitational Generator" in gens
    @test "Greedy Generator" in gens
    @test "Growing Spheres Generator" in gens
    @test "REVISE Generator" in gens
    @test "DiCE Generator" in gens
    @test "Wachter Generator" in gens
    @test "Probe Generator" in gens
    @test "CLUE Generator" in gens
    
end


@testset "generate" begin

    linearlySeparable =  TaijaData.load_linearly_separable()
    model = fit_model(DataPreprocessing.CounterfactualData(linearlySeparable...), :Linear).model
    
    dataset = DataFrame(permutedims([linearlySeparable[1]; reshape(map( x -> (x == 2) ? "class 2" : "class 1", linearlySeparable[2]), (1, :))]), :auto)

    params = Dict(
        :model => model,
        :dataset => dataset,
        :num_counterfactuals => "1",
        :factual => "class 2",
        :target => "class 1",
        :convergence => "Decision Threshold",
        :generator => "Gravitational Generator",
        :max_itr => "100",
        :zoom => "0",
        :x_axis => "x-axis",
        :y_axis => "y-axis",
        :graph_title => "My Graph"
    )
            
    ElementHandlers.generateCounterfactuals(params)
    @test true   # Tests whether the generate! runs without any exceptions.
       
end

@testset "getGenerator" begin
    @test ElementHandlers.getGenerator("Wachter Generator")() isa CounterfactualExplanations.AbstractGenerator
    @test ElementHandlers.getGenerator(:wachter)() isa CounterfactualExplanations.AbstractGenerator
    @test_throws KeyError ElementHandlers.getGenerator("Nonexistent Generator")
end

@testset "getAllGenerators" begin
    gens = ElementHandlers.getAllGenerators()
    @test "Wachter Generator" in keys(gens)
    @test gens["Wachter Generator"] == :wachter
end


@testset "getGeneratorRequirements" begin
    reqs = ElementHandlers.getGeneratorRequirements("ClaPROAR Generator")
    @test length(reqs) == 1
    @test reqs[1][1] == "lambda"
    @test reqs[1][2] == AbstractFloat
    @test reqs[1][3][1](1.0) == true
    @test reqs[1][3][1](0.0) == false
end


