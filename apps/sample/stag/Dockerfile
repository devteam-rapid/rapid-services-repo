FROM node:23 AS build

ENV TZ=Asia/Seoul
WORKDIR /app

COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm npm install

COPY . .
RUN --mount=type=cache,target=/root/.npm npm run build

FROM node:23-slim

ENV TZ=Asia/Seoul
WORKDIR /app

COPY --from=build /app/dist .
COPY --from=build /app/package*.json ./

ENV NODE_ENV=staging
EXPOSE 3000
CMD npm start