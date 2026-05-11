FROM denoland/deno:alpine-1.37.0
WORKDIR /app
COPY . .
# Hii itatafuta na kuwasha faili lako popote lilipo
CMD ["sh", "-c", "find . -name main.ts -exec deno run --allow-net --allow-env {} +"]
 
 
