defmodule MyApp.Accounts.Query do
  import Ecto.Query, warn: false
  alias MyApp.Accounts.User

  def users_by_criteria(criteria) do
    query = from(u in User)

    Enum.reduce(criteria, query, fn
      {:account_id, account_id}, query ->
        from q in query, where: q.account_id == ^account_id

      {:firstname, firstname}, query ->
        from q in query, where: q.firstname == ^firstname

      {:lastname, lastname}, query ->
        from q in query, where: q.lastname == ^lastname

      {:preload_account, true}, query ->
        from q in query, preload: [:account]

      _, query ->
        query
    end)
  end
end
