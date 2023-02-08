# Setting up HTTPS using Let's Encrypt and Certbot

This is to setup secured HTTP by using certificate from Let's Encrypt and Certbot.

> ※ These steps might need to be superuser. Use command `$ su` to switch to super user, or start every command with `sudo`.

---

Use the following command to obtain a new certificate for domain:
```shell
certbot --nginx --nginx-ctl /usr/sbin/nginx -d DOMAIN_NAME
```
By replacing `DOMAIN_NAME` with the domain name to get SSL certificate, without prefixing `http://` nor `https://`.

---

To renew certificate, use crontab for the following command:

```shell
certbot renew
```

---
