# Stage 1: Base Node image
FROM node:18-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm install -g @angular/cli@16
RUN npm install

# Stage 2: Development
FROM base AS development
EXPOSE 4200

# The following command is used to run the Angular app in development mode if you face 'heap out of memory' issue,
# since, on some machines the default memory limit is not enough for Angular CLI to run the app.
# 
# More details here: https://stackoverflow.com/questions/38558989/node-js-heap-out-of-memory?page=2&tab=modifieddesc#tab-top
# 
# --------------------------------------------
# CMD ["npm","run","start-container-max-memory"]
# --------------------------------------------
# About '--poll' inside the start-container-max-memory script in package.json:
# Used to detect changes in the container if you are using WSL backend for Docker

# If you don't face the 'heap out of memory' issue, you can use the following command:

# If you have WSL Backend for Docker:
# More details about WSL Backend for Docker: https://docs.docker.com/desktop/setup/install/windows-install/
# --------------------------------------------
CMD ["npm", "run", "start-container"]
# --------------------------------------------
# About '--poll' inside the start-container-max-memory script in package.json:
# Used to detect changes in the container if you are using WSL backend for Docker

# If your have Hyper-V Backend for Docker:
# More details about Hyper-V Backend for Docker: https://docs.docker.com/desktop/setup/install/windows-install/
# --------------------------------------------
# CMD ["ng", "serve", "--host", "0.0.0.0"]
# --------------------------------------------





# Stage 3: Build the Angular app for production
FROM base AS build
# Copy the rest of the application code
COPY . .
RUN ng build --configuration production

# Stage 4: Serve the app with Nginx
FROM nginx:alpine AS production
COPY --from=build /app/dist/samplefrontend /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]