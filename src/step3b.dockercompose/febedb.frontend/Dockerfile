#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM base AS testCerts
ADD Certs/Generated/febedb.ca.cert.crt /usr/local/share/ca-certificates/febedb.ca.cert.crt
RUN chmod 644 /usr/local/share/ca-certificates/febedb.ca.cert.crt && update-ca-certificates

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ["febedb.backend/febedb.backend.csproj", "febedb.backend/"]
COPY ["febedb.frontend/febedb.frontend.csproj", "febedb.frontend/"]
COPY ["febedb.db/febedb.db.sqlproj", "febedb.db/"]
COPY ["febedb.db.build/febedb.db.build.csproj", "febedb.db.build/"]
RUN dotnet restore "febedb.frontend/febedb.frontend.csproj"
COPY . .
WORKDIR "/src/febedb.frontend"
RUN dotnet build "febedb.frontend.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "febedb.frontend.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "febedb.frontend.dll"]