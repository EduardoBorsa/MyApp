defmodule MyApp.Workers.NotificationWorker do
  @moduledoc """
  This is the Workers.NotificationWorker module.
  """
  use Oban.Worker, queue: :scheduled

  @impl Oban.Worker
  def perform(_job) do
    :ok
  end
end
