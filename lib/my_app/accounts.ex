defmodule MyApp.Accounts do
  import Ecto.Query, warn: false
  alias MyApp.Repo

  alias MyApp.Accounts.Account
  alias MyApp.Accounts.Query

  def list_accounts do
    Repo.all(Account)
  end

  def get_account!(id), do: Repo.get!(Account, id)

  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end

  alias MyApp.Accounts.User

  def list_users do
    Repo.all(User) |> Repo.preload(:account)
  end

  def list_users_by_criteria(criteria) when is_list(criteria) do
    Query.users_by_criteria(criteria)
    |> Repo.all()
  end

  def get_user_by_criteria(criteria) do
    Query.users_by_criteria(criteria)
    |> Repo.one()
  end

  def get_user!(id), do: Repo.get!(User, id) |> Repo.preload(:account)

  def get_user_by(attrs) do
    user = Repo.get_by(User, attrs) |> Repo.preload(:account)

    if user do
      {:ok, user}
    else
      {:error, Ecto.NoResultsError}
    end
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.transaction(fn ->
      user =
        user
        |> Repo.preload([:notifications])

      user
      |> Map.get(:notifications)
      |> Enum.each(fn notification ->
        notification
        |> Repo.delete!()
      end)

      Repo.delete!(user)
    end)
  rescue
    changeset_error ->
      {:error, changeset_error}
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
