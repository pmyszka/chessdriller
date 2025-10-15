FROM node:alpine

RUN apk add --no-cache openssl

WORKDIR /code

COPY package.json .
RUN npm install

COPY . .

RUN npx prisma generate
RUN npm run build

# Copy the init script to run migrations at container startup
COPY bin/init-db.sh /usr/local/bin/init-db.sh
RUN chmod +x /usr/local/bin/init-db.sh

EXPOSE 3123

ENTRYPOINT ["/usr/local/bin/init-db.sh"]
CMD ["node", "server.js"]
