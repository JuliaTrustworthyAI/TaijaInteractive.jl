module CreateTableDashboards

import SearchLight.Migrations:
    create_table, column, columns, pk, add_index, drop_table, add_indices

function up()
    create_table(:dashboards) do
        [
            pk()
            column(:title, :string)
            column(:creationTime, :string)
            column(:lastAccessTime, :string)
            column(:modelKeys, :string)
            column(:datasetKeys, :string)
        ]
    end

    return add_index(:dashboards, :title)
end

function down()
    return drop_table(:dashboards)
end

end
