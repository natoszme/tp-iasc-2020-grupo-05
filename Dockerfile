FROM elixir:1.10.3 as builder
ARG PORT

COPY . .

RUN mix local.hex --force && \
    mix local.rebar --force

RUN export MIX_ENV=prod && \
    rm -Rf _build && \
    mix deps.get && \
    mix release

EXPOSE $PORT
ENV PORT=$PORT

ENTRYPOINT ["_build/prod/rel/automatic_auctions/bin/automatic_auctions"]
CMD ["start"]
