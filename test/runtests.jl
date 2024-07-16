using TaijaInteractive
using Test
using Revise

includet("Aqua.jl")
test_aqua()

include("controllers/TestElementController.jl")
include("controllers/TestDashboardController.jl")
include("controllers/TestDatasetController.jl")
include("controllers/TestModelsController.jl")
include("controllers/TestHuggingFaceController.jl")

includet("TestDashboardelement.jl")
test_dashboardelement() 
includet("TestDataset.jl")
testDataset()
include("TestValidators.jl")
include("ElementHandlers/TestConformalElementHandler.jl")
include("ElementHandlers/TestCounterfactualElementHandler.jl")
include("ParamHandlers/TestParamHandlers.jl")

# Selenium tests for the frontend
#include("TestSelenium.jl")
