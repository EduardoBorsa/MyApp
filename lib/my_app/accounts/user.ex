defmodule MyApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias MyApp.Services.Encryptr

  @required_keys ~w(firstname lastname email active account_id)a
  @optional_keys ~w(password verified )a
  @derive {Jason.Encoder, only: @required_keys ++ @optional_keys}
  @foreign_key_type :binary_id
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :active, :boolean, default: true
    field :email, :string
    field :firstname, :string
    field :lastname, :string
    field :verified, :boolean, default: false
    field :password_hash, :string
    field :password, :string, virtual: true

    belongs_to :account, MyApp.Accounts.Account
    has_many :notifications, MyApp.Notifications.Notification

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_keys ++ @optional_keys)
    |> validate_required(@required_keys)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> unique_constraint(:email, message: "That email address already exists in our system.")
    |> downcase_email
    |> encrypt_password
  end

  defp encrypt_password(changeset) do
    password = get_change(changeset, :password)

    if password do
      encrypted_password = Encryptr.hash_password(password)
      put_change(changeset, :password_hash, encrypted_password)
    else
      changeset
    end
  end

  defp downcase_email(changeset) do
    update_change(changeset, :email, &String.downcase/1)
  end
end
