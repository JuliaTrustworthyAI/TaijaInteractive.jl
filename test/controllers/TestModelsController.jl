using TaijaInteractive
using Test
using SimpleMock
using CounterfactualExplanations
using TaijaInteractive.DashboardElementsController.DashboardElements
using TaijaInteractive.ModelsController.Models
using TaijaInteractive.ModelsController
using SearchLight
using Genie.Requests
using BSON
using TaijaData
import Dates: DateTime, now, format

@testset "ModelsController" begin
    @testset "crud_operations" begin
        mock(
            SearchLight.save! => Mock((model::Model) -> model),
            find => Mock(
                (type::Type{Model}; id::DbId) -> [
                    Model(;
                        id,
                        type="Linear",
                        format="bson",
                        name="mocked model",
                        description="blah blah",
                    ),
                ],
            ),
            delete => Mock((model::Model) -> model),
        ) do save, mock_find, mock_delete

            model = TaijaInteractive.ModelsController.create(
                "bson", "Linear", "mocked model", "blah blah"
            )
            @testset "create" begin

                @test model.type == "Linear"
                @test model.format == "bson"
                @test model.name == "mocked model"
                @test model.description == "blah blah"

                model2 = Model("linear", "bson", "m2", "bla bla bla")

                @test model2.type == "linear"
                @test model2.format == "bson"
                @test model2.name == "m2"
                @test model2.description == "bla bla bla"

            end

            @testset "update" begin
                edited = TaijaInteractive.ModelsController.update(
                    model.id, "binary_multi", "the better classifier"
                )

                @test edited.type == "binary_multi"
                @test edited.name == "the better classifier"
            end

            @testset "remove" begin

                # Mocking find and delete functions

                removed = TaijaInteractive.ModelsController.remove(DbId(model.id))

                @test removed.type == model.type
                @test removed.name == model.name

            end
        end

        mock(SearchLight.all => Mock(
            (type::Type{Model}) -> [
                Model(;
                    id=DbId("1"),
                    type="Linear",
                    format="bson",
                    name="mocked model",
                    description="blah blah",
                ),
            ],
        )) do mock_all
            @testset "getAllModel" begin

                allModels = TaijaInteractive.ModelsController.getAllModels()

                @test length(allModels) == 1
                element = allModels[1]
                @test element.id == DbId("1")
                

            end
        end
    end


    @testset "models" begin
        @testset "registerModel" begin
            #filespayload(:ModelFile) = (;name="example.bson", data="fake data")
    
            mock(SearchLight.save! => Mock((model::Model) -> model)) do mock_save
                dummy_data = IOBuffer()
                write(dummy_data, "This is some dummy model data for testing.")
                seekstart(dummy_data)
                dummyOutput = IOBuffer()
                registerModelFromFile("testModel", dummy_data; path=dummyOutput)
    
                #@test read(dummyOutput, String) == "This is some dummy model data for testing."
                @test called_once(mock_save)
            end
            
        end
    
        @testset "retrieveModel" begin 
                
            @testset "dataset_instance is nothing" begin
                mock_get = SimpleMock.Mock((id::Int) -> nothing)
    
                SimpleMock.mock(
                    TaijaInteractive.ModelsController.getById => mock_get,
                ) do mockGet
    
                    @test_throws ErrorException TaijaInteractive.ModelsController.retrieveModel(1)
                end
            end
    
            @testset "no file present" begin
                mock_get = SimpleMock.Mock((id::Int) -> TaijaInteractive.ModelsController.Model(;
                    id=DbId(1), name="My Dataset", format="format 1", size="10",description="bla bla", type="Linear",
                ))
                mock_isfile = SimpleMock.Mock((path::String) -> false)
    
                SimpleMock.mock(
                    TaijaInteractive.ModelsController.getById => mock_get,
                    isfile => mock_isfile,
                ) do mockGet, mockIsfile
    
                    @test_throws UndefVarError TaijaInteractive.ModelsController.retrieveModel(1)
                end
            end

            

            @testset "registerModel" begin

            end

    
            """
            @testset "success and retrieveDataset!" begin 
    
                mock_get = SimpleMock.Mock((id::Int) -> Model(;
                id=DbId(1), name="My Dataset", format="format 1", size="10",description="bla bla", type="Linear",
                ))
                mock_isfile = SimpleMock.Mock((path::String) -> true)
                mock_read = SimpleMock.Mock((path, type) -> template_df)
    
                SimpleMock.mock(
                    TaijaInteractive.ModelsController.getById => mock_get,
                    isfile => mock_isfile,
                    BSON.load => mock_read,
                ) do mockGet, mockIsfile
                    SimpleMock.mock(BSON.load => mock_read) do mockRead
                        @test template_df == TaijaInteractive.ModelsController.retrieveModel(1)
                    end
                end 
            end
            """
    
            
        end
    end
end

@testset "loadPretrainedModel Tests" begin
    model = loadPretrainedModel("cifar_mlp")
    @test model isa CounterfactualExplanations.Models.Model

    model = loadPretrainedModel("cifar_ensemble")
    @test model isa CounterfactualExplanations.Models.Model

    model = loadPretrainedModel("cifar_vae")
    @test model isa CounterfactualExplanations.GenerativeModels.VAE

    model = loadPretrainedModel("fashion_ensemble")
    @test model isa CounterfactualExplanations.Models.Model

    model = loadPretrainedModel("mnist_mlp")
    @test model isa CounterfactualExplanations.Models.Model

    model = loadPretrainedModel("fashion_mnist_vae")
    @test model isa CounterfactualExplanations.GenerativeModels.VAE

    @testset "invalid model name" begin
        @test_logs (:error, "no model found for string: invalid_model_name") loadPretrainedModel(
            "invalid_model_name"
        )
    end

    
end

