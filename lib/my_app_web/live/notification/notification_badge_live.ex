defmodule MyAppWeb.NotificationBadgeLive do
  @moduledoc """
  This is the NotificationBadgeLive module.
  """
  use MyAppWeb, :live_view
  use Phoenix.HTML

  alias MyApp.Notifications

  def mount(_params, session, socket) do
    Notifications.subscribe()

    current_user = session["current_user"]

    socket =
      assign(socket,
        current_user: current_user,
        notification_count: Notifications.get_notification_count_for_user(current_user.id)
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <%= if @notification_count > 0 do %>
      <span class="tag is-rounded is-danger wb-badge" style="display:flex"><%= @notification_count %></span>
    <% end %>
    """
  end

  def handle_info({:notification_created, _notification}, socket) do
    current_user = socket.assigns.current_user

    {:noreply,
     update(
       socket,
       :notification_count,
       fn _ -> Notifications.get_notification_count_for_user(current_user.id) end
     )}
  end

  def handle_info({:notification_updated, _notification}, socket) do
    current_user = socket.assigns.current_user

    {:noreply,
     update(
       socket,
       :notification_count,
       Notifications.get_notification_count_for_user(current_user.id)
     )}
  end

  def handle_info({:all_notifications_updated, nil}, socket) do
    current_user = socket.assigns.current_user

    {:noreply,
     update(
       socket,
       :notification_count,
       Notifications.get_notification_count_for_user(current_user.id)
     )}
  end
end
