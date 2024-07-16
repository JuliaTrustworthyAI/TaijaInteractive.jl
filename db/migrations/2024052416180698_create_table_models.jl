module CreateTableModels

import SearchLight.Migrations:
    create_table, column, columns, pk, add_index, drop_table, add_indices

function up()
    create_table(:models) do
        [
            pk()
            column(:type, :string)
            column(:format, :string)
            column(:name, :string)
            column(:description, :string)
        ]
    end

    return add_index(:models, :type)
end

function down()
    return drop_table(:models)
end

end
