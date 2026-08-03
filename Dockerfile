FROM docker.io/library/caddy:2.10.2-alpine@sha256:d8c17a862962def15cde69863a3a463f25a2664942eafd7bdbf050e9c3116b83 AS caddy
FROM docker.io/xlrl/mantisbt:2.28.4@sha256:c8c7278daebab0fc5bfd0dbeab681a9e2830f77e70966095ca949506cced0ca1
USER root
COPY --from=caddy /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY entrypoint.sh /usr/local/bin/mantisbt-railway-entrypoint
RUN chmod +x /usr/local/bin/mantisbt-railway-entrypoint
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/mantisbt-railway-entrypoint"]
