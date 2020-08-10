defmodule ReverseIap.TokenProvider do
  use GenServer
  defmodule State, do: defstruct(~w(token expiry retriever audience principal)a)

  def start_link([]) do
    GenServer.start_link(__MODULE__, [retriever: ReverseIap.TokenRetriever], name: __MODULE__)
  end

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: __MODULE__)
  end

  def init(init_arg) do
    retriever = Keyword.get(init_arg, :retriever, ReverseIap.TokenRetriever)
    audience = Keyword.fetch!(init_arg, :audience)
    principal = Keyword.fetch!(init_arg, :principal)
    %{token: initial_jwt, expiry: expiry} = fetch_jwt(retriever, audience, principal)

    {:ok,
     %State{
       token: initial_jwt,
       expiry: expiry,
       retriever: retriever,
       audience: audience,
       principal: principal
     }}
  end

  def handle_call(:current_token, _from, state) do
    case DateTime.compare(state.expiry, DateTime.utc_now()) do
      :gt -> {:reply, state.token, state}
      _ -> handle_expired_token(state)
    end
  end

  defp fetch_jwt(retriever, audience, principal) do
    jwt = retriever.token_for_audience(audience, principal)
    expiry_time = decode_expiry(jwt)

    %{token: jwt, expiry: expiry_time}
  end

  defp decode_expiry(jwt) do
    case Joken.peek_claims(jwt) do
      {:ok, %{"exp" => exp}} -> DateTime.from_unix!(exp)
      _ -> raise "Unable to determine expiry from token"
    end
  end

  defp update_state_with_new_token(state) do
    updated_token = fetch_jwt(state.retriever, state.audience, state.principal)
    %State{state | expiry: updated_token.expiry, token: updated_token.token}
  end

  defp handle_expired_token(state) do
    updated_state = update_state_with_new_token(state)
    {:reply, updated_state.token, updated_state}
  end

  def current_token() do
    GenServer.call(__MODULE__, :current_token)
  end
end
