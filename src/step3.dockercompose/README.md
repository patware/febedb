# Step 3 - Docker-Compose

! STOP !

Do NOT follow this, use step3b.dockercompose instead.

Turns out the approach I initially took was flawed and had to revert back.  But, I feel you should be able to follow what I've done so that you can "appreciate" the work and thought process.  Skip this "non-sense" and go directly to step3b.dockercompose which continues in the right direction.  This step3.dockercompose exists only as a knowledge base.

Making it actually work in docker.

In [step 1](../step1.normal/README.md), we created a classic 3 tier application: front end in ASP.Net Core MVC, a back end in ASP.Net Core Web Api and a Sql Database project.  
In [step 2](../step2.docker/README.md), we dockerized our 3 tier app, so instead of running the apps in it's normal environment (kestrel or IIS Express), the apps will run in a Docker container.  
The problem we quickly found out is that inter container communication is not easy.  
In step 3, docker-compose will(I hope, well that's the plan) bridge the gap of inter container communication.

## docker-composing

The backend and frontend are configured to run in a docker container.  
Let's make them run in a multi-container, orchestrated docker group with docker-compose, by letting Visual Studio do the heavy lifting:

- Right click on the febedb.backend > Add > Container Orchestration Support
- Container orchestrator: Docker Compose
- Target OS: Linux

A new project is added to the solution: docker-compose.  Inspect the docker-compose project properties, and the docker-compose.yml.  Quite simple.  Repeat this for febedb.frontend:

- Right click on the febedb.frontend > Add > Container Orchestration Support
- Container orchestrator: Docker Compose
- Target OS: Linux

If you check docker-compose.yml, you'll notice that the febedb.frontend was added to the list of services.  
Notice also these: there's not dependency hints between frontend and backend, and there's not mention of the db.  
Note also the backend and frontend projects (csproj) have a new property DockerComposeProjectPath

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

If you select docker-compose as the Startup Project and hit start, the swagger page will show.  
Check the port, it's a dynamically created port number that allows the service to be exposed outside the "service".  Let's run curl inside the frontend container:

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

## The Db's turn to get some TLC

Alright....  

Short answer, don't try it, and Skip to the step3B.dockercompose.

But basically, the first problem was with my whole approach of db schemas in images.  We shouldn't!

Check out Chris Behrens's [Developing SQL Server Databases with Docker](https://app.pluralsight.com/library/courses/sql-server-databases-docker-developing) to find out why not.

Second, the approach I was aiming involved a workaround using MSBuild.Sdk.SqlProj class library, but this created another problem:

CTC1031: Linux containers are not supported for febedb.db.build project.

So, I decided to switch approach completely and do it "the right way".

### A manual approach before doing anything in a Dockerfile

One way to get the docker file correctly is to do run the commands from the command line.

#### Run a Sql Server image

Pull a sql server image and run it.

```
docker pull mcr.microsoft.com/mssql/server:2019-latest
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=<YourStrong!Passw0rd>" -p 1401:1433 --name febedb_db_manual -d mcr.microsoft.com/mssql/server:2019-latest
```

A container is running.  Check it out

```
docker exec -it febedb_db_manual /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "<YourStrong!Passw0rd>" -Q "SELECT @@VERSION"
------------------------------------------------------------------------------------------------------------------------------------
Microsoft SQL Server 2019 (RTM-CU13) (KB5005679) - 15.0.4178.1 (X64)
        Sep 23 2021 16:47:49
        Copyright (C) 2019 Microsoft Corporation
        Developer Edition (64-bit) on Linux (Ubuntu 20.04.3 LTS) <X64>

(1 rows affected)
```

#### Copy the dacpac

Let's copy the dacpac to the container

```
docker exec --user root febedb_db_manual mkdir /dacpacs
docker cp febedb.db\bin\Debug\febedb.db.dacpac febedb_db_manual:/dacpacs/febedb.db.dacpac
```

#### Install unzip and SqlPackage

Install Unzip

```
docker exec --privileged --user root febedb_db_manual apt-get update
docker exec --privileged --user root febedb_db_manual apt-get install unzip -y
```

and SQLPackage

Install SQLPackage for Linux and make it executable (from evergreen link https://aka.ms/sqlpackage-linux)

```
docker exec --privileged --user root febedb_db_manual wget -progress=bar:force -q -O sqlpackage.zip https://aka.ms/sqlpackage-linux
docker exec --privileged --user root febedb_db_manual unzip -qq sqlpackage.zip -d /opt/sqlpackage
docker exec --privileged --user root febedb_db_manual chmod +x /opt/sqlpackage/sqlpackage
```

#### Deploy the DACPAC to SQL

Notice that this command now runs under mssql

```
docker exec --user mssql febedb_db_manual /opt/sqlpackage/sqlpackage /action:publish /targetuser:sa /targetpassword:"<YourStrong!Passw0rd>" /sourcefile:/dacpacs/febedb.db.dacpac /TargetServerName:. /TargetDatabaseName:febedb.db
Publishing to database 'febedb.db' on server '.'.
Initializing deployment (Start)
Initializing deployment (Complete)
Analyzing deployment plan (Start)
Analyzing deployment plan (Complete)
Updating database (Start)
Creating database febedb.db...
Creating SqlTable [dbo].[WeatherForecast]...
Creating SqlExtendedProperty [dbo].[WeatherForecast].[Date].[MS_Description]...
Update complete.
Updating database (Complete)
Successfully published database.
Time elapsed 0:00:12.66
```

Ho yeah!  Test it.

```
docker exec -it febedb_db_manual /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "<YourStrong!Passw0rd>" -d "febedb.db" -Q "SELECT * FROM [dbo].[WeatherForecast]"
Id          Date                    TemperatureC
----------- ----------------------- ------------

(0 rows affected)
```

Wooot !

### Time to translate this knowledge to a Dockerfile

#### But first, a special workaround is necessary

Lets try our luck with:

- [Shawty](https://shawtyds.wordpress.com/2020/08/26/using-a-full-framework-sql-server-project-in-a-net-core-project-build/)'s blog.
- [](https://www.wintellect.com/devops-sql-server-dacpac-docker)
- [](https://www.wintellect.com/automating-sql-server-2019-docker-deployments/)
- [](https://dbafromthecold.com/2019/09/18/running-sql-server-containers-as-non-root/)
- [](https://docs.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage-download?view=sql-server-linux-ver15)
- [](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-docker-container-configure?view=sql-server-ver15&pivots=cs1-bash)
- [](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-docker-container-deployment?view=sql-server-linux-ver15&pivots=cs1-cmd#buildnonrootcontainer)


### Start with the class library

- Add new standard Class Library
  - name: febedb.db.build
  - Target Framework: .NET Standard 2.1
- Delete class1
- Unload the project
- Replace the csproj with:

```xml
<Project Sdk="MSBuild.Sdk.SqlProj/1.15.0">
  <PropertyGroup>
    <TargetFramework>netstandard2.1</TargetFramework>
    <SqlServerVersion>Sql150</SqlServerVersion>
    <!-- For additional properties that can be set here, please refer to https://github.com/rr-wfm/MSBuild.Sdk.SqlProj#model-properties -->
  </PropertyGroup>
  <PropertyGroup>
    <!-- Refer to https://github.com/rr-wfm/MSBuild.Sdk.SqlProj#publishing-support for supported publishing options -->
  </PropertyGroup>
  <ItemGroup>
    <Content Include="..\febedb.db\**\*.sql" Exclude="..\febedb.db\bin\**" />
  </ItemGroup>
</Project>
```


### Dockerfile

Add a Dockerfile to the febedb.db.build project.

Build and run the image.

```dos
docker build -f febedb.db.build\Dockerfile  -t febedbdb:dev . 

md db/data
md db/log
md db/secrets

D:\dev\Github\Patware\febedb\src\step3.dockercompose\
docker run -p 1433:1433 -v D:\dev\Github\Patware\febedb\src\step3.dockercompose\db\data:/var/opt/mssql/data -v D:\dev\Github\Patware\febedb\src\step3.dockercompose\db\log:/var/opt/mssql/log -v D:\dev\Github\Patware\febedb\src\step3.dockercompose\db\secrets:/var/opt/mssql/secrets -d -n febedbdb_dev febedbdb:dev

```

Arg...  Something's wrong, the db doesn't get committed to the final image.

## Blocked

Linux Containers don't support MSBuild.Sdk.SqlProj type projects.

```
CTC1031: Linux containers are not supported for febedb.db.build project.	

docker-compose	C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Sdks\Microsoft.Docker.Sdk\build\Microsoft.VisualStudio.Docker.Compose.targets	318	
```

Found similar threads from various sites (github, stakoverflow)

### Plan B - Build from command line

A thread suggested building from the command line

```
docker-compose build
error MSB4044: The "CopyRefAssembly" task was not given a value for the required parameter "SourcePath". [/src/febedb.db.build/febedb.db.build.csproj]
```
