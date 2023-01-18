defmodule OneToMany.Line do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groceries_lines" do
    field(:item, :string)
    field(:amount, :integer)
    field(:sequence, :integer)
    field(:delete, :boolean, virtual: true)

    belongs_to :groceries_list, OneToMany.GroceriesList

    timestamps()
  end

  def changeset(form, params) do
    changeset =
      form
      |> cast(params, [:item, :amount, :sequence, :delete])
      |> validate_required([:item, :amount, :sequence])

    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
