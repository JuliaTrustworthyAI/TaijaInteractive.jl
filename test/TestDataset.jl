using TaijaInteractive.DatasetsController.Datasets
using Test
using Dates
function testDataset()
    dataset = Dataset(
        "Sample Dataset", "https://example.com", "CSV", "1000", "2023-06-08T08:00:00", "2"
    )

    @test dataset.name == "Sample Dataset"
    @test dataset.source == "https://example.com"
    @test dataset.format == "CSV"
    @test dataset.size == "1000"
    @test dataset.lastChanged == "2023-06-08T08:00:00"
    @test dataset.poolId == "2"
end
