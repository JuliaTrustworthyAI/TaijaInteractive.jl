using TaijaInteractive
using TaijaInteractive.DatasetsController.Datasets
using TaijaInteractive.DashboardElementsController.DashboardElements
using TaijaInteractive.DashboardsController.Dashboards
using TaijaInteractive.ModelsController.Models

using SimpleMock
using Test
import Dates: DateTime, now, format

using SearchLight, SearchLight.Validation

using Dates
@testset "Dataset Validator" begin
    k = TaijaInteractive.DatasetsValidator.not_empty(
        :name,
        Dataset(
            "Sample Dataset",
            "https://example.com",
            "CSV",
            "1000",
            "2023-06-08T08:00:00",
            "2",
        ),
    )
    @test k == ValidationResult(valid)

    @test TaijaInteractive.DatasetsValidator.not_empty(
        :name, Dataset("", "https://example.com", "CSV", "1000", "2023-06-08T08:00:00", "2")
    ) != ValidationResult(valid)

    @test TaijaInteractive.DatasetsValidator.is_int(
        :name,
        Dataset(
            "Sample Dataset",
            "https://example.com",
            "CSV",
            "1000",
            "2023-06-08T08:00:00",
            "2",
        ),
    ) != ValidationResult(valid)

    """
    SimpleMock.mock(SearchLight.save! => SimpleMock.Mock((dataset::Dataset) -> dataset),
    
    find => SimpleMock.Mock((type::Type{Dashboard}; id::DbId) -> [Dashboard(;title="MyBoard",
    creationTime=format(now(), "yyyy-mm-dd HH:MM:SS"),
    lastAccessTime=format(now(), "yyyy-mm-dd HH:MM:SS"),
    modelKeys="",
    datasetKeys="",
)])) do save

    
    dataset1 = TaijaInteractive.DatasetsController.create("name304i3948", "source 1", 0, "3")

    dataset2 = TaijaInteractive.DatasetsController.create("name304i3948", "source 1", 0, "3")
   
    dataset3 = TaijaInteractive.DatasetsController.create("name 2", "source 1", 0, "4")
    

    @test TaijaInteractive.DatasetsValidator.is_unique(:name, dataset3) == ValidationResult(valid)

    @test TaijaInteractive.DatasetsValidator.is_unique(:name, dataset2) != ValidationResult(valid)
    
    
    end 
"""
end

@testset "Dashboard Validator" begin
    tnow = format(now(), "yyyy-mm-dd HH:MM:SS")

    k = TaijaInteractive.DashboardsValidator.not_empty(
        :title, Dashboard(DbId(1), "Sample Dashboard", tnow, tnow, "", "")
    )
    @test k == ValidationResult(valid)

    k = TaijaInteractive.DashboardsValidator.not_empty(
        :title, Dashboard(DbId(1), "", tnow, tnow, "", "")
    )
    @test k != ValidationResult(valid)

    k = TaijaInteractive.DashboardsValidator.is_int(
        :title, Dashboard(DbId(1), "Sample Dashboard", tnow, tnow, "", "")
    )
    @test k != ValidationResult(valid)
end

@testset "Dashboard Element Validator" begin
    k = TaijaInteractive.DashboardElementsValidator.not_empty(
        :title,
        DashboardElement(
            "Sample Element", "Chart", 0.0, 0.0, "2023-06-08T08:00:00", string(1)
        ),
    )
    @test k == ValidationResult(valid)

    k = TaijaInteractive.DashboardElementsValidator.not_empty(
        :title, DashboardElement("", "Chart", 0.0, 0.0, "2023-06-08T08:00:00", string(1))
    )
    @test k != ValidationResult(valid)

    k = TaijaInteractive.DashboardElementsValidator.is_int(
        :title,
        DashboardElement(
            "Sample Element", "Chart", 0.0, 0.0, "2023-06-08T08:00:00", string(1)
        ),
    )
    @test k != ValidationResult(valid)
end

