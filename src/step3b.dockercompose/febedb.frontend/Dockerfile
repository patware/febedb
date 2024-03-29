#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

# Requirements
#  The certificates used need to be previously created
#    Use the ../Certs/Init-Certs.ps1 to generate them
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 as build
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