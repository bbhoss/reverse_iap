# ReverseIAP

ReverseIAP is a tool for exposing a preauthenticated tunnel to an endpoint protected
by Google Cloud's [Identity-Aware Proxy](https://cloud.google.com/iap). This is most
useful for wrapping third party services that have clients that aren't built with
connecting through IAP in mind. It is primarily designed to be used as a [sidecar container](https://docs.microsoft.com/en-us/azure/architecture/patterns/sidecar)
that a sibling container will treat as an API endpoint. _Make sure that you trust anything
with network access to ReverseIAP, as it will have unfettered access the service on the
other end._

# Running
To run ReverseIap, you can use the prebuilt docker image `bbhoss/reverse_iap`. Make sure you
set the following environment variables when starting the container.

  * `TARGET_AUDIENCE` - set this to the OAuth2 client audience for the client you're using with IAP
  * `TARGET_PRINCIPAL` - Service account email address that the default credentials provide `roles/iam.serviceAccountTokenCreator` access, see [IAM Setup](#iam-setup)
  * `UPSTREAM_URL` - The URL you want to proxy requests to, this is where IAP will be listening.
  * `GCLOUD_PROJECT` - Project where you've enabled the [iamcredentials api](https://console.developers.google.com/apis/library/iamcredentials.googleapis.com). This will default to the project your code is running in, if ReverseIAP has access to a metadata server. Notably, it is not automatically detected when using Application-Default Credentials, so it must be set if you are authenticating that way.
  * `GOOGLE_APPLICATION_CREDENTIALS` - This may be optionally configured to allow for running ReverseIAP under
    credentials of your choice. By default, ReverseIAP will try to use the credentials available via GKE, GCE, or Application-Default Credentials configured with the gcloud sdk.

  # IAM Setup
  IAM needs to be setup for ReverseIAP to work. The application default credentials need to provide
  `roles/iam.serviceAccountTokenCreator` to `TARGET_PRINCIPAL`, the service account that will be used to access the service (which could be identical to IAP, but must be a service account).
  `TARGET_PRINCIPAL` will also need to `roles/iam.serviceAccountTokenCreator` role granted on
  itself, in order for tokens to be generated.