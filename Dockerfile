FROM node:16

WORKDIR /
RUN git clone https://gitlab.com/moodlenet/moodlenet.git src

WORKDIR /src
RUN npm install
RUN npm run dev-install-backend default-dev

CMD [ "npm", "run", "dev-start-backend", "default-dev" ]
