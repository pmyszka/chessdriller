FROM "node:alpine"

RUN apk add --no-cache openssl

WORKDIR /code

COPY package.json .

RUN npm install

COPY . .

RUN npx prisma db push && npm run build

EXPOSE 3123

CMD ["node", "server.js"]
