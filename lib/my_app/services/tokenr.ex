defmodule MyApp.Services.Tokenr do
  import Plug.Conn

  @reset_password "reset_password"
  @verify_user "verify_user"
  @login_token "login_user_token"

  def generate_auth_token(user) do
    Phoenix.Token.sign(MyAppWeb.Endpoint, @login_token, user)
  end

  def verify_auth_token(token) do
    Phoenix.Token.verify(MyAppWeb.Endpoint, @login_token, token, max_age: 604_800)
  end

  def generate_forgot_email_token(user) do
    Phoenix.Token.sign(MyAppWeb.Endpoint, @reset_password, user)
  end

  def verify_forgot_email_token(token) do
    Phoenix.Token.verify(MyAppWeb.Endpoint, @reset_password, token, max_age: 604_800)
  end

  def generate_verify_user_token(user) do
    Phoenix.Token.sign(MyAppWeb.Endpoint, @verify_user, user)
  end

  def verify_user_token(token) do
    Phoenix.Token.verify(MyAppWeb.Endpoint, @verify_user, token, max_age: 604_800)
  end

  def get_user_from_token(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user} <- verify_auth_token(token) do
      {:ok, user}
    else
      _ ->
        {:error, "Invalid token"}
    end
  end

  def get_account_from_token(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user} <- verify_auth_token(token) do
      {:ok, user.account_id}
    else
      _ ->
        {:error, "Invalid token"}
    end
  end

  def get_account_and_user_from_token(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user} <- verify_auth_token(token) do
      {:ok, %{"account_id" => user.account_id, "user_id" => user.id}}
    else
      _ ->
        {:error, "Invalid token"}
    end
  end
end
