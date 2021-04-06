# Step 3 - Docker-Compose

Making it actually work in docker.

In [step 1](../step1.normal/README.md), we created a classic 3 tier application: front end in ASP.Net Core MVC, a back end in ASP.Net Core Web Api and a Sql Database project.  In [step 2](../step2.docker/README.md), we dockerized our 3 tier app, so instead of running the apps in it's normal environment (kestrel or IIS Express), the apps will run in a Docker container.  The problem we quickly found out is that inter container communication is not easy.  In step 3, docker-compose will bridge the gap of inter container communication.

## docker-composing

The backend and frontend are configured to run in a docker container.  Let's make them run in a multi-container, orchestrated docker group with docker-compose.  Let's let Visual Studio do the heavy lifting:

- Right click on the febedb.backend > Add > Container Orchestration Support
- Container orchestrator: Docker Compose
- Target OS: Linux

A new project is added to the solution: docker-compose.  Inspect the docker-compose project properties, and the docker-compose.yml.  Quite simple.  Let's repeat this for febedb.frontend:

- Right click on the febedb.frontend > Add > Container Orchestration Support
- Container orchestrator: Docker Compose
- Target OS: Linux

If you check docker-compose.yml, you'll notice that the febedb.frontend was added to the list of services.  Notice also these: there's not dependency hints between frontend and backend, and there's not mention of the db.  Note also the backend and frontend projects (csproj) have a new property DockerComposeProjectPath

```xml
<DockerComposeProjectPath>..\docker-compose.dcproj</DockerComposeProjectPath>
```

| project | https | http |
| ------- | --- | --- |
| febedb.backend | 5313 | 5310 |
| febedb.frontend | 5323 | 5320 |
