# Directly Bind Build WebApp

If MoodleNet was not successful in building webpack, you can use the one that already sucessfully built from another machine.

1. Clone the following GitHub repository to the server.
```console
$ git clone https://github.com/ponlawat-w/mn3-latest-build.git
```

2. In the `docker run` command of MoodleNet3 from [the step 2](./2-docker-deploy.md), add the following mount option after any option:
```console
-v PATH_TO_CLONED_REPOSITORY:/src/packages/react-app/latest-build
```
by replacing `PATH_TO_CLONED_REPOSITORY` to **absolute path** of the directory that was recently cloned from github.

The full `docker run` command should look like this:
```console
$ docker run -d -v PATH_TO_CONFIG_JSON:/root/default.config.json -v PATH_TO_CLONED_REPOSITORY:/src/packages/react-app/latest-build -v moodlenet3_data:/src/.dev-machines -e MOODLENET_CONFIG_FILE=/root/default.config.json -p 8080:8080 --restart always --network moodlenet3 --link mn3_arangodb:arangodb --name mn3_core ponlawatw/moodlenet:3-20230114
```

---
