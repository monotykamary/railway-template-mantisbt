FROM docker.io/library/caddy:2.11.4-alpine@sha256:5f5c8640aae01df9654968d946d8f1a56c497f1dd5c5cda4cf95ab7c14d58648 AS caddy
FROM docker.io/xlrl/mantisbt:2.28.4@sha256:c8c7278daebab0fc5bfd0dbeab681a9e2830f77e70966095ca949506cced0ca1
USER root
COPY --from=caddy /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY entrypoint.sh /usr/local/bin/mantisbt-railway-entrypoint
RUN chmod +x /usr/local/bin/mantisbt-railway-entrypoint
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/mantisbt-railway-entrypoint"]
