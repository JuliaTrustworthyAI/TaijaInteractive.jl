module DashboardElementsController

using Genie.Router, Genie.Renderer, Genie.Renderer.Html, Genie.Requests
using CounterfactualExplanations
using CounterfactualExplanations:
    Generators, DataPreprocessing, Models, AbstractGenerator, CounterfactualExplanation
using TaijaData
using TaijaPlotting
using Plots
using SearchLightSQLite
using SQLite
using Mocking
using ..ElementHandlers
using ..ParamHandlers
using ..ModelsController
using ..DatasetsController

import SearchLight: AbstractModel, DbId, save!, all, delete, find, SQLWhereExpression
import Dates: DateTime, now, format

include("./DashboardElements.jl")

#include("./../datasets/DatasetsController.jl")

#include("./../models/ModelsController.jl")
using .DashboardElements

include("./controller/elements.jl")
include("./controller/crud_operations.jl")

# Counterfactual Generator Exports
export generateElement
export renderElement
export getElementsByDashboardId
export renderElementsByDashboardId

end
