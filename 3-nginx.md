# Setting up Reverse Proxy to nginx

To set up reverse proxy from external connection to MoodleNet container, firstly, we need to make sure that MoodleNet Docker container is running on a port (e.g. 8080).

> ※ These steps might need to be superuser. Use command `$ su` to switch to super user, or start every command with `sudo`.

1. Navigate to nginx available sites directory
```console
$ cd /etc/nginx/sites-available
```

2. Create a new file with any name (e.g. `moodlenet`), with the following content
```nginx
server {
    listen      80;
    server_name DOMAIN_NAME;

    location / {
        proxy_set_header    X-Forwarded-By       $server_addr:$server_port;
        proxy_set_header    X-Forwarded-For      $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto    $scheme;
        proxy_set_header    Host                 $host;
        proxy_set_header    X-Real-IP            $remote_addr;
        proxy_pass          http://127.0.0.1:8080/;
    }
}
```
by replacing `DOMAIN_NAME` with the domain name without `http://` nor `https://`. And to make sure that URL after `proxy_pass` is going to port binded by MoodleNet container.

3. Navigate to nginx enabled sites directory
```console
$ cd /etc/nginx/sites-enabled
```

4. Create symbolic link from `sites-available` directory to `sites-enabled` directory by providing the absolute path:
```console
$ ln -s /etc/nginx/sites-available/FILE_NAME /etc/nginx/sites-enabled/FILE_NAME
```

5. Test configuration file:
```console
$ nginx -t
```

6. If returned message is "test is successful", then reload the config.
```console
$ nginx -s reload
```

7. Try access the domain via browser.

---
