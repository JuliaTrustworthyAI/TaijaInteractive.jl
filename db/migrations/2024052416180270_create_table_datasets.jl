module CreateTableDatasets

import SearchLight.Migrations:
    create_table, column, columns, pk, add_index, drop_table, add_indices

function up()
    create_table(:datasets) do
        [
            pk()
            column(:name, :string)
            column(:source, :string)
            column(:format, :string)
            column(:size, :string)
            column(:lastChanged, :string)
            column(:poolId, :string)
        ]
    end

    return add_index(:datasets, :name)
end

function down()
    return drop_table(:datasets)
end

end
