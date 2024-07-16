using TaijaInteractive
using Test
using SearchLight
using SimpleMock: SimpleMock

using TaijaInteractive.DashboardsController.Dashboards
using TaijaInteractive.DashboardElementsController.DashboardElements
import Dates: DateTime, now, format

@testset "Dashboard Controller" begin

    mock_save = SimpleMock.Mock((dashboard::Dashboard) -> dashboard)
    mock_find = SimpleMock.Mock(
        (type::Type{Dashboard}; id::DbId) -> [
            Dashboard(;
                id=id,
                title="My Board",
                creationTime=format(now(), "yyyy-mm-dd HH:MM:SS"),
                lastAccessTime=format(now(), "yyyy-mm-dd HH:MM:SS"),
                modelKeys="",
                datasetKeys="",
            ),
        ],
    )
    mock_getelements = SimpleMock.Mock((id::DbId) -> [DashboardElement(;
        id=DbId(1),
        title="My Element",
        type="type",
        posX=0.0,
        posY=0.0,
        lastUpdateTime=format(now(), "yyyy-mm-dd HH:MM:SS"),
        dashboardId=string(id),
    )])
    mock_elementRemove = SimpleMock.Mock((id::DbId) -> DashboardElement(;
    id=DbId(1),
    title="My Element",
    type="type",
    posX=0.0,
    posY=0.0,
    lastUpdateTime=format(now(), "yyyy-mm-dd HH:MM:SS"),
    dashboardId=string(id),
    ))

    mock_delete = SimpleMock.Mock((dashboard::Dashboard) -> dashboard)


    SimpleMock.mock(
        SearchLight.save! => mock_save,
        find => mock_find,
        delete => mock_delete,
        DashboardElementsController.getElementsByDashboardId => mock_getelements,
        DashboardElementsController.remove => mock_elementRemove,
    ) do mockSave, mockFind, mockDelete, mockGetelements, mockElementRemove
        dashboard = TaijaInteractive.DashboardsController.create()

        @testset "create" begin
            

            @test dashboard.title == "My Board"
            @test dashboard.modelKeys == ""
            @test dashboard.datasetKeys == ""
        end

        @testset "getById" begin
            found = TaijaInteractive.DashboardsController.getById(dashboard.id)

            @test found.title == "My Board"
            @test found.modelKeys == ""
            @test found.datasetKeys == ""
            @test found.id == dashboard.id

            @test SimpleMock.called_once(mockSave)
            @test SimpleMock.called_once(mockFind)
        end

        @testset "update" begin
            dashboard = TaijaInteractive.DashboardsController.create()

            editedDashboard = TaijaInteractive.DashboardsController.update(
                dashboard.id,
                "ahalan",
                format(DateTime("2020-01-01", "yyyy-mm-dd"), "yyyy-mm-dd"),
                format(DateTime("2020-01-01", "yyyy-mm-dd"), "yyyy-mm-dd"),
                "1",
                "2",
            )

            @test editedDashboard.title == "ahalan"
            @test editedDashboard.creationTime ==
                format(DateTime("2020-01-01", "yyyy-mm-dd"), "yyyy-mm-dd")
            @test editedDashboard.lastAccessTime ==
                format(DateTime("2020-01-01", "yyyy-mm-dd"), "yyyy-mm-dd")
            @test editedDashboard.modelKeys == "1"
            @test editedDashboard.datasetKeys == "2"
        end
        
        @testset "remove" begin
            dashboard = TaijaInteractive.DashboardsController.create()
            removed = TaijaInteractive.DashboardsController.remove(DbId(dashboard.id))

            @test removed.title == dashboard.title
            @test removed.modelKeys == dashboard.modelKeys
            @test removed.datasetKeys == dashboard.datasetKeys
        end

        @testset "update title" begin
            dashboard = TaijaInteractive.DashboardsController.create()
            updated = TaijaInteractive.DashboardsController.updateTitle(dashboard.id, "new title")

            @test updated.title == "new title"
            @test updated.modelKeys == dashboard.modelKeys
            @test updated.id == dashboard.id
            @test updated.datasetKeys == dashboard.datasetKeys
            
        end
        
    end




    mock_all = SimpleMock.Mock(
        (type::Type{Dashboard}) -> [
            Dashboard(;
                id=DbId(1),
                title="My Board",
                creationTime=format(now(), "yyyy-mm-dd HH:MM:SS"),
                lastAccessTime=format(now(), "yyyy-mm-dd HH:MM:SS"),
                modelKeys="",
                datasetKeys="",
            ),
        ],
    )

    SimpleMock.mock(SearchLight.all => mock_all) do mockAll
        @testset "getAllDashboards" begin

            allDashboards = TaijaInteractive.DashboardsController.getAllBoards()

            @test length(allDashboards) == 1
            element = allDashboards[1]
            @test element.id == DbId(1)

        end
    end

end
