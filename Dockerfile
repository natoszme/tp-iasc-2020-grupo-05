FROM elixir:1.10.3 as builder
ARG PORT

# prepare build dir
# RUN mkdir /app 
# WORKDIR /app


RUN mkdir /app && chown -R nobody: /app
WORKDIR /app

#Copy the source folder into the Docker image
COPY . .

RUN mix local.hex --force && \
    mix local.rebar --force

#Install dependencies and build Release
RUN export MIX_ENV=prod && \
    rm -Rf _build && \
    mix deps.get && \
    mix release

# #Extract Release archive to /rel for copying in next stage
# RUN APP_NAME="automatic_auctions" && \
#     RELEASE_DIR=`ls -d _build/prod/rel/$APP_NAME/releases/*/` && \
#     mkdir /export && \
#     tar -xf "$RELEASE_DIR.tar.gz" -C /export

# #Copy and extract .tar.gz Release file from the previous stage
# COPY --from=builder /export/ .

# #Set environment variables and expose port
# EXPOSE $PORT
# ENV PORT=$PORT

# #Change user
# USER default

# #Set default entrypoint and command
# ENTRYPOINT ["/opt/app/bin/MY_APP_NAME"]

# prepare release image
FROM elixir:1.10.3
#RUN apk add --update bash openssl

RUN mkdir /app && chown -R nobody: /app
WORKDIR /app
USER nobody

COPY --from=builder /app/_build/prod/rel/automatic_auctions ./

EXPOSE $PORT
ENV PORT=$PORT

ENTRYPOINT ["/app/bin/automatic_auctions"]
CMD ["start"]

# docker container run -e "PORT=9001" -v $PWD:/data -w /data -it elixir:1.10.3 mix deps.get && iex --sname a -S mix run lib/automaticAuctions.ex