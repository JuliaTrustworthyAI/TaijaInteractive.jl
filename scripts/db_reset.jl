using SearchLight

using SearchLightSQLite

# Load configuration and connect to the database
SearchLight.Configuration.load() |> SearchLight.connect
# Down migrations
SearchLight.Migrations.down("CreateTableModels")
SearchLight.Migrations.down("CreateTableDatasets")
SearchLight.Migrations.down("CreateTableDashboardelements")
SearchLight.Migrations.down("CreateTableDashboards")

# Up migrations
SearchLight.Migrations.up("CreateTableDashboards")
SearchLight.Migrations.up("CreateTableDashboardelements")
SearchLight.Migrations.up("CreateTableDatasets")
SearchLight.Migrations.up("CreateTableModels")
