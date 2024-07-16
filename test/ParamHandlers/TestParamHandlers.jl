using Test
using SimpleMock
using TaijaInteractive.ParamHandlers

@testset "ParamHandlers" begin
    ph = TaijaInteractive.ParamHandlers

    @testset "EmptyParamHandler" begin
        # Set up the handler
        handler = ph.buildParamHandler()

        @test handler == handler.root
        @test ph.isEnd(handler) && ph.isStart(handler)

        @test_throws ArgumentError("Paramater name model cannot be found.") ph.getParam(
            handler, :model
        )

        params = ph.getModelParams(handler)
        @test params isa Set && length(params) == 0

        params = ph.getDatasetParams(handler)
        @test params isa Set && length(params) == 0
    end

    @testset "SpecialParamHandler" begin
        @testset "Model" begin
            # Set up the handler
            handler = ph.addModelParamHandler(:MyModel, "First Model")
            handler = ph.buildParamHandler!(handler)

            @test handler.root == handler
            @test handler.type == :model
            @test handler.identifier == :MyModel
            @test handler.name == "First Model"
            @test handler.value == -1

            @test handler.next isa EmptyParamHandler

            @test ph.isEnd(handler) && ph.isStart(handler)
            @test ph.isEnd(handler.next) && !ph.isStart(handler.next)

            @test ph.getParam(handler, :MyModel) == -1
            @test_throws ArgumentError("Paramater name NotMyModel cannot be found.") ph.getParam(
                handler, :NotMyModel
            )

            params = ph.getModelParams(handler)
            @test params isa Set && length(params) == 1 && :MyModel in params

            params = ph.getDatasetParams(handler)
            @test params isa Set && length(params) == 0
        end

        @testset "Dataset" begin
            # Set up the handler
            handler = ph.addDatasetParamHandler(:MyDataset, "First Dataset")
            handler = ph.addModelParamHandler!(handler, :MyModel, "First Model")
            handler = ph.buildParamHandler!(handler)

            @test handler.root == handler
            @test handler.type == :dataset
            @test handler.identifier == :MyDataset
            @test handler.name == "First Dataset"
            @test handler.value == -1

            @test handler.next isa SpecialParamHandler
            @test handler.next.next isa EmptyParamHandler

            @test !ph.isEnd(handler) && ph.isStart(handler)
            @test ph.isEnd(handler.next) && !ph.isStart(handler.next)

            @test ph.getParam(handler, :MyDataset) == -1
            @test ph.getParam(handler, :MyModel) == -1
            @test_throws ArgumentError("Paramater name NotMyDataset cannot be found.") ph.getParam(
                handler, :NotMyDataset
            )

            params = ph.getModelParams(handler)
            @test params isa Set && length(params) == 1 && :MyModel in params

            params = ph.getDatasetParams(handler)
            @test params isa Set && length(params) == 1 && :MyDataset in params
        end
    end

    @testset "CustomParamHandler" begin
        # Set up the handler
        handler = ph.addCustomParamHandler("No Parameters")
        handler = ph.addDatasetParamHandler!(handler, :MyDataset, "First Dataset")
        handler = ph.addCustomParamHandler!(handler, "Plot Parameters")
        addFieldParam!(handler, :title, "Graph Title", "My Plot")
        addCheckboxParam!(handler, :toInclude, "Include Graph?", true)
        addSelectorParam!(
            handler, :type, "Graph Type", "Type A", vec(["Type A", "Type B", "Type C"])
        )
        handler = ph.buildParamHandler!(handler)

        @test handler.root == handler
        @test handler.params == Dict()
        @test handler.title == "No Parameters"

        @test handler isa CustomParamHandler

        @test !ph.isEnd(handler) && ph.isStart(handler)
        @test !ph.isEnd(handler.next) && !ph.isStart(handler.next)
        @test ph.isEnd(handler.next.next) && !ph.isStart(handler.next.next)

        @test ph.getParam(handler, :MyDataset) == -1
        @test ph.getParam(handler, :title) == "My Plot"
        @test ph.getParam(handler, :toInclude) == true
        @test ph.getParam(handler, :type) == "Type A"

        params = ph.getModelParams(handler)
        @test params isa Set && length(params) == 0

        params = ph.getDatasetParams(handler)
        @test params isa Set && length(params) == 1 && :MyDataset in params
    end

    @testset "ParamHandlers: Render" begin
        @testset "EmptyParamHandler" begin
            # Set up the handler
            handler = ph.buildParamHandler()

            renderedMenu = string(ph.render(handler))

            @test occursin("class=\"inner-vertical-menu-submit\"", renderedMenu)
            @test occursin("<button", renderedMenu)
            @test !occursin("\"inner-vertical-menu-item\"", renderedMenu)
        end

        @testset "SpecialParamHandler" begin
            @testset "Model" begin
                # Set up the handler
                handler = ph.addModelParamHandler(:MyModel, "First Model")
                handler = ph.buildParamHandler!(handler)

                renderedMenu = string(ph.render(handler))

                @test occursin("class=\"inner-vertical-menu-submit\"", renderedMenu)
                @test occursin("\"inner-vertical-menu-item\"", renderedMenu)
                #@test occursin("class=\"model\"", renderedMenu)
                @test !occursin("class=\"dataset\"", renderedMenu)
            end

            @testset "Dataset" begin
                # Set up the handler
                handler = ph.addDatasetParamHandler(:MyDataset, "First Dataset")
                handler = ph.buildParamHandler!(handler)

                renderedMenu = string(ph.render(handler))

                @test occursin("class=\"inner-vertical-menu-submit\"", renderedMenu)
                @test occursin("\"inner-vertical-menu-item\"", renderedMenu)
                @test !occursin("class=\"model\"", renderedMenu)
                #@test occursin("class=\"dataset\"", renderedMenu)
            end
        end

        @testset "CustomParamHandler" begin
            # Set up the handler
            handler = ph.addCustomParamHandler("No Parameters")
            handler = ph.addDatasetParamHandler!(handler, :MyDataset, "First Dataset")
            handler = ph.addCustomParamHandler!(handler, "Plot Parameters")
            addFieldParam!(handler, :title, "Graph Title", "My Plot")
            addCheckboxParam!(handler, :toInclude, "Include Graph?", true)
            addSelectorParam!(
                handler, :type, "Graph Type", "Type A", vec(["Type A", "Type B", "Type C"])
            )
            handler = ph.buildParamHandler!(handler)

            renderedMenu = string(ph.render(handler))

            @test occursin("class=\"inner-vertical-menu-submit\"", renderedMenu)
            @test count("\"inner-vertical-menu-item\"", renderedMenu) == 3
            @test count("<option", renderedMenu) == 3
            @test count("type=\"text\"", renderedMenu) == 1
            @test count("type=\"checkbox\"", renderedMenu) == 1
            @test_throws ArgumentError("Parameter Type invalid is not recognized.") ph.renderParameter(
                :InvalidParameter, (type=:invalid, name="My Invalid Parameter")
            )

            wrappedMenu = ph.renderMenu(3, :myElement, handler)
            @test occursin("action=\"/dashboard/3/generateElement\"", wrappedMenu)
            @test occursin("id=\"element-handler-form-myElement\"", wrappedMenu)
        end
    end

    @testset "ParamHandlers: Read" begin

        # To access the payload function
        import Genie.Requests.postpayload

        @testset "EmptyParamHandler" begin
            # Set up the handler
            handler = ph.buildParamHandler()

            params = ph.readPostParams(handler)

            @test params isa Dict && length(keys(params)) == 0
        end

        @testset "SpecialParamHandler" begin
            # Set up the handler
            handler = ph.addModelParamHandler(:MyModel, "First Model")
            handler = ph.addDatasetParamHandler!(handler, :MyDataset, "First Dataset")
            handler = ph.buildParamHandler!(handler)

            mockedPayload = Mock((x::Symbol, y::Any) -> (x == :MyModel) ? "3" : "7")

            mock((postpayload) => mockedPayload) do payload
                params = ph.readPostParams(handler)

                @test length(keys(params)) == 2 &&
                    params[:MyModel] == "3" &&
                    params[:MyDataset] == "7"
            end
        end

        @testset "CustomParamHandler" begin
            # Set up the handler
            handler = ph.addCustomParamHandler("No Parameters")
            handler = ph.addDatasetParamHandler!(handler, :MyDataset, "First Dataset")
            handler = ph.addCustomParamHandler!(handler, "Plot Parameters")
            addFieldParam!(handler, :title, "Graph Title", "My Plot")
            addCheckboxParam!(handler, :toInclude, "Include Graph?", true)
            addSelectorParam!(
                handler, :type, "Graph Type", "Type A", vec(["Type A", "Type B", "Type C"])
            )
            handler = ph.buildParamHandler!(handler)

            fakeParams = Dict(
                :MyDataset => 2,
                :title => "Not My Plot",
                :toInclude => false,
                :type => "Type C",
            )
            mockedPayload = Mock((x::Symbol, y::Any) -> fakeParams[x])

            mock((postpayload) => mockedPayload) do payload
                params = ph.readPostParams(handler)

                @test length(keys(params)) == 4
            end
        end
    end
end
