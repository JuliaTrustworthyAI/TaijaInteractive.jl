using TaijaInteractive.DashboardElementsController.DashboardElements
using TaijaInteractive.DashboardElementsController
using Genie
using Test
using Dates
using TaijaData
using CounterfactualExplanations.Generators
using CounterfactualExplanations
using TaijaInteractive
using Dates
using SearchLight: DbId, find
using SearchLight
using Plots
using SimpleMock

function test_dashboardelement()
    #@testset "DashboardElement struct" begin

    dashboardElement = DashboardElementsController.DashboardElements.DashboardElement(
        "Sample Element", "Chart", 0.0, 0.0, "2023-06-08T08:00:00", string(1)
    )

    @test dashboardElement.title == "Sample Element"
    @test dashboardElement.type == "Chart"
    @test dashboardElement.lastUpdateTime isa String
    @test dashboardElement.posX == 0.0
    @test dashboardElement.posY == 0.0
    @test dashboardElement.dashboardId == "1"

    id = DbId()
    element2 = DashboardElementsController.DashboardElements.DashboardElement(
        id, "halo", "ce", 0.0, 0.0, "2023-06-08T08:00:00", "2"
    )

    @test element2.id == id
    @test element2.title == "halo"
    @test element2.type == "ce"
    @test dashboardElement.posX == 0.0
    @test dashboardElement.posY == 0.0
    @test element2.lastUpdateTime isa String
    @test element2.dashboardId == "2"


end

    #@testset "element" begin
    # dashboardElement = DashboardElementsController.DashboardElements.DashboardElement("Sample Element", "CE", "2023-06-08T08:00:00", string(1))

    # rendered = TaijaInteractive.DashboardElementsController.renderElement(dashboardElement)

    #demo and rendersubelement not tested
    #end


# @testset "crud dashboardelements" begin
#     TaijaInteractive.DashboardElementsController.create("hm", "CE", "42")
#     des = TaijaInteractive.DashboardElementsController.getElementsByDashboardId("42")
#     de = des[1]
#     @test de.title == "hm"
#     @test de.type == "CE"
#     @test de.dashboardId == "42"

#     id = de.id

#     du1 = TaijaInteractive.DashboardElementsController.update(id, "mh", "CS", "420")
#     #TODO check that there is no element by id 42
#     dus2 = TaijaInteractive.DashboardElementsController.getElementsByDashboardId("420")
#     #du1 = dus1[1]
#     du2 = dus2[2]

#     @test du1.title == "mh" && "mh" == du2.title
#     @test du1.type == "CS" && "CS" == du2.type
#     @test du1.dashboardId == "420" &&"420" == du2.dashboardId
#     #@test du1.id == du2.id
#     #TODO remove andcheck that it isn't there

