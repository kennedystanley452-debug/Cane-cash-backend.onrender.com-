FROM denoland/deno:alpine-1.37.0
WORKDIR /app
COPY . .
# Hii itaingia ndani ya folda lako moja kwa moja
WORKDIR /app/Secure_Payment_Integration_System
RUN deno cache main.ts
EXPOSE 5000
CMD ["run", "--allow-net", "--allow-env", "main.ts"]
 
 
