module TaijaInteractive
using Genie

const up = Genie.up
export up
"""
starts the application
"""
function main()
    return Genie.genie(; context=@__MODULE__)
end

include("ParamHandlers/ParamHandler.jl")
include("ElementHandlers/ElementHandler.jl")

include("../app/resources/datasets/DatasetsController.jl")
include("../app/resources/models/ModelsValidator.jl")
include("../app/resources/models/ModelsController.jl")
include("../app/resources/datasets/DatasetsValidator.jl")

include("../app/resources/dashboardelements/DashboardElementsController.jl")
include("../app/resources/dashboardelements/DashboardElementsValidator.jl")

include("../app/resources/dashboards/DashboardsController.jl")
include("../app/resources/dashboards/DashboardsValidator.jl")

include("../app/resources/huggingface/HuggingFaceController.jl")

export DashboardElementsController
export DatasetsController
export ModelsController

export DashboardsValidator
export ModelsValidator
export DatasetsValidator
export DashboardElementsValidator

end
