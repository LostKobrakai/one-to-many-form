defmodule OneToManyWeb.ListLive do
  use OneToManyWeb, :live_view
  alias OneToMany.GroceriesList

  @impl true
  def render(assigns) do
    ~H"""
    <.simple_form
      :let={f}
      id="form"
      for={@changeset}
      phx-change="validate"
      phx-submit="submit"
      as="form"
    >
      <.input field={{f, :email}} label="Email" />

      <fieldset class="flex flex-col gap-2">
        <legend>Groceries</legend>
        <%= for f_line <- Phoenix.HTML.Form.inputs_for(f, :lines) do %>
          <.line f_line={f_line} />
        <% end %>
        <.button class="mt-2" type="button" phx-click="add-line">Add</.button>
      </fieldset>

      <:actions>
        <.button>Save</.button>
      </:actions>
    </.simple_form>
    """
  end

  def line(assigns) do
    assigns =
      assign(
        assigns,
        :deleted,
        Phoenix.HTML.Form.input_value(assigns.f_line, :delete) == true
      )

    ~H"""
    <div class={if(@deleted, do: "opacity-50")}>
      <%= Phoenix.HTML.Form.hidden_inputs_for(@f_line) %>
      <.input field={{@f_line, :delete}} type="hidden" />
      <div class="flex gap-4 items-end">
        <div class="grow">
          <.input class="mt-0" field={{@f_line, :item}} readonly={@deleted} label="Item" />
        </div>
        <div class="grow">
          <.input
            class="mt-0"
            field={{@f_line, :amount}}
            type="number"
            readonly={@deleted}
            label="Amount"
          />
        </div>
        <.button
          class="grow-0"
          type="button"
          phx-click="delete-line"
          phx-value-index={@f_line.index}
          disabled={@deleted}
        >
          Delete
        </.button>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_, _, socket) do
    base = GroceriesList.load()
    {:ok, init(socket, base)}
  end

  defp init(socket, base) do
    changeset = GroceriesList.changeset(base, %{})

    assign(socket, base: base, changeset: changeset)
  end

  @impl true
  def handle_event("add-line", _, socket) do
    socket =
      update(socket, :changeset, fn changeset ->
        existing = get_change_or_field(changeset, :lines)
        Ecto.Changeset.put_embed(changeset, :lines, existing ++ [%{}])
      end)

    {:noreply, socket}
  end

  def handle_event("delete-line", %{"index" => index}, socket) do
    index = String.to_integer(index)

    socket =
      update(socket, :changeset, fn changeset ->
        existing = get_change_or_field(changeset, :lines)
        {to_delete, rest} = List.pop_at(existing, index)

        lines =
          if Ecto.Changeset.change(to_delete).data.id do
            List.replace_at(existing, index, Ecto.Changeset.change(to_delete, delete: true))
          else
            rest
          end

        Ecto.Changeset.put_embed(changeset, :lines, lines)
      end)

    {:noreply, socket}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    changeset =
      socket.assigns.base
      |> GroceriesList.changeset(params)
      |> struct!(action: :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    case GroceriesList.save(socket.assigns.base, params) do
      {:ok, data} ->
        socket = put_flash(socket, :info, "Submitted successfully")
        {:noreply, init(socket, data)}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp get_change_or_field(changeset, field) do
    with nil <- Ecto.Changeset.get_change(changeset, field) do
      Ecto.Changeset.get_field(changeset, field, [])
    end
  end
end
