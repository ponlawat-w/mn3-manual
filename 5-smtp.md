# Setting up SMTP Configuration for MoodleNet

This is to set up SMTP configuration for MoodleNet.

> ※ These steps might need to be superuser. Use command `$ su` to switch to super user, or start every command with `sudo`.

---

Before starting, it is required to have SMTP credentials which can be get from Amazon SES.

---

1. Access ArangoShell through Docker:
```console
$ docker exec -it mn3_arangodb arangosh
```

2. If prompted for password, leave empty and press enter.

3. Switch database to `at__moodlenet__email-service`.
```console
> db._useDatabase('at__moodlenet__email-service')
```

4. Update entry by using the following command:

```console
> db._update(db._collection('Moodlenet_simple_key_value_store').firstExample('_key', 'mailerCfg::'), { value: { defaultFrom: 'SENDER_ADDRESS', defaultReplyTo: 'SENDER_ADDRESS' } })
```
by replacing `SENDER_ADDRESS` in the command to be the sender address (e.g. noreply@domain).

5. Edit configuration json file replace the object `nodemailerTransport` in `@moodlenet/email-service` to be the following and replace the value parameters:
```json
{
  "host": "SMTP_HOST",
  "secure": true,
  "auth": {
    "user": "SMTP_USER",
    "pass": "SMTP_PASS"
  }
}
```
Final configuration json file should look like this:
```json
{
  "pkgs": {
    "@moodlenet/core": {
      "npm_config_registry": "https://registry.npmjs.org/"
    },
    "@moodlenet/arangodb": {
      "connectionCfg": {
        "url": "http://arangodb:8529"
      }
    },
    "@moodlenet/http-server": {
      "port": 8080
    },
    "@moodlenet/email-service": {
      "nodemailerTransport": {
        "host": "SMTP_HOST",
        "secure": true,
        "auth": {
          "user": "SMTP_USER",
          "pass": "SMTP_PASS"
        }
      }
    },
    "@moodlenet/authentication-manager": {
      "rootPassword": "root"
    }
  }
}
```

6. Restart the MoodleNet container.

---

If SMTP configuration is not successful and emails are not received, MoodleNet should log the error messages which can be seen by using the command:
```console
$ docker logs mn3_core
```

---
