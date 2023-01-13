defmodule MyApp.Services.Encryptr do
  import Argon2

  def hash_password(password), do: hash_pwd_salt(password)
  def validate_password(nil, _hash), do: {:error, "Invalid password"}
  def validate_password(password, hash), do: verify_pass(password, hash)
end
