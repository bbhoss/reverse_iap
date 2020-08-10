defmodule ReverseIap.Router do
  use Plug.Router

  plug :match
  plug ReverseIap.AddIapCookiePlug
  plug :dispatch

  match "/*glob" do
    # Do things in a wildcard match so we can pull from the app env at runtime
    Plug.forward(conn, glob, ReverseProxyPlug,
      ReverseProxyPlug.init(upstream: Application.fetch_env!(:reverse_iap, :upstream_url))
    )
  end
end
