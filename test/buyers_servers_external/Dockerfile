FROM node:13
COPY package*.json ./
RUN npm i
COPY . .
CMD "node buyer_server.js"