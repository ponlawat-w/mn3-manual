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
> db._update(db._collection('Moodlenet_simple_key_value_store').firstExample('_key', 'mailerCfg::'), { value: { defaultFrom: 'SENDER_ADDRESS', defaultReplyTo: 'SENDER_ADDRESS', transport: { host: 'SMTP_HOST', secure: true, auth: { user: 'SMTP_USER', pass: 'SMTP_PASS' } } } })
```
and replacing the following values in the command:
- `SENDER_ADDRESS` to be the email address of the sender (e.g. noreply@domain)
- `SMTP_HOST` to be the SMTP host 
- `SMTP_USER` to be the SMTP username
- `SMTP_PASS` to be the SMTP password

---

If SMTP configuration is not successful and emails are not received, MoodleNet should log the error messages which can be seen by using the command:
```console
$ docker logs mn3_core
```

---
