module CreateTableDashboardelements

import SearchLight.Migrations:
    create_table, column, columns, pk, add_index, drop_table, add_indices

function up()
    create_table(:dashboardelements) do
        [
            pk()
            column(:title, :string)
            column(:type, :string)
            column(:posX, :float)
            column(:posY, :float)
            column(:lastUpdateTime, :string)
            column(:dashboardId, :string)
        ]
    end

    return add_index(:dashboardelements, :title)
end

function down()
    return drop_table(:dashboardelements)
end

end
