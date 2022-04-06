
# nginx-proxy
Automated nginx proxy for Docker with maintenance page support based on jwilder nginx-proxy

## Explanation

The nginx.tmpl file contains the configuration to display a maintenance page if a container is not started.
The snippet below triggers if there is no specific configuration for a given host (e.g. if an application container in not started).
When the snippet triggers a 503 error is returned and finally the maintenance page will be shown.

```
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

## Usage of demo application

1. clone the repository
2. start docker-compose
3. copy the maintenance folder to `/usr/share/nginx/html` inside the nginx-proxy container (volume should be something like `/var/lib/docker/volumes/nginx-proxy_nginx_html`)
4. configure the environment variables (host name) of the demo application and start it.
5. if dns is configured properly your demo application should be reachable now
6. stop the demo application and check if maintenance page is shown

## Docker Image
You can find the built docker image on DockerHub:
https://hub.docker.com/r/deckweissgmbh/nginx-proxy

## Original project

https://github.com/nginx-proxy/nginx-proxy
