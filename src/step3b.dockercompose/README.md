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
