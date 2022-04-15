# https://github.com/twright-msft/mssql-node-docker-demo-app/blob/master/Dockerfile
# This helped: https://vsupalov.com/docker-arg-env-variable-guide/
#    and this: https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-docker-container-deployment?view=sql-server-linux-ver15&pivots=cs1-cmd#buildnonrootcontainer
#  ARG: 
#   Build-time variables.  
#   Useable from the place they're defined
#   Running containers can't access values from ARG
#   ARG variables without a default value HAS TO BE provided in the bulid command, or else there will be an error.
#   ARG value is accessible from the docker history of an image. poor choice for sensitive data
# Dockerfile
#   ARG some_variable_name
#   ARG some_other_variable_name=with_default_value
#   RUN echo "Look at that $some_variable_name or ${some_other_variablename}"
# Docker build
#   docker build --build-arg some_variable_name=foo --build-arg some_other_variable_name=bar_overrides_default_value
#
#  ENV: 
#   Accessible during build
#   Accessible from running container
#   Useable from the place they're defined
#   Values are overwridable when starting container
# Dockerfile
#   ENV hey
#   ENV foo bar
#   ENV hello=world
#   #Use the env variable "foo"
#   RUN echo $foo
#     # translates to RUN echo bar
#   RUN echo ${foo}
#     # translates to RUN echo bar
# Example of dynamic on-build env variables
#   # expect a build-time variable
#   ARG Some_Build_Time_Variable
#   # use the value to set the ENV var
#   ENV Some_Environment_Variable=$Some_Build_Time_Variable
# if not overriden, that value of Some_Environment_Variable will be available to your container 


# --------------------------------------------------------
FROM mcr.microsoft.com/mssql/server:2019-latest@sha256:fb5277e7a3cc53f7d2230ed089ed60849f79567ebb0aae8f41ceb85879e9e09d AS base
WORKDIR /init

# Configure external build arguments to allow configurability.
# See https://hub.docker.com/_/microsoft-mssql-server
#   Requires the following environment flags
ENV ACCEPT_EULA=Y
# MSSQL_PID=<your_product_id | edition_name> (default: Developer)
ENV MSSQL_PID=Express 
ENV DBNAME=febedb.db
EXPOSE 1433:1433
ENV MSSQL_SA_PASSWORD="<YourStrong!Passw0rd>"

# --------------------------------------------------------
# This will build the febedb.db.build which will generate dacpac (to folder /db/)
FROM mcr.microsoft.com/dotnet/sdk:5.0@sha256:6f6ca28cee7960278a8a62859d389084a48449abaa0b98411b1e8684716585a5 as build
WORKDIR /src
COPY ["febedb.backend/febedb.backend.csproj", "febedb.backend/"]
COPY ["febedb.frontend/febedb.frontend.csproj", "febedb.frontend/"]
COPY ["febedb.db/febedb.db.sqlproj", "febedb.db/"]
COPY ["febedb.db.build/febedb.db.build.csproj", "febedb.db.build/"]
RUN dotnet restore "febedb.db.build/febedb.db.build.csproj"
COPY . .
WORKDIR "/src/febedb.db.build"
RUN dotnet build "febedb.db.build.csproj" -c Release -o /db/

# --------------------------------------------------------
FROM base AS final

USER root
WORKDIR /dacpacs

# Copy the generated dacpac to /dacpacs/febedb.db.dacpac
COPY --from=build /db/febedb.db.build.dacpac febedb.db.dacpac

# Install Unzip
RUN apt-get update \
    && apt-get install unzip -y

# Install SQLPackage for Linux and make it executable (from evergreen link https://aka.ms/sqlpackage-linux)
RUN wget -progress=bar:force -q -O sqlpackage.zip https://aka.ms/sqlpackage-linux \
    && unzip -qq sqlpackage.zip -d /opt/sqlpackage \
    && chmod +x /opt/sqlpackage/sqlpackage

# Launch SQL Server, confirm startup is complete, deploy the DACPAC, then terminate SQL Server.
# See https://www.wintellect.com/devops-sql-server-dacpac-docker/
# See https://stackoverflow.com/a/51589787/488695
RUN ( /opt/mssql/bin/sqlservr & ) | grep -q "Service Broker manager has started" \
    && /opt/sqlpackage/sqlpackage /Action:publish /Targetuser:sa /TargetPassword:$MSSQL_SA_PASSWORD /sourcefile:/dacpacs/febedb.db.dacpac       /TargetServerName:.  /TargetDatabaseName:$DBNAME \
    && rm /dacpacs/febedb.db.dacpac \
    && /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -d "febedb.db" -Q "SELECT * FROM [dbo].[WeatherForecast]" | grep -q "TemperatureC" \
    && pkill sqlservr

