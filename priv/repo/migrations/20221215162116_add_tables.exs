defmodule OneToMany.Repo.Migrations.AddTables do
  use Ecto.Migration

  def change do
    create table("groceries_lists") do
      add :email, :string, null: false
      add :lines, :jsonb, null: false, default: "[]"

      timestamps()
    end

    create table("groceries_lines") do
      add :item, :string
      add :amount, :integer
      add :sequence, :integer
      add :groceries_list_id, references(:groceries_lists, on_delete: :delete_all)

      timestamps()
    end
  end
end
