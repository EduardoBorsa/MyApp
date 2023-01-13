defmodule MyAppWeb.NotificationLive do
  @moduledoc """
  This is the NotificationLive module.
  """
  use MyAppWeb, :live_view
  use Phoenix.HTML

  alias MyApp.Notifications

  def mount(_params, session, socket) do
    Notifications.subscribe()

    current_user = session["current_user"]

    socket =
      assign(socket,
        notifications: Notifications.list_notifications_for_user(current_user),
        current_user: session["current_user"]
      )

    {:ok, socket, temporary_assigns: [notifications: []]}
  end

  def handle_info({:notification_created, notification}, socket) do
    current_user = socket.assigns.current_user

    if notification.user_id == current_user.id do
      {:noreply,
       update(socket, :notifications, fn notifications ->
         [notification | notifications]
       end)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:notification_updated, _notification}, socket) do
    current_user = socket.assigns.current_user

    {:noreply,
     update(socket, :notifications, Notifications.list_notifications_for_user(current_user.id))}
  end

  def handle_info({:all_notifications_updated, nil}, socket) do
    current_user = socket.assigns.current_user

    {:noreply,
     update(socket, :notifications, Notifications.list_notifications_for_user(current_user.id))}
  end

  def handle_event("mark_as_read", %{"id" => id}, socket) do
    notification = Notifications.get_notification!(id)

    Notifications.update_notification(notification, %{marked_read: true})

    {:noreply, socket}
  end

  def handle_event("mark_as_unread", %{"id" => id}, socket) do
    notification = Notifications.get_notification!(id)

    Notifications.update_notification(notification, %{marked_read: false})

    {:noreply, socket}
  end

  def handle_event("clear", %{"id" => id}, socket) do
    notification = Notifications.get_notification!(id)

    Notifications.delete_notification(notification)

    {:noreply, socket}
  end

  def handle_event("mark_all_as_read", _, socket) do
    current_user = socket.assigns.current_user

    Notifications.mark_all_as_read(current_user.id)

    {:noreply, socket}
  end

  def handle_event("mark_all_as_unread", _, socket) do
    current_user = socket.assigns.current_user

    Notifications.mark_all_as_unread(current_user.id)

    {:noreply, socket}
  end

  def handle_event("clear_all", _, socket) do
    current_user = socket.assigns.current_user

    Notifications.delete_notifications_for_user(current_user.id)

    {:noreply, socket}
  end
end
