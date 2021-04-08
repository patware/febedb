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

### Service dependencies

The frontend depends on the backend, and the backend depends on the db.

- Open docker-compose.yml
- Add the depends_on

```yml
  febedb.frontend:
    image: ${DOCKER_REGISTRY-}febedbfrontend
    depends_on:
      - febedb.backend
    build:
      context: .
      dockerfile: febedb.frontend/Dockerfile
```

If you select docker-compose as the Startup Project and hit start, the swagger page will show.  Check the port, it's a dynamically created port number that allows the service to be exposed outside the "service".  Let's run curl inside the frontend container:

```dos
docker exec -it c1601 /bin/sh

# apt-get update
# apt-get install curl
# curl https://febedb.frontend/
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.haxx.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.

# curl https://febedb.backend/swagger/index.html
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.haxx.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```

This is "some" progress, the frontend can now reference the backend using the service's name: "febedb.backend".  Now, the certificates.

## OpenSSL

Thanks to the community, a [similar problem](https://github.com/microsoft/DockerTools/issues/249) was reported in gitHub. I followed Nathan Carlson's [CertExample](https://github.com/NCarlsonMSFT/CertExample/).

- Create a (Windows) folder: Certs
- Create PowerShell script: create-certs.ps1
- Create docker-compose yml template: docker-compose.vs.debug.yml.template
- Create a bash shell script: createCerts.sh
- Create config files: febedb.cnf, febedb.backend.cnf, febedb.frontend.cnf

In the docker-compose.vs.debug.yml has a instruction build a specific stage of the dockerfile.  Add the specified stage to the backend and frontend dockerfiles.

```yml
FROM base AS testCerts
ADD Certs/Generated/febedb.ca.cert.crt /usr/local/share/ca-certificates/febedb.ca.cert.crt
RUN chmod 644 /usr/local/share/ca-certificates/febedb.ca.cert.crt && update-ca-certificates
```

This will add the generated CA as approver for the each SSL certificate.

The frontend still points to "localhost:5213", this is a two step fix:

1. febedb.frontend\appsettings.json > update the BackendUrl to: ```"BackendUrl": "https://febedb.backend"```
1. docker-compose.override.yml > set the appropriate port mappings:

- febedb.backend:
  - "5310:80"
  - "5313:443"
- febedb.frontend:
  - "5320:80"
  - "5323:443"

>[!NOTE]
> Notice that the BackendUrl (https://febedb.backend) does not include a port, but in the docker-compose we set a port mapping and when we navigate to the url to test the swagger, we need that port.  That's because internally (from container to container within docker-compose) they speak native (:80 and :443).  The port mapping is for the outside world (your workstation) when trying to access "internals".

Now, if you hit Start, we're almost there ;)  There will be an error, that's because (localdb) being SQL Express won't be accessible.

We can workaround that problem by hard coding a fake weather, and tackle the sql stuff another time.