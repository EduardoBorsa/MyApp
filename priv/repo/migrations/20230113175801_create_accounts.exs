defmodule MyApp.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def up do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :active, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:accounts, [:name])
  end

  def down do
    drop index(:accounts, [:name])
    drop table(:accounts)
  end
end
