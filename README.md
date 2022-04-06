# nginx-proxy
Automated nginx proxy for Docker with maintenance page support based on jwilder nginx-proxy

# Explanation

The nginxt.tmpl file contains the configuration to dispaly a maintenance page if a container is not started:

```
{{ $enable_ipv6 := eq (or ($.Env.ENABLE_IPV6) "") "true" }}
server {
        server_name _; # This is just an invalid value which will never trigger on a real hostname.
        server_tokens off;
        listen {{ $external_http_port }};
        {{ if $enable_ipv6 }}
        listen [::]:{{ $external_http_port }};
        {{ end }}
        {{ $access_log }}

        location / {
                {{ if eq $external_https_port "443" }}
                return 301 https://$host$request_uri;
                {{ else }}
                return 301 https://$host:{{ $external_https_port }}$request_uri;
                {{ end }}
        }
}

{{ if (and (exists "/etc/nginx/certs/default.crt") (exists "/etc/nginx/certs/default.key")) }}
server {
        server_name _; # This is just an invalid value which will never trigger on a real hostname.
        server_tokens off;
        listen {{ $external_https_port }} ssl http2;
        {{ if $enable_ipv6 }}
        listen [::]:{{ $external_https_port }} ssl http2;
        {{ end }}
        {{ $access_log }}

        error_page 503 /503.html;
        location ~ ^/(503.html|maintenance_assets) {
                root /usr/share/nginx/html/maintenance;
        }

        location / {
                return 503;
        }

        ssl_session_cache shared:SSL:50m;
        ssl_session_tickets off;
        ssl_certificate /etc/nginx/certs/$ssl_server_name/cert.pem;
        ssl_certificate_key /etc/nginx/certs/$ssl_server_name/key.pem;
}
{{ end }}

```
