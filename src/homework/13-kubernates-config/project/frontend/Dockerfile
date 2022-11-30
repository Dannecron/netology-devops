FROM node:16-buster as builder

RUN mkdir /app

WORKDIR /app

COPY package.json /app/package.json
COPY package-lock.json /app/package-lock.json

RUN npm i

COPY . /app

RUN npm run build && rm -rf /app/node_modules

FROM nginx:latest

RUN mkdir /app
WORKDIR /app
COPY --from=builder /app/ /app

RUN mv /app/markup/* /app && rm -rf /app/markup

COPY demo.conf /etc/nginx/conf.d/default.conf
