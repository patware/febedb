#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0@sha256:3cbb1b87fb7abdf2f769c1cb9e455bd1e36ddacb465bee8179b7bf7faf747a85 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0@sha256:6187deae4799f812191b618d6d071dc30d1be692600b12af5046ff3b2c4b4658 as build
WORKDIR /src
COPY ["febedb.frontend/febedb.frontend.csproj", "febedb.frontend/"]
COPY ["febedb.backend/febedb.backend.csproj", "febedb.backend/"]
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