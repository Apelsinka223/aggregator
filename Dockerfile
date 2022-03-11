# Elixir Destiller
FROM elixir:1.11-alpine as build

ARG MIX_ENV=prod
ARG SECRET_KEY_BASE="dB1owF86MT4gpkDMZClYHXAiZmq8Qo0ze8Lh7TuSd+vvMVGaw3lYeMbxM969GqGN"
ARG PORT
ARG HOST
ENV MIX_ENV $MIX_ENV
ENV PORT $PORT
ENV HOST $HOST
ENV SECRET_KEY_BASE $SECRET_KEY_BASE

WORKDIR /app/
COPY . .

RUN apk add --no-cache build-base inotify-tools

RUN mix local.rebar --force && \
    mix local.hex --force && \
    mix deps.get && \
    mix deps.clean mime --build

RUN cd /app && mix compile
RUN mix release

# Elixir bulb
FROM elixir:1.11-alpine
ARG MIX_ENV=prod
ARG PORT
ARG HOST
ARG NDC_BA_URL
ARG NDC_BA_TOKEN
ARG NDC_AFKLM_URL
ARG NDC_AFKLM_TOKEN
ENV MIX_ENV $MIX_ENV
ENV PORT $PORT
ENV HOST $HOST
ENV SECRET_KEY_BASE $SECRET_KEY_BASE
ENV NDC_BA_URL $NDC_BA_URL
ENV NDC_BA_TOKEN $NDC_BA_TOKEN
ENV NDC_AFKLM_URL $NDC_AFKLM_URL
ENV NDC_AFKLM_TOKEN $NDC_AFKLM_TOKEN
# Add Tini
ENV TINI_VERSION v0.18.1

RUN apk add --no-cache bash openssl tini

COPY --from=build ./app/_build/$MIX_ENV/rel/aggregator .

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["sh","-c", "bin/aggregator start"]
