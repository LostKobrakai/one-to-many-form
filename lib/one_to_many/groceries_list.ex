defmodule OneToMany.GroceriesList do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias OneToMany.Line

  schema "groceries_lists" do
    field(:email, :string)

    has_many :lines, Line, on_replace: :delete

    timestamps()
  end

  def changeset(form, params) do
    form
    |> cast(params, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> cast_assoc(:lines, with: &Line.changeset/2)
  end

  def line_changeset(city, params) do
    changeset =
      city
      |> cast(params, [:item, :amount, :delete])
      |> validate_required([:item, :amount])

    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end

  ## Persistence
  ## Usually in a context

  def load do
    ordered_lines_query = from(l in Line, order_by: [asc: :sequence])
    list_query = from q in __MODULE__, preload: [lines: ^ordered_lines_query]
    OneToMany.Repo.one(list_query) || %__MODULE__{}
  end

  def save(list, params) do
    list
    |> changeset(params)
    |> OneToMany.Repo.insert_or_update()
  end
end
