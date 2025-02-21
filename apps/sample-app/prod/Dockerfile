FROM node:23-alpine AS build

ENV TZ=Asia/Seoul
WORKDIR /app

COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm npm ci

COPY . .
RUN --mount=type=cache,target=/root/.npm npm run build

FROM node:23-alpine-slim

ENV TZ=Asia/Seoul
WORKDIR /app

COPY --from=build /app/dist .
COPY --from=build /app/package*.json ./

ENV NODE_ENV=production
EXPOSE 8080
CMD npm start