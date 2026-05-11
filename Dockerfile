FROM denoland/deno:alpine-1.37.0
WORKDIR /app
COPY . .
RUN deno cache main.ts
EXPOSE 5000
CMD ["run", "--allow-net", "--allow-env", "main.ts"]
