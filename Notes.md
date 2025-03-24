
```powershell
ng new samplefrontend
npm i
ng generate environment

dotnet new sln
dotnet new webapi --use-controllers --no-openapi --framework net8.0 --use-program-main --output primarybackendservice
dotnet new webapi --use-controllers --no-openapi --framework net8.0 --use-program-main --output secondarybackendservice

dotnet sln add .\primarybackendservice\ 
dotnet sln add .\secondarybackendservice\ 

dotnet new gitignore

dotnet new classlib -f net8.0 --name workhelpers
dotnet sln add .\workhelpers\

dotnet add .\primarybackendservice\primarybackendservice.csproj reference .\workhelpers\workhelpers.csproj
dotnet add .\secondarybackendservice\secondarybackendservice.csproj reference .\workhelpers\workhelpers.csproj
     
dotnet user-secrets init  
dotnet user-secrets set "ConnectionStrings:Database" "Host=localhost;Port=5432;Database=sample_database;Username=sa_ss;Password=dev.123;"


dotnet add package Microsoft.EntityFrameworkCore.Sqlite --version 8.0.13

# Inside workhelpers
dotnet ef migrations add InitialCreate --startup-project ..\anotherbackendservice\anotherbackendservice.csproj

dotnet ef migrations script --startup-project ..\primarybackendservice\primarybackendservice.csproj
# OR
dotnet ef database update --startup-project ..\primarybackendservice\primarybackendservice.csproj

```

https://stenbrinke.nl/blog/configuration-and-secret-management-in-dotnet/


Now after initializing docker in the project, we look at launchsettings.json file and describe its changes.

AFter looking at launch settings let's examine the csproj file. Only one detail, of target being llinux is added there
currently. Now we will look at the docker file. 

It has the APP_UID non root user. Here is the reasoning why:
[Andrew Lock's article](https://andrewlock.net/exploring-the-dotnet-8-preview-updates-to-docker-images-in-dotnet-8/)

``` json

{
  //"ConnectionStrings:Docker-Database": "Host=database;Port=5432;Database=sample_database;Username=postgres;Password=mysecretpassword;",
  "ConnectionStrings:Docker-Database": "Host=host.docker.internal;Port=5500;Database=sample_database;Username=postgres;Password=mysecretpassword;",
}

    "Container (Dockerfile)": {
      "commandName": "Docker",
      "launchUrl": "{Scheme}://{ServiceHost}:{ServicePort}/weatherforecast",
      "launchBrowser": false,
      "environmentVariables": {
        "ASPNETCORE_HTTPS_PORTS": "8081",
        "ASPNETCORE_HTTP_PORTS": "8080"
      },
      "publishAllPorts": true,
      "useSSL": true,
      "httpPort": 5058,
      "sslPort": 7111
    },


        "Container (Dockerfile)": {
      "commandName": "Docker",
      "launchUrl": "{Scheme}://{ServiceHost}:{ServicePort}/weatherforecast",
      "launchBrowser": false,
      "environmentVariables": {
        "ASPNETCORE_HTTPS_PORTS": "8081",
        "ASPNETCORE_HTTP_PORTS": "8080"
      },
      "publishAllPorts": true,
      "useSSL": true,
      "httpPort": 5264,
      "sslPort": 7046
    }
```

Postgresql docker commands:
```powershell

docker run --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -p 5500:5432 -v .\seed_script.sql:/docker-entrypoint-initdb.d/seed_script.sql -d postgres:14

docker exec \-it my\_postgres psql \-U postgres
```

```powershell

docker run -dt 
-v "C:\Users\muhammad.anas\vsdbg\vs2017u5:/remote_debugger:rw"

-v "C:\Users\muhammad.anas\AppData\Roaming\Microsoft\UserSecrets:/root/.microsoft/usersecrets:ro"
-v "C:\Users\muhammad.anas\AppData\Roaming\Microsoft\UserSecrets:/home/app/.microsoft/usersecrets:ro"
-v "C:\Users\muhammad.anas\AppData\Roaming\ASP.NET\Https:/root/.aspnet/https:ro" 
-v "C:\Users\muhammad.anas\AppData\Roaming\ASP.NET\Https:/home/app/.aspnet/https:ro" 

-v "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Sdks\Microsoft.Docker.Sdk\tools\linux-x64\net8.0:/VSTools:ro" 
-v "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\HotReload:/HotReloadAgent:ro" 
-v "D:\Spare\sample-docker\services\primarybackendservice:/app:rw" 
-v "D:\Spare\sample-docker\services:/src/:rw" 
-v "C:\Users\muhammad.anas\.nuget\packages:/.nuget/fallbackpackages2:rw" 
-v "C:\Program Files (x86)\Microsoft Visual Studio\Shared\NuGetPackages:/.nuget/fallbackpackages:rw" 
-e "ASPNETCORE_LOGGING__CONSOLE__DISABLECOLORS=true"

-e "ASPNETCORE_ENVIRONMENT=Development" 
-e "ASPNETCORE_HTTPS_PORT=7111" 

-e "DOTNET_USE_POLLING_FILE_WATCHER=1" 
-e "NUGET_PACKAGES=/.nuget/fallbackpackages2" 
-e "NUGET_FALLBACK_PACKAGES=/.nuget/fallbackpackages;/.nuget/fallbackpackages2" 

-p 5058:8080
-p 7111:8081

-l "com.microsoft.visualstudio.launch-url.path-query=/weatherforecast" 
-P

--name primarybackendservice 
--entrypoint dotnet primarybackendservice:dev 
--roll-forward Major /VSTools/DistrolessHelper/DistrolessHelper.dll --wait 
813b129a5e37e2319440746bb27c1825d0970542fbf8a51ab68d36da2249b3ef


```


```yml
  
  database:
    image: ${DOCKER_REGISTRY-}datbase
    build:
      context: .
      dockerfile: database.Dockerfile
    environment:
     # - POSTGRES_DB=sample_database
     # - POSTGRES_USER=postgres
     - POSTGRES_PASSWORD=mysecretpassword
    volumes:
     - ./container-storage/pg_data:/var/lib/postgresql/data
     # - my_new_pg_data:/var/lib/postgresql/data
    ports:
     - 5500:5432
```

database.Dockerfile
```yml
FROM postgres:14
COPY seed_script.sql /docker-entrypoint-initdb.d/
```

Change the user secrets again:
```json
 //"ConnectionStrings:Docker-Database": "Host=host.docker.internal;Port=5500;Database=sample_database;Username=postgres;Password=mysecretpassword;",
 "ConnectionStrings:Docker-Database": "Host=database;Port=5432;Database=sample_database;Username=postgres;Password=mysecretpassword;"
```
Possible Angular docker cli commands:
```powershell
docker build --target development -t samplefrontend .
docker run -p 4200:4200 -v $(pwd):/app -v samplefrontend_nodemodules:/app/node_modules samplefrontend
```

Angular Dockerfile:
```dockerfile
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
```

```yml
services:
  samplefrontend:
    image: ${DOCKER_REGISTRY-}samplefrontend
    build:
      context: .
      target: development
      dockerfile: Dockerfile
    ports:
      - "4200:4200"
    volumes:
      - .:/app
      - samplefrontend_nodemodules:/app/node_modules

volumes:
  samplefrontend_nodemodules:
```