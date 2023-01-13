defmodule MyApp.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def up do
    create table(:notifications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event, :string
      add :message, :text, null: false
      add :url, :string
      add :marked_read, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:notifications, [:user_id])
  end

  def down do
    drop index(:notifications, [:user_id])
    drop table(:notifications)
  end
end
