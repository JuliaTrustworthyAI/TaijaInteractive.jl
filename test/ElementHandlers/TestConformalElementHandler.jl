using Test
using SimpleMock
using TaijaInteractive.ParamHandlers
using TaijaInteractive.ElementHandlers

@testset "Conformal Element" begin
    ph = TaijaInteractive.ParamHandlers
    eh = TaijaInteractive.ElementHandlers

    elementHandler = eh.elementHandlerCatalogue[:ConformalPrediction]

    @testset "utility" begin
        modelParams = eh.getModelParams(elementHandler)
        @test length(modelParams) == 1

        datasetParams = eh.getDatasetParams(elementHandler)
        @test length(datasetParams) == 1
    end

    # @testset "generate" begin

    #     using SymbolicRegression
    #     using ConformalPrediction
    #     using DataFrames

    #     regressor = SymbolicRegression.SRRegressor
    #     model = regressor(
    #         niterations=5,
    #         binary_operators=[+, -, *],
    #     )

    #     df = DataFrame(hcat([2, 3, 4, 5, 6, 7], [-5, -6, -7, -8, -9, -10]), :auto)

    #     params = Dict(:model => model, :trainDataset => df, :zoom => 0.0, :xmax => 0.0, :x_axis => "x-axis", :y_axis => "y-axis", :graph_title => "Title")

    #     using Plots
    #     mock((Plots.png) => Mock((plt, str) -> nothing,), (ConformalPrediction.fit!) => Mock(())) do png
    #         eh.generate!(elementHandler, params, "3")   
    #     end

    #     @test true
    # end

    @testset "render" begin
        renderedElement = string(eh.renderOuter(elementHandler, (id=3, title="temp",posX=0.0,posY=0.0)))

        @test occursin("src=\"/public/img/3\"", renderedElement)
    end
end
