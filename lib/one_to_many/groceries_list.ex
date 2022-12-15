defmodule OneToMany.GroceriesList do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groceries_lists" do
    field(:email, :string)

    embeds_many :lines, Line, on_replace: :delete do
      field(:item, :string)
      field(:amount, :integer)
      field(:delete, :boolean, virtual: true)
    end

    timestamps()
  end

  def changeset(form, params) do
    form
    |> cast(params, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> cast_embed(:lines, with: &line_changeset/2)
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

  ## Persistance
  ## Usually in a context

  def load do
    OneToMany.Repo.one(__MODULE__) || %__MODULE__{}
  end

  def save(list, params) do
    list
    |> changeset(params)
    |> OneToMany.Repo.insert_or_update()
  end
end
