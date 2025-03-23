
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
    "ConnectionStrings:Docker-Database": "Host=database;Port=5432;Database=sample_database;Username=postgres;Password=mysecretpassword;",
    "ConnectionStrings:Database": "Host=localhost;Port=5432;Database=sample_database;Username=sa_ss;Password=dev.123;"
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
```

```powershell
docker run --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -p 5500:5432 -v .\seed_script.sql:/docker-entrypoint-initdb.d/seed_script.sql -d postgres:14
```
