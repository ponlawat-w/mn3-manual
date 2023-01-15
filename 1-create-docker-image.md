# Create MoodleNet 3 Docker Image

This step is optional. You can use already built image [`ponlawatw/moodlnet:3-20230114`](https://hub.docker.com/repository/docker/ponlawatw/moodlenet/general) in Docker Hub.

This step will guide and provide description of steps to create a Docker image of MoodleNet 3 that will be used in the deployment.

1. Create an empty directory.
2. Create a file name `Dockerfile` without extension in the directory with following content:

```Dockerfile
FROM node:16

WORKDIR /
RUN git clone https://gitlab.com/moodlenet/moodlenet.git src

WORKDIR /src
RUN npm install
RUN npm run dev-install-backend default-dev

CMD [ "npm", "run", "dev-start-backend", "default-dev" ]
```

3. Run the following commmand, replacing `IMAGE_NAME` with the name of the image to be created:
```console
$ docker build -t IMAGE_NAME .
```
For example, create a new image name `moodlenet` with tag `3`:
```console
$ docker build -t moodlenet:3 .
```

[See here](https://docs.docker.com/engine/reference/commandline/build/) for more information about building a Docker image.

4. If the build of Docker image is done in the machine which will host MoodleNet, it is not necessary to push the image into Docker registry. But in the case that Docker image is built in a different machine with the one will host the site, Docker image must be pushed into Docker hub registry and will be pulled by the one that will host the site.

5. To push the Docker image into [Docker hub registry](http://hub.docker.com/), firstly, rename the image using `docker tag` command to include Docker hub username (registration is required).
```console
$ docker tag ORIGINAL_IMAGE_NAME USERNAME/NEW_IMAGE_NAME
```
For example, the image name that was built locally was `moodlenet:3` and to push it into Docker hub of username `ponlawatw`:
```console
$ docker tag moodlenet:3 ponlawatw/moodlenet:3
```

6. Use `docker push` command to push the image into the registry
```console
$ docker push USERNAME/IMAGE_NAME
```
For exmaple:
```console
$ docker push ponalwatw/moodlenet:3
```

---

## Dockerfile Description

This section describes the command in the file `Dockerfile`.

```Dockerfile
FROM node:16
```
This image is based on `node:16` image.

```Dockerfile
WORKDIR /
RUN git clone https://gitlab.com/moodlenet/moodlenet.git src
```
Go to base directory `/` and clone MoodlenNet source code into folder `/src`

```Dockerfile
WORKDIR /src
```
Set working directory to `/src` which is the source code just being pulled from GitLab.

```Dockerfile
RUN npm install
```
Install dependencies of MoodleNet.

```Dockerfile
RUN npm run dev-install-backend default-dev
```
Create a development environment name `default-dev`, the name can be something else.

```Dockerfile
CMD [ "npm", "run", "dev-start-backend", "default-dev" ]
```
Set the initial command of the image to be `npm run dev-start-backend default-dev`, which `default-dev` is the name of development environment created from the previous step, so they shoud match.

---
