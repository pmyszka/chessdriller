FROM node:alpine

RUN apk add --no-cache openssl

WORKDIR /code

COPY package.json ./
COPY prisma ./prisma
RUN npm install

COPY . .

RUN npm run build

COPY scripts/init-db.sh /usr/local/bin/init-db.sh
RUN chmod +x /usr/local/bin/init-db.sh

EXPOSE 3123

ENTRYPOINT ["/usr/local/bin/init-db.sh"]
CMD ["node", "server.js"]
