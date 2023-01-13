defmodule MyApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :firstname, :string, null: false
      add :lastname, :string, null: false
      add :email, :string, null: false
      add :password_hash, :string
      add :active, :boolean, default: false, null: false
      add :verified, :boolean, default: false, null: false
      add :account_id, references(:accounts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:users, [:account_id])
    create unique_index(:users, [:email])
  end

  def down do
    drop index(:users, [:account_id])
    drop unique_index(:users, [:email])
    drop table(:users)
  end
end
