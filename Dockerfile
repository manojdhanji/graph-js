# -----------------------------
# 1. Build Stage
# -----------------------------
FROM node:18-alpine AS build

WORKDIR /app

# Install dependencies (cached)
COPY package*.json ./
RUN npm install

# Copy source
COPY . .

# Build for production
RUN npm run build


# -----------------------------
# 2. Production Stage (Nginx)
# -----------------------------
FROM nginx:1.25-alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy dist from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Optional: custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
