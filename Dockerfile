FROM node:18-alpine

EXPOSE 3000

WORKDIR /app

COPY ./escom_hotel /app
