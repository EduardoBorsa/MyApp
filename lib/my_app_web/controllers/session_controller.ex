defmodule MyAppWeb.SessionController do
  use MyAppWeb, :controller

  alias MyApp.Accounts
  alias MyApp.Services.Encryptr

  def new(conn, _params) do
    if Plug.Conn.get_session(conn, :current_user) do
      Phoenix.Controller.redirect(conn, to: "/")
    else
      render(conn, "new.html")
    end
  end

  def create(conn, params) do
    case Accounts.get_user_by(email: String.downcase(params["email"])) do
      {:ok, user} ->
        case Encryptr.validate_password(params["password"], user.password_hash) do
          true ->
            create_session_conds(conn, user)

          _ ->
            conn
            |> put_flash(:error, "Incorrect email or password.")
            |> render("new.html")
        end

      {:error, Ecto.NoResultsError} ->
        conn
        |> put_flash(:error, "No users found with that email address.")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:current_user)
    |> redirect(to: "/")
  end

  defp create_session_conds(conn, user) do
    cond do
      !user.verified and user.active ->
        conn
        |> put_session(:unverified_user, user.id)
        |> put_flash(
          :error,
          "Your account is not verified."
        )
        |> redirect(to: "/login")

      !user.account.active or !user.active ->
        conn
        |> put_session(:unverified_user, user.id)
        |> put_flash(
          :error,
          "Your account is currently inactive."
        )
        |> render("new.html")

      user.account.active and user.verified and user.active ->
        conn
        |> put_session(:current_user, user)
        |> redirect(to: "/")

      true ->
        conn |> render("new.html")
    end
  end
end