@testset "Model Validator" begin
    model = Model(DbId(1), "type", "format", "name", "description")

    k = TaijaInteractive.ModelsValidator.not_empty(:type, model)
    @test k == ValidationResult(valid)

    model.type = ""

    k = TaijaInteractive.ModelsValidator.not_empty(:type, model)
    @test k != ValidationResult(valid)

    k = TaijaInteractive.ModelsValidator.is_int(:type, model)
    @test k != ValidationResult(valid)
end

@testset "DashboardElement Unique Validator" begin
    element = DashboardElement(
        "Unique Element", "Chart", 0.0, 0.0, "2023-06-08T08:00:00", string(1)
    )

    SimpleMock.mock(
        findone => SimpleMock.Mock((::Type{DashboardElement}; args...) -> nothing),
        ispersisted => SimpleMock.Mock((::DashboardElement) -> false),
    ) do mock_findone, mock_ispersisted
        result = TaijaInteractive.DashboardElementsValidator.is_unique(:title, element)
        @test result == ValidationResult(valid)
    end

    SimpleMock.mock(
        findone => SimpleMock.Mock((::Type{DashboardElement}; args...) -> element),
        ispersisted => SimpleMock.Mock((::DashboardElement) -> false),
    ) do mock_findone_existing, mock_ispersisted_existing
        result = TaijaInteractive.DashboardElementsValidator.is_unique(:title, element)
        @test result != ValidationResult(valid)
    end
end

@testset "Models Unique Validator" begin
    model = Model("Type", "Format", "Unique Name", "Description")

    SimpleMock.mock(
        findone => SimpleMock.Mock((::Type{Model}; args...) -> nothing),
        ispersisted => SimpleMock.Mock((::Model) -> false),
    ) do mock_findone, mock_ispersisted
        result = TaijaInteractive.ModelsValidator.is_unique(:name, model)
        @test result == ValidationResult(valid)
    end

    SimpleMock.mock(
        findone => SimpleMock.Mock((::Type{Model}; args...) -> model),
        ispersisted => SimpleMock.Mock((::Model) -> false),
    ) do mock_findone_existing, mock_ispersisted_existing
        result = TaijaInteractive.ModelsValidator.is_unique(:name, model)
        @test result != ValidationResult(valid)
    end
end

@testset "Dashboards Unique Validator" begin
    dashboard = Dashboard(
        "Unique Title",
        "2023-06-08T08:00:00",
        "2023-06-08T09:00:00",
        "model1,model2",
        "dataset1,dataset2",
    )

    SimpleMock.mock(
        findone => SimpleMock.Mock((::Type{Dashboard}; args...) -> nothing),
        ispersisted => SimpleMock.Mock((::Dashboard) -> false),
    ) do mock_findone, mock_ispersisted
        result = TaijaInteractive.DashboardsValidator.is_unique(:title, dashboard)
        @test result == ValidationResult(valid)
    end

    SimpleMock.mock(
        findone => SimpleMock.Mock((::Type{Dashboard}; args...) -> dashboard),
        ispersisted => SimpleMock.Mock((::Dashboard) -> false),
    ) do mock_findone_existing, mock_ispersisted_existing
        result = TaijaInteractive.DashboardsValidator.is_unique(:title, dashboard)
        @test result != ValidationResult(valid)
    end
end

@testset "Datasets Unique Validator" begin
    dataset = Dataset(
        "Unique Name", "Source", "Format", "100", "2023-06-08T08:00:00", "pool1"
    )

    SimpleMock.mock(
        findone => SimpleMock.Mock((::Type{Dataset}; args...) -> nothing),
        ispersisted => SimpleMock.Mock((::Dataset) -> false),
    ) do mock_findone, mock_ispersisted
        result = TaijaInteractive.DatasetsValidator.is_unique(:name, dataset)
        @test result == ValidationResult(valid)
    end

    SimpleMock.mock(
        findone => SimpleMock.Mock((::Type{Dataset}; args...) -> dataset),
        ispersisted => SimpleMock.Mock((::Dataset) -> false),
    ) do mock_findone_existing, mock_ispersisted_existing
        result = TaijaInteractive.DatasetsValidator.is_unique(:name, dataset)
        @test result != ValidationResult(valid)
    end
end
