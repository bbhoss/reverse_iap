defmodule ReverseIap.Application do
  @moduledoc false

  use Application

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    children = [
      {ReverseIap.TokenProvider,
       audience: Application.fetch_env!(:reverse_iap, :audience),
       principal: Application.fetch_env!(:reverse_iap, :principal)},
      {Plug.Cowboy,
       scheme: :http,
       plug: ReverseIap.Router,
       options: [port: Application.get_env(:reverse_iap, :port, 8099)]}
    ]

    opts = [strategy: :one_for_one, name: ReverseIap.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
