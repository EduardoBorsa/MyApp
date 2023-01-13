defmodule MyApp.Notifications do
  import Ecto.Query, warn: false
  alias MyApp.Repo

  alias MyApp.Notifications.Notification

  def list_notifications do
    Repo.all(Notification)
  end

  def list_notifications_for_user(nil), do: []

  def list_notifications_for_user(%{id: user_id}), do: list_notifications_for_user(user_id)

  def list_notifications_for_user(user_id) do
    query =
      from n in Notification,
        where: n.user_id == ^user_id,
        order_by: [asc: n.marked_read],
        order_by: [desc: n.inserted_at]

    query |> Repo.all()
  end

  def get_notification_count_for_user(user_id) do
    query =
      from n in Notification,
        where: n.user_id == ^user_id and n.marked_read == false,
        select: count(n.id)

    query |> Repo.one()
  end

  def get_notification!(id), do: Repo.get!(Notification, id)

  def get_notification_by(attrs), do: Repo.get_by(Notification, attrs)

  def create_notification(attrs \\ %{}) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:notification_created)
  end

  def create_notifications(%MyApp.Accounts.Account{id: id}) do
    users = MyApp.Accounts.list_users_by_criteria(account_id: id)

    Enum.reduce(users, Ecto.Multi.new(), fn %{id: id}, acc ->
      Ecto.Multi.insert(
        acc,
        "user-#{id}",
        Notification.changeset(%Notification{}, %{user_id: id, message: "new-user"})
      )
    end)
    |> Repo.transaction(timeout: :infinity)
    |> broadcast(:notification_created)
  end

  def update_notification(%Notification{} = notification, attrs) do
    notification
    |> Notification.changeset(attrs)
    |> Repo.update()
    |> broadcast(:notification_updated)
  end

  def delete_notification(%Notification{} = notification) do
    Repo.delete(notification) |> broadcast(:notification_updated)
  end

  def mark_all_as_read(user_id) do
    query = from n in Notification, where: n.user_id == ^user_id
    query |> Repo.update_all(set: [marked_read: true]) |> broadcast(:all_notifications_updated)
  end

  def mark_all_as_unread(user_id) do
    query = from n in Notification, where: n.user_id == ^user_id
    query |> Repo.update_all(set: [marked_read: false]) |> broadcast(:all_notifications_updated)
  end

  def delete_notifications_for_user(user_id) do
    query = from n in Notification, where: n.user_id == ^user_id
    query |> Repo.delete_all() |> broadcast(:all_notifications_updated)
  end

  def change_notification(%Notification{} = notification, attrs \\ %{}) do
    Notification.changeset(notification, attrs)
  end

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(MyApp.PubSub, @topic)
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, notification}, event) do
    Phoenix.PubSub.broadcast(MyApp.PubSub, @topic, {event, notification})

    {:ok, notification}
  end

  defp broadcast({_, _}, event) do
    Phoenix.PubSub.broadcast(MyApp.PubSub, @topic, {event, nil})
    :ok
  end
end
