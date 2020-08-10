defmodule ReverseIap.TokenRetriever do
  alias GoogleApi.IAMCredentials

  alias IAMCredentials.V1.Model.{
    GenerateIdTokenRequest,
    GenerateIdTokenResponse
  }

  def token_for_audience(audience, target_principal) do
    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/cloud-platform")
    conn = IAMCredentials.V1.Connection.new(token.token)

    {:ok, %GenerateIdTokenResponse{token: token}} =
      IAMCredentials.V1.Api.Projects.iamcredentials_projects_service_accounts_generate_id_token(
        conn,
        "-",
        target_principal,
        body: %GenerateIdTokenRequest{audience: audience, includeEmail: true}
      )

    token
  end
end
