defmodule MyAppWeb.UserController do
  use MyAppWeb, :controller

  require Logger

  alias MyApp.Accounts
  alias MyApp.Accounts.User
  alias MyApp.Mailer
  alias MyApp.Services.Tokenr

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    accounts = Accounts.list_accounts()

    render(conn, "new.html",
      changeset: changeset,
      edit_mode: false,
      accounts: accounts
    )
  end

  def create(conn, %{"user" => user_params}) do
    accounts = Accounts.list_accounts()

    case Accounts.create_user(user_params) do
      {:ok, user} ->
        MyApp.Notifications.create_notifications(
          conn.private[:plug_session]["current_user"].account
        )

        try do
          Swoosh.Email.new(from: "admin@email.com", to: user.email) |> Mailer.deliver()
        rescue
          error -> Logger.error("Error sending Mailer: ", error)
        after
          conn
          |> put_flash(:success, "User created successfully.")
          |> redirect(to: Routes.user_path(conn, :index))
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html",
          changeset: changeset,
          edit_mode: false,
          accounts: accounts
        )
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    accounts = Accounts.list_accounts()

    render(conn, "edit.html",
      user: user,
      changeset: changeset,
      edit_mode: true,
      accounts: accounts
    )
  end

  def update(conn, %{"id" => id, "user" => user_params, "wb_admin" => wb_admin}) do
    user = Accounts.get_user!(id)
    accounts = Accounts.list_accounts()

    user_params = Map.merge(user_params, %{"wb_admin" => wb_admin})

    case Accounts.update_user(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:success, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          user: user,
          changeset: changeset,
          edit_mode: true,
          accounts: accounts
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    result = Tokenr.get_user_from_token(conn)
    IO.inspect(result)
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:success, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end
end
