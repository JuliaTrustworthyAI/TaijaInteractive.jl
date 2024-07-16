module DashboardsController

using Genie.Router, Genie.Renderer
using ..DashboardElementsController
import SearchLight: AbstractModel, DbId, save!, all, delete, find

import Dates: DateTime, now, format

export getAllBoards
export getById
export updateTitle
export getElementsByDashboardId

include("./Dashboards.jl")
using .Dashboards

include("./controller/crud_operations.jl")
include("./controller/dashboards.jl")

end
