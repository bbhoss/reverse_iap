defmodule ReverseIap.AddIapCookiePlug do
  import Plug.Conn


  # TODO: Generate initial credential token here
  def init(options), do: options

  def call(conn, _opts) do
    add_iap_cookie(conn)
  end

  defp fetch_jwt() do
    ReverseIap.TokenProvider.current_token()
  end

  defp add_iap_cookie(conn) do
    jwt_cookie = fn -> "GCP_IAAP_AUTH_TOKEN=#{fetch_jwt()}" end

    case get_req_header(conn, "cookie") do
      [] -> put_req_header(conn, "cookie", jwt_cookie.())
      [cookiestring] -> put_req_header(conn, "cookie", cookiestring <> "; " <> jwt_cookie.())
    end
  end
end
