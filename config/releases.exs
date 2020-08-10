import Config

config :reverse_iap, :audience, System.fetch_env!("TARGET_AUDIENCE")
config :reverse_iap, :principal, System.fetch_env!("TARGET_PRINCIPAL")
config :reverse_iap, :upstream_url, System.fetch_env!("UPSTREAM_URL")
