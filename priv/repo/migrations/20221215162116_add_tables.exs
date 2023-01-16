defmodule OneToMany.Repo.Migrations.AddTables do
  use Ecto.Migration

  def change do
    create table("groceries_lists") do
      add :email, :string, null: false
      add :lines, :jsonb, null: false, default: "[]"

      timestamps()
    end
  end
end
