defmodule MyApp.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  @foreign_key_type :binary_id
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "notifications" do
    field :event, MyApp.AtomType
    field :marked_read, :boolean, default: false
    field :message, :string
    field :url, :string

    belongs_to :user, MyApp.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:event, :message, :url, :marked_read, :user_id])
    |> validate_required([:message, :user_id])
  end
end
