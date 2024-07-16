using Test
using SimpleMock
using TaijaInteractive.HuggingFaceController
using Transformers
using Transformers.HuggingFace
using HuggingFaceApi
using BSON


@testset "HuggingFaceController" begin
    hfc = TaijaInteractive.HuggingFaceController
    
    @testset "Authentication" begin

        @testset "loginHuggingface" begin
            # Mocking HuggingFace API functions
            mock_save_token = Mock((token::String) -> nothing)
            mock_whoami = Mock(() -> "user123")

            mock((HuggingFaceApi.save_token) => mock_save_token) do saveTokenMock
                mock((HuggingFaceApi.whoami) => mock_whoami) do whoamiMock
                    result = hfc.loginHuggingface("fake_token")
                    @test result == true
                end
            end
        end

        @testset "isLoggedInHuggingface" begin
            @testset "When logged in" begin
                mock_whoami = Mock(() -> "user123")
                mock((HuggingFaceApi.whoami) => mock_whoami) do whoamiMock
                    result = hfc.isLoggedInHuggingface()
                    @test result == true
                end
            end

            @testset "When not logged in" begin
                mock_whoami = Mock(() -> throw(ArgumentError("Not logged in")))
                mock((HuggingFaceApi.whoami) => mock_whoami) do whoamiMock
                    result = hfc.isLoggedInHuggingface()
                    @test result == false
                end
            end
        end

        @testset "getHuggingfaceToken" begin
            mock_get_token = Mock(() -> "fake_token")
            mock((HuggingFaceApi.get_token) => mock_get_token) do getTokenMock
                result = hfc.getHuggingfaceToken()
                @test result == "fake_token"
            end
        end
    end

    @testset "Model Download" begin

        """
        @testset "downloadTransformerModel" begin
            
            mock_load_model = Mock((modelId::String) -> "mock_model")
            mock_load_tokenizer = Mock((modelId::String) -> "mock_tokenizer")
            
            mock((Transformers.HuggingFace.load_model) => mock_load_model) do loadModelMock
                mock((Transformers.HuggingFace.load_tokenizer) => mock_load_tokenizer) do loadTokenizerMock
                    model, tokenizer = hfc.downloadTransformerModel("fake_model_id")
                    @test model == "mock_model"
                    @test tokenizer == "mock_tokenizer"
                end
            end
            
        end 
        """
        
        
        
        @testset "downloadBSONModel" begin        

            """
            @testset "When BSON file is found" begin
                mock_list_repo_files = SimpleMock.Mock((modelId::String) -> ["file1.txt", "model.bson"])
                mock_hf_hub_download = SimpleMock.Mock((modelId::String, file::String) -> "mock_bson_data")
                mock_load = SimpleMock.Mock((data) -> Dict("model" => "mock_bson_model"))
    
                mock((HuggingFaceApi.list_repo_files) => mock_list_repo_files) do listRepoFilesMock
                    mock((HuggingFaceApi.hf_hub_download) => mock_hf_hub_download) do hfHubDownloadMock
                        mock((BSON.load) => mock_load) do loadMock
                            result = hfc.downloadBSONModel("fake_model_id")
                            @test result == "mock_bson_model"
                        end
                    end
                end
            end 
            """
            
    
            @testset "When BSON file is not found" begin
                mock_list_repo_files = Mock((modelId::String) -> ["file1.txt", "file2.txt"])
                mock((HuggingFaceApi.list_repo_files) => mock_list_repo_files) do listRepoFilesMock
                    @test_throws ErrorException hfc.downloadBSONModel("fake_model_id")
                end
            end
    
            @testset "When BSON download fails" begin
                mock_list_repo_files = Mock((modelId::String) -> ["model.bson"])
                mock_hf_hub_download = Mock((modelId::String, file::String) -> throw(ErrorException("Failed to download BSON")))
    
                mock((HuggingFaceApi.list_repo_files) => mock_list_repo_files) do listRepoFilesMock
                    mock((HuggingFaceApi.hf_hub_download) => mock_hf_hub_download) do hfHubDownloadMock
                        @test_throws ErrorException hfc.downloadBSONModel("fake_model_id")
                    end
                end
            end

        end
    
        @testset "downloadModel" begin


            @testset "Using transformers library" begin
                mock_download_transformer_model = Mock((modelId::String) -> ("mock_model", "mock_tokenizer"))
                mock((hfc.downloadTransformerModel) => mock_download_transformer_model) do downloadTransformerModelMock
                    result = hfc.downloadModel("fake_model_id", "transformers")
                    @test result == Dict("model" => "mock_model", "tokenizer" => "mock_tokenizer")
                end
            end
    
            @testset "Using BSON library" begin
                mock_download_bson_model = Mock((modelId::String) -> "mock_bson_model")
                mock((hfc.downloadBSONModel) => mock_download_bson_model) do downloadBsonModelMock
                    result = hfc.downloadModel("fake_model_id", "bson")
                    @test result == Dict("model" => "mock_bson_model")
                end
            end
        end
    end
end
