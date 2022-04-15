#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

# Requirements
#  The certificates used need to be previously created
#    Use the ../Certs/Init-Certs.ps1 to generate them
FROM mcr.microsoft.com/dotnet/aspnet:6.0@sha256:3cbb1b87fb7abdf2f769c1cb9e455bd1e36ddacb465bee8179b7bf7faf747a85 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0@sha256:6187deae4799f812191b618d6d071dc30d1be692600b12af5046ff3b2c4b4658 as build
WORKDIR /src
COPY ["febedb.backend/febedb.backend.csproj", "febedb.backend/"]
COPY ["febedb.frontend/febedb.frontend.csproj", "febedb.frontend/"]
COPY ["febedb.db/febedb.db.sqlproj", "febedb.db/"]
RUN dotnet restore "febedb.frontend/febedb.frontend.csproj"
COPY . .
WORKDIR "/src/febedb.frontend"
RUN dotnet build "febedb.frontend.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "febedb.frontend.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY /Certs/generated/ /usr/local/share/ca-certificates
RUN chmod 644 /usr/local/share/ca-certificates/febedb.ca.cert.crt \
  && update-ca-certificates
COPY --from=publish /app/publish .

ENTRYPOINT ["dotnet", "febedb.frontend.dll"]