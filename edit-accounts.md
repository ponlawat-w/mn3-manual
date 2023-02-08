# Editing accounts in database

## Update password

To directly update password in database, follow the following steps:

1. Access ArangoShell through Docker:
```shell
docker exec -it mn3_arangodb arangosh
```

2. If prompted for password, leave empty and press enter.

3. Switch database to `at__moodlenet__simple-email-auth` using the following command:
```js
db._useDatabase('at__moodlenet__simple-email-auth')
```

4. Update user entry by the following command:
```js
db._update(db._collection('User').firstExample('email', 'EMAIL_ADDRESS'), { password: 'NEW_PASSWORD' })
```
by replacing `EMAIL_ADDRESS` to a registered email address and `NEW_PASSWORD` to be new password of the user.
