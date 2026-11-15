FROM docker.io/library/caddy:2.11.9-alpine@sha256:003a97808e781aa9f7e75cc2f43d34d461099031faf5e20faefb9f61126836f0 AS caddy
FROM docker.io/xlrl/mantisbt:2.28.4@sha256:c8c7278daebab0fc5bfd0dbeab681a9e2830f77e70966095ca949506cced0ca1
USER root
COPY --from=caddy /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY entrypoint.sh /usr/local/bin/mantisbt-railway-entrypoint
RUN chmod +x /usr/local/bin/mantisbt-railway-entrypoint
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/mantisbt-railway-entrypoint"]
