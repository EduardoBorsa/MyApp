defmodule MyApp.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @required_keys ~w(name)a
  @optional_keys ~w(active)a
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "accounts" do
    field :active, :boolean, default: false
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, @required_keys ++ @optional_keys)
    |> unique_constraint(:name, message: "An account already exists with this name")
    |> validate_required(@required_keys)
  end
end
