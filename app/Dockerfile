# image being used is node:23-alpine
FROM node@sha256:a34e14ef1df25b58258956049ab5a71ea7f0d498e41d0b514f4b8de09af09456 AS builder

WORKDIR /app

COPY package*.json ./

# installs the dependencies
RUN npm install

COPY . .

# makes the application production-ready and stores fils in the /dist directory
RUN npm run build


# Verified provider docker image that is more secure than the original as it runs as non-root
# image being used is nginxinc/nginx-unprivileged:1.27-alpine-slim
FROM node@sha256:ec6b8b1f1bfa594db13e99fc692b9fb816cb7e365927196610f622659de95913


# allows to run the image as a non-root user
RUN sed -i '/^pid/d' /etc/nginx/nginx.conf
RUN echo "pid /tmp/nginx.pid;" >> /etc/nginx/nginx.conf

# copies the production-ready files to the nginx directory
COPY --from=builder /app/dist /usr/share/nginx/html