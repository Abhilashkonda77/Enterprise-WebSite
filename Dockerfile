FROM nginx:alpine

# Copy custom nginx config (THIS IS CRITICAL)
COPY nginx.conf /etc/nginx/nginx.conf

# Copy website files
COPY . /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
