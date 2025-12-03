FROM node:20-alpine

WORKDIR /app

# Copiar package.json desde proyecto-notas/app
COPY proyecto-notas/app/package*.json ./

# Instalar dependencias
RUN npm install --only=production

# Copiar código fuente
COPY proyecto-notas/app/src ./src

# Exponer puerto
EXPOSE 3000

# Start command
CMD ["node", "src/app.js"]
