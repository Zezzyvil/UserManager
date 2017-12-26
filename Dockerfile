FROM node:9

WORKDIR /app

COPY ./webapp/package.json /app/package.json

RUN npm install

COPY ./webapp /app

EXPOSE 3000

CMD ["npm","start"]
