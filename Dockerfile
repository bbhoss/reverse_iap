# ---- Build Stage ----
FROM elixir:1.10 AS app_builder

# Set environment variables for building the application
ENV MIX_ENV=prod \
    TEST=1 \
    LANG=C.UTF-8

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Create the application build directory
RUN mkdir /app
WORKDIR /app

# Set default environment variables so compile doesn't explode
ENV TARGET_AUDIENCE snip.apps.googleusercontent.com
ENV TARGET_PRINCIPAL sa-name@project-id.iam.gserviceaccount.com
ENV UPSTREAM_URL http://localhost:3033

# Copy over all the necessary application files and directories
COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY mix.exs .
COPY mix.lock .

# Fetch the application dependencies and build the application
RUN mix deps.get
RUN mix deps.compile
RUN mix release

# ---- Application Stage ----
FROM debian:buster AS app

ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y openssl && apt-get dist-upgrade -y

# Copy over the build artifact from the previous step and create a non root user
RUN useradd --create-home app
WORKDIR /home/app
COPY --from=app_builder /app/_build .
RUN mkdir -p /home/app/prod/rel/reverse_iap/tmp && chown -R app: ./prod && chmod 755 -R /home/app/prod
USER app

# Run the Phoenix app
CMD ["./prod/rel/reverse_iap/bin/reverse_iap", "start"]