# https://github.com/twright-msft/mssql-node-docker-demo-app/blob/master/Dockerfile

FROM mcr.microsoft.com/mssql/server:2019-latest AS base
WORKDIR /init
ENV ACCEPT_EULA=Y
ENV MSSQL_SA_PASSWORD=MyPassword
ENV MSSQL_PID=Express
EXPOSE 1433:1433

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ["febedb.backend/febedb.backend.csproj", "febedb.backend/"]
COPY ["febedb.frontend/febedb.frontend.csproj", "febedb.frontend/"]
COPY ["febedb.db/febedb.db.sqlproj", "febedb.db/"]
COPY ["febedb.db.build/febedb.db.build.csproj", "febedb.db.build/"]
RUN dotnet restore "febedb.db.build/febedb.db.build.csproj"
COPY . .
WORKDIR "/src/febedb.db.build"
RUN dotnet build "febedb.db.build.csproj" -c Release -o /db/

FROM base AS final
WORKDIR /dacpacs
COPY --from=build /db/ .

USER root

# Install Unzip
RUN apt-get update \
    && apt-get install unzip -y

# Install SQLPackage for Linux and make it executable (from evergreen link https://aka.ms/sqlpackage-linux)
RUN wget -progress=bar:force -q -O sqlpackage.zip https://aka.ms/sqlpackage-linux \
    && unzip -qq sqlpackage.zip -d /opt/sqlpackage \
    && chmod +x /opt/sqlpackage/sqlpackage

# Configure external build arguments to allow configurability.
ARG DBNAME=febedb.db
ARG PASSWORD

# Configure the required environmental variables
ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=$PASSWORD

USER mssql

# Launch SQL Server, confirm startup is complete, deploy the DACPAC, then terminate SQL Server.
# See https://stackoverflow.com/a/51589787/488695
 RUN ( /opt/mssql/bin/sqlservr & ) | grep -q "Service Broker manager has started" \
    && /opt/sqlpackage/sqlpackage /Action:Publish /TargetServerName:. /TargetDatabaseName:${DBNAME} /TargetUser:sa /TargetPassword:$SA_PASSWORD /SourceFile:/dacpacs/febedb.db.build.dacpac \
    && rm /dacpacs/febedb.db.build.dacpac \
    && pkill sqlservr

# RUN SqlPackage.exe /action:publish /sourcefile:/app/publish/febedb.db.build.dacpac /TargetDatabaseName:febedb.db
ENTRYPOINT /bin/bash ./entrypoint.sh