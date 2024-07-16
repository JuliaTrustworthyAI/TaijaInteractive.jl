using TaijaInteractive
using Test
using SearchLight
using TaijaInteractive.DatasetsController.Datasets
using SimpleMock
using CSV
using Genie, Genie.Router, Genie.Renderer.Html, Genie.Requests
using DataFrames
import Dates: DateTime, now, format

import SearchLight: AbstractModel, DbId, save!, all, delete, find

@testset "DatasetController" begin
    @testset "crud_operations" begin
        templateDataset = Datasets.Dataset(
            DbId(1), "My Dataset", "source 1", "format 1", "10", format(now(), "yyyy-mm-dd HH:MM:SS"), "1",
        )

        mock_save = SimpleMock.Mock((dataset::Dataset) -> dataset)
        mock_find = SimpleMock.Mock(
            (type::Type{Dataset}; id::DbId) -> [
                Dataset(;
                    id=id,
                    name="My Dataset",
                    source="source 1",
                    format="format 1",
                    size="10",
                    lastChanged=format(now(), "yyyy-mm-dd HH:MM:SS"),
                    poolId="1",
                ),
            ],
        )
        mock_delete = SimpleMock.Mock((dataset::Dataset) -> dataset)


        SimpleMock.mock(
            SearchLight.save! => mock_save,
            find => mock_find,
            delete => mock_delete,
        ) do mockSave, mockFind, mockDelete
            dataset = TaijaInteractive.DatasetsController.create(templateDataset)

            @testset "getAllSets" begin
                
            end

            @testset "getAllSetsForId" begin
                
            end

            """
            @testset "get" begin
                foundDataset = TaijaInteractive.DatasetsController.get(1)

                @test foundDataset.id == DbId(dataset.id)
                @test foundDataset.name == "My Dataset"
                @test foundDataset.source == "source 1"
                @test foundDataset.format == "format 1"
                @test foundDataset.size == "10"
            end
            """

            @testset "create: values" begin
                newDataset = TaijaInteractive.DatasetsController.create(
                    "type", "filename", "source", "size", "poolId"
                )

                @test newDataset.name == "filename"
                @test newDataset.source == "source"
                @test newDataset.format == "type"
                @test newDataset.size == "size"
                @test newDataset.poolId == "poolId"
            end

            @testset "create: instance" begin 
                newDataset = TaijaInteractive.DatasetsController.create(templateDataset)

                @test newDataset.name == dataset.name
                @test newDataset.source == dataset.source
                @test newDataset.format == dataset.format
                @test newDataset.size == dataset.size
                @test newDataset.lastChanged == dataset.lastChanged
                @test newDataset.poolId == dataset.poolId
            end

            @testset "update: values" begin
                dataset = TaijaInteractive.DatasetsController.create(templateDataset)

                editedDataset = TaijaInteractive.DatasetsController.update(
                    DbId(dataset.id),
                    "name",
                    "source",
                    "format",
                    "size",
                    "lastChanged",
                    "poolId",
                )

                @test editedDataset.name == "name"
                @test editedDataset.source == "source"
                @test editedDataset.format == "format"
                @test editedDataset.size == "size"
                @test editedDataset.lastChanged == "lastChanged"
                @test editedDataset.poolId == "poolId"
            end

            # Completed
            @testset "remove" begin 
                dataset = TaijaInteractive.DatasetsController.create(templateDataset)
                removed = TaijaInteractive.DatasetsController.remove(DbId(dataset.id))

                @test removed.name == dataset.name
                @test removed.poolId == dataset.poolId
                @test removed.source == dataset.source
            end
        end
    end

    @testset "Controller" begin

        template_df = DataFrames.DataFrame()
        template_df.x = [1, 2, 3]
        template_df.y = [4, 5, 6]

        @testset "retrieveDataset" begin 
            
            @testset "dataset_instance is nothing" begin
                mock_get = SimpleMock.Mock((id::Int) -> nothing)

                SimpleMock.mock(
                    TaijaInteractive.DatasetsController.get => mock_get,
                ) do mockGet

                    @test_throws ErrorException TaijaInteractive.DatasetsController.retrieveDataset(1)
                end
            end

            @testset "no file present" begin
                mock_get = SimpleMock.Mock((id::Int) -> TaijaInteractive.DatasetsController.Dataset(;
                    id=DbId(1), name="My Dataset", source="source 1", format="format 1", size="10", lastChanged=format(now(), "yyyy-mm-dd HH:MM:SS"), poolId="1",
                ))
                mock_isfile = SimpleMock.Mock((path::String) -> false)

                SimpleMock.mock(
                    TaijaInteractive.DatasetsController.get => mock_get,
                    isfile => mock_isfile,
                ) do mockGet, mockIsfile

                    @test_throws ErrorException TaijaInteractive.DatasetsController.retrieveDataset(1)
                end
            end

            """
            @testset "success and retrieveDataset!" begin 

                mock_get = SimpleMock.Mock((id::Int) -> TaijaInteractive.DatasetsController.Dataset(;
                    id=DbId(1), name="My Dataset", source="source 1", format="format 1", size="10", lastChanged=format(now(), "yyyy-mm-dd HH:MM:SS"), poolId="1",))
                mock_isfile = SimpleMock.Mock((path::String) -> true)
                mock_read = SimpleMock.Mock((path, type) -> template_df)

                SimpleMock.mock(
                    TaijaInteractive.DatasetsController.get => mock_get,
                    isfile => mock_isfile,
                    CSV.read => mock_read,
                ) do mockGet, mockIsfile
                    SimpleMock.mock(CSV.read => mock_read) do mockRead
                        @test template_df == TaijaInteractive.DatasetsController.retrieveDataset(1)
                    end
                end 
            end
            """

        end


        

    end

    @testset "Dataset" begin
        @testset "getLabel" begin
            mock_dataset = Dataset(DbId(1), "Test Dataset", "Test Source", "CSV", "100", "2023-04-20", "1")
            mock_df = DataFrame(
                :feature1 => [1, 2, 3, 4, 5],
                :feature2 => ["A", "B", "C", "D", "E"],
                :label => ["X", "Y", "X", "Z", "Y"]
            )
        
            SimpleMock.mock(
                TaijaInteractive.DatasetsController.get => SimpleMock.Mock((id::Int) -> mock_dataset),
                CSV.read => SimpleMock.Mock((path, ::Type{DataFrame}) -> mock_df),
                joinpath => SimpleMock.Mock((args...) -> "mocked_path.csv")
            ) do mock_get, mock_csv_read, mock_joinpath
                labels = TaijaInteractive.DatasetsController.getLabels(1)
                
                @test labels == ["X", "Y", "Z"]
                @test SimpleMock.called_once_with(mock_get, 1)
                @test SimpleMock.called_once_with(mock_csv_read, "mocked_path.csv", DataFrame)
                @test SimpleMock.called_once_with(mock_joinpath, "public", "files", "1.csv")
            end
        end
    end

    
end
