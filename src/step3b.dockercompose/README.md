# Step 3b - Docker-Compose

Making it actually work in docker.

In [step 1](../step1.normal/README.md), we created a classic 3 tier application: front end in ASP.Net Core MVC, a back end in ASP.Net Core Web Api and a Sql Database project.  
In [step 2](../step2.docker/README.md), we dockerized our 3 tier app, so instead of running the apps in it's normal environment (kestrel or IIS Express), the apps will run in a Docker container.  
The problem we quickly found out is that inter container communication is not easy.  
In step 3, docker-compose will(I hope, well that's the plan) bridge the gap of inter container communication.

## docker-composing

Our story picks up at the end of step2.docker.  I copied step2.docker to step3b.dockercompose

- Open the sln in Visual Studio 2019
- Right click febedb.frontend project > add > Container Orchestration Support
  - Container orchestrator: select "Docker compose", next,
  - Target OS: Linux

A new project is added to the solution: docker-compose.  Inspect the docker-compose project properties, and the docker-compose.yml.  Quite simple.  Repeat this for febedb.backend:

- Right click on the febedb.backend > Add > Container Orchestration Support
- Container orchestrator: Docker Compose
- Target OS: Linux

If you check docker-compose.yml, you'll notice that the febedb.backend was added to the list of services.  
Notice also these: there's not dependency hints between frontend and backend, and there's not mention of the db.  
The backend and frontend projects (csproj) both have a new property DockerComposeProjectPath

```xml
<DockerComposeProjectPath>..\docker-compose.dcproj</DockerComposeProjectPath>
```

### Service dependencies

The frontend depends on the backend, and the backend depends on the db.  I'm a sucker for readability, so reorder the services to have the backend first, the frontend second, just as if you needed to start the backend before frontend.

- Open docker-compose.yml
- Reorder the services to have backend followed by frontend
- Add the depends_on to the frontend

The docker-compose.yml should look like this:

```yaml
version: '3.4'

services:
  febedb.backend:
    image: ${DOCKER_REGISTRY-}febedbbackend
    build:
      context: .
      dockerfile: febedb.backend/Dockerfile

  febedb.frontend:
    image: ${DOCKER_REGISTRY-}febedbfrontend
    depends_on:
      - febedb.backend
    build:
      context: .
      dockerfile: febedb.frontend/Dockerfile
```

If you try to add a Container Orchestration Support to the febedb.db project, you'll quickly find out that you can't.

Instead, we'll use a vanilla MS SQL approved image instead, and figure things out from there.

Add a new "services" item:

```yaml
  febedb.db:
    image: mcr.microsoft.com/mssql/server:2019-latest
    environment:
      - SA_PASSWORD=Pass@word
      - ACCEPT_EULA=Y
    ports:
      - "5434:1433"
```

And at the same time, change the backend to depend on db.

The docker-compose.yml should look like this so far.

```yaml
version: '3.4'

services:

  febedb.db:
    image: mcr.microsoft.com/mssql/server:2019-latest
    environment:
      - SA_PASSWORD=Pass@word
      - ACCEPT_EULA=Y
    ports:
      - "1433:1433"

  febedb.backend:
    image: ${DOCKER_REGISTRY-}febedbbackend
    depends_on:
      - febedb.db
    build:
      context: .
      dockerfile: febedb.backend/Dockerfile

  febedb.frontend:
    image: ${DOCKER_REGISTRY-}febedbfrontend
    depends_on:
      - febedb.backend
    build:
      context: .
      dockerfile: febedb.frontend/Dockerfile
```

### First run

If you select docker-compose as the Startup Project and hit start, nothing happens.  Let's check the logs.

```powershell
docker logs febedb.frontend
```

nothing !?

```powershell
docker inspect febedb.frontend
```

Did you spot it ?

Check the port...

```json
"Ports": {
    "443/tcp": [
        {
            "HostIp": "0.0.0.0",
            "HostPort": "57909"
        }
    ],
    "80/tcp": [
        {
            "HostIp": "0.0.0.0",
            "HostPort": "57908"
        }
    ]
},
```

If you remember from previous exercises, the environment variables ASPNETCORE_URLS and ASPNETCORE_HTTPS_PORT play significant roles.  Also, if you remember to ..\README.md, docker-compose should be working with 53xx.

- Open the docker-compose.override.yml
- Take the opportunity to change the order: backend, then frontend
- Add ASPNETCORE_HTTPS_PORT environment variables to both backend (5313) and frontend (5323)
- Add port forwards for both projects and ports

The docker-compose.override.yml should look this:

```yml
version: '3.4'

services:
  febedb.backend:
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=https://+:443;http://+:80
      - ASPNETCORE_HTTPS_PORT=5313
    ports:
      - 5310:80
      - 5313:443
    volumes:
      - ${APPDATA}/Microsoft/UserSecrets:/root/.microsoft/usersecrets:ro
      - ${APPDATA}/ASP.NET/Https:/root/.aspnet/https:ro
  febedb.frontend:
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=https://+:443;http://+:80
      - ASPNETCORE_HTTPS_PORT=5323
    ports:
      - 5320:80
      - 5323:443
    volumes:
      - ${APPDATA}/Microsoft/UserSecrets:/root/.microsoft/usersecrets:ro
      - ${APPDATA}/ASP.NET/Https:/root/.aspnet/https:ro

```

Hit F5 again. not much more.  Sigh.

## Back to the basics - CLI

Visual Studio does some voodoo magic in order to give you a great debug experience, but this only works when things go well !

- Delete the generated dockercompose container in Docker Desktop
- Open the command prompt (I like Windows Terminal > PowerShell core) and navigate to the root of this step3b.
- run the docker-compose command yourself:

```powershell
docker-compose -f docker-compose.yml -f docker-compose.override.yml -p febedb up --build --force-recreate
```

- -f are optional, but only docker-compose.yml will be used if not specified, and the override has the port forwards.
- -p is optional, but gives a short and easy to read project name
- up: the command that builds, creates and starts the services from the yml
- --build is optional, but builds the images before starting the containers
- --force-recreate is optional, but recreates the containers, even if no change was detected

Now, open the Docker Desktop:

- check the febedb container logs - looks good
- inspect the febedb containers - looks good
- open the frontend: https://localhost:5323 - looks good
- open the frontend: http://localhost:5320 - woot.  redirected to https..5323
- open the backend: https://localhost:5313/swagger/index.html - woohoo !

Ok... now, what gives ?  Why can't VS do the same ?

Check the Visual Studio Output:

Build output:

```powershell
docker-compose -f "docker-compose.yml" -f "docker-compose.override.yml" -f "\obj\Docker\docker-compose.vs.debug.g.yml" -p dockercompose6205210832147902414 --ansi never up -d
```

mmm: "\obj\Docker\docker-compose.vs.debug.g.yml" let's look at this file.

Many items added to help VS attach to the debugger.

There's got te be something else.  Show output from: Container Tools:

- Checking for Container Prerequisites, Docker Destkop, OS, etc. : nice touch
- Pulling Required Images. ok.
- Warming up container(s) for febedb.backend.  ok, so I guess VS will taylor the debugging experience based on the "output" from running the docker container.  nice touch too.
- And then..  Found this:

```DOS
Info: Using vsdbg version '17.0.10712.2'
Info: Using Runtime ID 'linux-musl-x64'
Info: Successfully installed vsdbg at 'C:\Users\patwa\vsdbg\vs2017u5\linux-musl-x64'
docker run -dt -v "C:\Users\patwa\vsdbg\vs2017u5:/remote_debugger:rw" -v ".\febedb.backend:/app" -v ".\:/src/" -v "C:\Users\patwa\AppData\Roaming\Microsoft\UserSecrets:/root/.microsoft/usersecrets:ro" -v "C:\Users\patwa\AppData\Roaming\ASP.NET\Https:/root/.aspnet/https:ro" -v "C:\Users\patwa\.nuget\packages\:/root/.nuget/fallbackpackages3" -v "C:\Program Files (x86)\Microsoft Visual Studio\Shared\NuGetPackages:/root/.nuget/fallbackpackages" -v "C:\Program Files (x86)\Microsoft\Xamarin\NuGet\:/root/.nuget/fallbackpackages2" -e "DOTNET_USE_POLLING_FILE_WATCHER=1" -e "ASPNETCORE_LOGGING__CONSOLE__DISABLECOLORS=true" -e "ASPNETCORE_ENVIRONMENT=Development" -e "NUGET_PACKAGES=/root/.nuget/fallbackpackages3" -e "NUGET_FALLBACK_PACKAGES=/root/.nuget/fallbackpackages;/root/.nuget/fallbackpackages2;/root/.nuget/fallbackpackages3" -p 5210:80 -p 5213:443 -P --name febedb.backend --entrypoint tail febedbbackend:dev -f /dev/null 
5ee417fae7960d9f10dab0ff45200d7abf863f3993f43708694d820b1c296c29
Container started successfully.
```

Did you spot it ?  -p 5210:80 -p 5213:443

I tried searching for 5210 all over the place: not found.  My gutt says caching issue, so:

- I stopped Visual Studio
- Deleted the hidden .vs folder
- Deleted every .user file, bin/obj folder
- Restarted Visual Studio
- Solution > Clean Solution
- Solution > Rebuild Solution
- F5

```powershell
---------------------------
Microsoft Visual Studio
---------------------------
The target process exited without raising a CoreCLR started event. Ensure that the target process is configured to use .NET Core. This may be expected if the target process did not run on .NET Core.
---------------------------
OK   
---------------------------
```

## Visual Studio 2022 Update

I paused working on this for a few months, and had the brilliant idea to upgrade Visual Studio from 2019 to 2022.  Some projects have been updated to a newer .net version, and now the solution doesn't compile.

```csharp
error DT1001: failed to solve: rpc error: code = Unknown desc = failed to compute cache key: "/febedb.db.build/febedb.db.build.csproj" not found: not found
```

>[!TIP]
> When refactoring code like what we're doing, do pause for a few months in the middle of it, finish the step first.

Now, to fix the error, need to check why it's failing.  The /febedb.db.build/febedb.db.build.csproj is the workaround to allow "dotnet" to compile the bebedb.db database project, but it's not in the solution.  But it's referenced in the DockerFiles...

- Open step3b.dockercompose\febedb.backend\Dockerfile
- Remove the line 17: COPY ["febedb.db.build/febedb.db.build.csproj", "febedb.db.build/"]
- Open step3b.dockercompose\febedb.frontend\Dockerfile
- Remove the line 17: COPY ["febedb.db.build/febedb.db.build.csproj", "febedb.db.build/"]
- Rebuild the solution - PASS

The two projects compile in their docker images.  Appart from the CS0162 Unreachable code detected, we're in good shape.

Run the solution, the [web page](https://localhost:5323/) will be opened with the following content:

```html
<h1>Today's weather forecast</h1>
<div>0 - The SSL connection could not be established, see inner exception.</div>
```

However, if you open the [https://localhost:5313/swagger/index.html](https://localhost:5313/swagger/index.html), you'll see the page responds.

This is the front-end not communicating with the back-end because of an SSL (https) problem.

## Problem DevCerts

Microsoft came up with a nice solution to deal with development SSL certificates - "Development certificates".  Dotnet generates local certificates that are associated with "localhost", so when the browser opens an https://localhost url, the certificate validation between the browser and the server (the workstation) will work.  But in our scenario, the frontend is communicating with the backend with the url [https://febedb.backend](https://febedb.backend) - the certificate issued for "bebedb.backend" does not match "localhost" so the browser rejects it.

There's no way (as of the writing of this repo) to add alternative names to the dev certs.  More info at [https://docs.microsoft.com/en-us/aspnet/core/security/docker-https?view=aspnetcore-6.0](https://docs.microsoft.com/en-us/aspnet/core/security/docker-https?view=aspnetcore-6.0).

We could disable https for development.  But I prefer having the same code for both dev and prod, call me overly protective.

There's a workaround for Kubernetes to [Manage TLS Certificates in a Cluster](https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/), which will be for step4, we need a solution for Docker-Compose.

### OpenSSL

After many failed attempts to find a solution, I found what I was looking for and it involves generating certificates using [OpenSSL](https://openssl.org).

The big picture.  We use openssl to generate certificates, copy them to the backend and frontend docker images at build time, register them in the images *and* on your computer.

OpenSSL can be difficult to install locally, but as a saving grace, many docker images have it installed already, so we'll use these docker images to generate them!

The ./Certs/Init-Certs.ps1 script does these actions:

- Generates a dynamic password and saves it to ./Certs/generated/Password.txt
- Runs the GenerateCertsInContainer.ps1 in a dotnet sdk docker image (mcr.microsoft.com/dotnet/sdk:5.0).  The ./Certs folder is volume mounted to the /Certs so that the generated files are easily retrievable from the host
- A Visual Studio docker-compose debug and release yml are generated with the password and certificate paths as environment variables (see bellow)
- The generated certificate is registered on the local machine (so that the browser can validate the certificate being passed by the web app)

The ./Certs/GenerateCertsInContainer.ps1 does these actions (in the container):

- Using the ./Certs/*.cnf as configuration data + ./Certs/generated/Password.txt
- Generates a certificate authority (root Certificate)
- Generates a backend certificate
- Generates a frontend certificate

The generated docker-compose.vs.debug/release.yml contain the password and absolute path as environment variables that kestrel will use

What do you need to do ?

- Create a folder ./Certs
- Copy every file from this repo's ./Certs folder
- Modify the *.cnf to match your setup
- Run ./Certs/Init-Certs.ps1
- Add the generated docker-compose.vs.debug/release.yml to the docker-compose.dcproj
- Modify the Dockerfiles

The end of the Dockerfile should look like this:

```dockerfile
FROM base AS final
WORKDIR /app
COPY /Certs/generated/ /usr/local/share/ca-certificates
RUN chmod 644 /usr/local/share/ca-certificates/febedb.ca.cert.crt \
  && update-ca-certificates
COPY --from=publish /app/publish .
```

That's it.  F5
