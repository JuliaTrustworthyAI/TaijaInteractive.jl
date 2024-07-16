using TaijaInteractive
using Test
using SimpleMock

using TaijaInteractive.DashboardElementsController.DashboardElements
using SearchLight
import Dates: DateTime, now, format

@testset "DashboardElementsController" begin

    @testset "crud_operations" begin

        mock_all = Mock((type::Type{DashboardElement}) -> [
            DashboardElement(;
                id=DbId(1),
                title="My element",
                type="Counterfactual",
                posX=0.0,
                posY=0.0,
                lastUpdateTime=format(now(), "yyyy-mm-dd HH:MM:SS"),
                dashboardId="3",
        ),],)

        mock(SearchLight.all => mock_all) do allMock 
            @testset "getAllElements" begin
                elements = TaijaInteractive.DashboardElementsController.getAllElements()

                @test length(elements) == 1
                @test elements[1].title == "My element"
            end
        end


        mock(
            SearchLight.save! => Mock((dashboardElement::DashboardElement) -> dashboardElement),
            find => Mock(
                (type::Type{DashboardElement}; id::DbId) -> [
                    DashboardElement(;
                        id,
                        title="My element",
                        type="Counterfactual",
                        posX=0.0,
                        posY=0.0,
                        lastUpdateTime=format(now(), "yyyy-mm-dd HH:MM:SS"),
                        dashboardId="3",
                    ),
                ],
            ),
            delete => Mock((element::DashboardElement) -> element),
        ) do save, mock_find, mock_delete

            element = TaijaInteractive.DashboardElementsController.create(
                "My element", "Counterfactual", 0.0, 0.0, "3"
            )


            @testset "create" begin
                @test element.title == "My element"
                @test element.type == "Counterfactual"
                @test element.posX == 0.0
                @test element.posY == 0.0
                @test element.dashboardId == "3"
            end

            @testset "update" begin
                edited = TaijaInteractive.DashboardElementsController.update(
                    element.id, "A different title", "Own Classifier", 3.0, 3.0, "5"
                )

                @test edited.title == "A different title"
                @test edited.type == "Own Classifier"
                @test edited.posX == 3.0
                @test edited.posY == 3.0
                @test edited.dashboardId == "5"

            end

            @testset "remove" begin

                element = nothing

                element = TaijaInteractive.DashboardElementsController.create(
                    "My element", "Counterfactual", 0.0, 0.0, "3"
                )

                # Mocking find and delete functions

                removed = TaijaInteractive.DashboardElementsController.remove(DbId(element.id))

                @test removed.title == element.title
                @test removed.posX == 0.0
                @test removed.posY == 0.0
                @test removed.type == element.type
                @test removed.dashboardId == element.dashboardId

            end
            """

            @testset "Get all Elements" begin
                using TaijaInteractive.DashboardElementsController
                #using Mocking: mock, unmock

                # Mock the all function to return a specific set of elements
                SimpleMock.mock(all => () -> ["element1", "element2", "element3"]) do
                    # Creating an element
                    element = create("My element", "Counterfactual", "3")
                    
                    # Mock getAllElements to return a predefined list
                    #mock(getAllElements => () -> [element, "element2", "element3"]) do
                        # Fetch all elements
                        getAll = getAllElements()
                        getAllByCorrectId = getElementsByDashboardId("3")
                        getAllByWrongId = getElementsByDashboardId("4")

                        @test element in getAll
                        @test element in getAllByCorrectId
                        @test !(element in getAllByWrongId)
                    #end
                end
            end

            """
        end
    end
end
