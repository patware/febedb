#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0@sha256:3cbb1b87fb7abdf2f769c1cb9e455bd1e36ddacb465bee8179b7bf7faf747a85 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM base AS testCerts
ADD Certs/Generated/febedb.ca.cert.crt /usr/local/share/ca-certificates/febedb.ca.cert.crt
RUN chmod 644 /usr/local/share/ca-certificates/febedb.ca.cert.crt && update-ca-certificates

FROM mcr.microsoft.com/dotnet/sdk:6.0@sha256:6187deae4799f812191b618d6d071dc30d1be692600b12af5046ff3b2c4b4658 as build
WORKDIR /src
COPY ["febedb.backend/febedb.backend.csproj", "febedb.backend/"]
COPY ["febedb.frontend/febedb.frontend.csproj", "febedb.frontend/"]
COPY ["febedb.db/febedb.db.sqlproj", "febedb.db/"]
COPY ["febedb.db.build/febedb.db.build.csproj", "febedb.db.build/"]
RUN dotnet restore "febedb.backend/febedb.backend.csproj"
COPY . .
WORKDIR "/src/febedb.backend"
RUN dotnet build "febedb.backend.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "febedb.backend.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "febedb.backend.dll"]