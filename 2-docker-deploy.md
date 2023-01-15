# Deploy MoodleNet 3 Image

This step requires a built Docker image of MoodlenNet 3. This can either be locally-built image from [step 1](./1-create-docker-image.md) or use the already-build image name [`ponlawatw/moodlenet:3-20230114`](https://hub.docker.com/repository/docker/ponlawatw/moodlenet/general) from Docker Hub registry.

---

> ※ These steps might need to be superuser. Use command `$ su` to switch to super user, or start every command with `sudo`.

## Set up Network and Volumes

- **Network**: this deployment contains at least 2 containers needed to run which are ArangoDB and Moodlenet, and the two containers need to communicate which each other. Therefore, a configuration of a bridge network is required. [[See more]](https://docs.docker.com/network/)
- **Volume**: files in Docker containers will get removed / reset every time a container is disposed. To keep the data relevant to the deployment to persiste across containers life time, some particular directories in the containers need to be mounted to a Docker volume. [[See more]](https://docs.docker.com/storage/volumes/)

To create a Docker network, use [`docker network create`](https://docs.docker.com/engine/reference/commandline/network_create/) command.
```console
$ docker network create -d bridge moodlenet3
```
- `-d bridge` indicates the network driver type
- `moodlenet3` is the network name, which could be anything, but it must match when being used in the following commands.

To create a Docker volume, use [`docker volume create`](https://docs.docker.com/engine/reference/commandline/volume_create/) command.
```console
$ docker volume create arangodb_data
$ docker volume create moodlenet3_data
```
- In this deployment, two volumes need to be created for ArangoDB and MoodleNet3 respectively.
- The volume names are `arangodb_data`, and `moodlenet3_data` which can be changed to anything but they must match when being used in the following commands.

---

## Run ArangoDB

To run a container of ArangoDB from official image, use the following [`docker run`](https://docs.docker.com/engine/reference/commandline/run/) command:
```console
$ docker run -d -e ARANGO_NO_AUTH=1 -v arangodb_data:/var/lib/arangodb3 -p 8529:8529 --restart always --network moodlenet3 --name mn3_arangodb arangodb
```
- `docker run` is the command to run a container from an image.
- `-d` indicates the container to be *detached*, so it will run in the background. Closing the terminal session won't affect the container.
- `-e ARANGO_NO_AUTH=1` is ArangoDB-specific environment variable telling that no authentication is required to interact with the database.
- `-v arangodb_data:/var/lib/arangodb3` indicates that directory `/var/lib/arangodb3` inside the container, which is the directory to store the data of the database, will be mapped into the Docker volume name `arangodb_data` which was created from the previous step.
- `-p 8529:8529` indicates that port 8529 of the container will be exposed and mapped to port 8529 of the host machine.
- `--restart always` indicates that the container will always get restarted when it is terminated or encounting an error.
- `--network moodlenet3` indicates that the container is using network name `moodlenet3` which was created from the previous step.
- `--name mn3_arangodb` indicates the container name to be `mn3_arangodb`, this can also be anything but must match when being referred in the following steps.
- `arangodb` is the image name.

Use the command [`docker logs`](https://docs.docker.com/engine/reference/commandline/logs/) to check the latest logged message from the container, when `mn3_arangodb` is the container name:
```console
$ docker logs mn3_arangodb
```

Find the following text in the result message of `docker logs` command. If it exists, then the ArangoDB is now ready.
```
INFO {general} ArangoDB (version 3.10.1 [linux]) is ready for business. Have fun!
```

If the message does not exist, then it might still be busy initialising the data, try to run `docker logs` again to see the updates. But if there are error messages, there might be something wrong during the previous step. Try dispose all the resources using steps from the last section in this page and start again from the beginning.

---

## Run MoodleNet

Before running a container of MoodleNet3, it is necessary to overwrite the default configuration by creating a JSON file with the following content (file name can be any, but recommending `default.config.json`):
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
        "jsonTransport": true
      }
    },
    "@moodlenet/authentication-manager": {
      "rootPassword": "root"
    }
  }
}
```
The reason to create this file is that the default configuration will connect to ArangoDB using `http://localhost:8529`. However, in Docker deployment, ArangoDB is running in another container which will be accounted as a different machine than `localhost`. For this reason, it is necessary to change the config into `http://[ARANGODB_CONTAINER_NAME]:[ARANGODB_CONTAINER_PORT]` which in this case `http://arangodb:8529`.

After the configuration file is created, now it is ready to run a container of MoodleNet3 from either locally-built image or already-built image from Docker Hub registry, use the following [`docker run`](https://docs.docker.com/engine/reference/commandline/run/)  command:
```console
$ docker run -d -v PATH_TO_CONFIG_JSON:/root/default.config.json -v moodlenet3_data:/src/.dev-machines -e MOODLENET_CONFIG_FILE=/root/default.config.json -p 8080:8080 --restart always --network moodlenet3 --link mn3_arangodb:arangodb --name mn3_core ponlawatw/moodlenet:3-20230114
```
- `docker run` is the command to run a container from a Docker image.
- `-d` indicates to run the container *detachedly*, so it will run in the background and not get affected even working terminal session is closed.
- `-v PATH_TO_CONFIG_JSON:/root/default.config.json` (**※ PLEASE REPLACE `PATH_TO_CONFIG_JSON` to ABSOLUTE path in the host machine to the JSON configuration file**) indicates that JSON configuration file at `PATH_TO_CONFIG_JSON` in the host machine will be mounted into `/root/default.config.json` in the container.
- `-v moodlenet3_data:/src/.dev-machines` indicates that `/src/.dev-machines/` in the container will be mounted to Docker volume name `moodlenete3_data`.
- `-e MOODLENET_CONFIG_FILE=/root/default.config.json` is to configure environment variable name `MOODLENET_CONFIG_FILE` of the container, which tells MoodleNet to look for configuration file at the path `/root/default.config.json`. Notice that the path is mounted from local machine to the JSON configuration file created from the previous step.
- `-p 8080:8080` indicates port mapping of 8080 from the container to port 8080 of the host machine.
- `--restart always` indicates that the container will always get restarted when it is terminated or encounting an error.
- `--network moodlenet3` indicates that the container is using network name `moodlenet3` which was created from the previous step.
- `--link mn3_arangodb:arangodb` indicates that container name `mn3_arangodb`, which is ArangoDB, will be reached in this container in the name `arangodb`. (As `http://arangodb:8529` indicated in the JSON configuration file).
- `--name mn3_core` indicates the container name to be `mn3_core`, this can also be anything but must match when being referred in the following steps.
- `ponlawatw/moodlenet:3-20230114` is the name of Docker image to be run for this container. This can be different depends on the action from [the first step](./1-create-docker-image.md).

After run, use `docker logs` command to see the logged messages from the container:
```console
$ docker logs mn3_core
```
where `mn3_core` is the container name. If in the result of `docker logs` there is the following text, the MoodleNet should be now ready. Otherwise, it might still be busy initialising, wait for a while and repeat the `docker logs` command until the text is found (which could take up to few minutes):
```
webpack compiled
webpack compiler done ... exited with signal 0
```
If webpack complier done but not exited with signal `0`, please try again, if it still not exited with signal `0`, please try [this additional step of directly bind built webapp into the container](./2-bind-webapp.md).

However, if there are any other error messages, there might be something wrong during the previous step. Try dispose all the resources using steps from the last section in this page and start again from the beginning.

To test locally if MoodleNet is up, use the command `curl` to check the response from the port 8080.
```console
$ curl http://localhost:8080
```
Expected the result from `curl` to be some HTML text looking like this:
```html
<!doctype html><html lang="en"><head><meta charset="utf-8"/><link rel="preconnect" href="https://fonts.googleapis.com"/><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/><link rel="icon" href="/favicon.svg"/><link rel="mask-icon" href="/mask-favicon.svg" color="#f88012"/><link rel="apple-touch-icon" href="/apple-touch-icon.png"/><meta name="viewport" content="width=device-width,initial-scale=1"/><link rel="apple-touch-icon" href="/logo192.png"/><link rel="manifest" href="/manifest.json"/><title>MoodleNet</title><link rel="icon" href="/favicon.svg"><script defer="defer" src="/runtime.825cc17b79d6f925436b.bundle.js"></script><script defer="defer" src="/vendors.92c647cd7ad07a0c803b.bundle.js"></script><script defer="defer" src="/main.2c9b1b16cb19948b2085.bundle.js"></script></head><body><section id="root"></section></body></html>
```

---

## Dispose the deployment

To stop the containers use the command [`docker stop CONTAINER_NAME`](https://docs.docker.com/engine/reference/commandline/stop/) for stopping MoodleNet and/or ArangoDB containers respectively:
```console
$ docker stop mn3_core
$ docker stop mn3_arangodb
```

To resume the stopped containers, use the command [`docker start CONTAINER_NAME`](https://docs.docker.com/engine/reference/commandline/start/):
```console
$ docker start mn3_core
$ docker start mn3_arangodb
```

To remove the stopped containers, use the command [`docker rm CONTAINER_NAME`](https://docs.docker.com/engine/reference/commandline/rm/):
```console
$ docker rm mn3_core
$ docker rm mn3_arangodb
```
※ To restart a removed container, one must use `docker run` command with all the proper options arguments from the previous step.

To remove the volumes, use the command [`docker volume rm VOLUME_NAME`](https://docs.docker.com/engine/reference/commandline/volume_rm/)
```console
$ docker volume rm moodlenet3_data
$ docker volume rm arangodb_data
```

To remove the network, use the command [`docker network rm NETWORK_NAME`](https://docs.docker.com/engine/reference/commandline/network_rm/)
```console
$ docker network rm moodlenet3
```

---
