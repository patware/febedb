#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

#Depending on the operating system of the host machines(s) that will build or run the containers, the image specified in the FROM statement may need to be changed.
#For more information, please see https://aka.ms/containercompat

FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src

# It's important to keep lines from here down to "COPY . ." identical in all Dockerfiles
# to take advantage of Docker's build cache, to speed up local container builds

COPY "3ta.sln"  "3ta.sln"

COPY ["3ta.api/3ta.api.csproj", "3ta.api/"]
COPY ["3ta.business/3ta.business.csproj", "3ta.business/"]
COPY ["3ta.core/3ta.core.csproj", "3ta.core/"]
COPY ["3ta.mvc/3ta.mvc.csproj", "3ta.mvc/"]

COPY "docker-compose.dcproj" "docker-compose.dcproj"

COPY "NuGet.config" "NuGet.config"

RUN dotnet restore "3ta.sln"

COPY . .
WORKDIR "/src/3ta.business"
RUN dotnet build "3ta.business.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "3ta.business.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "3ta.business.dll"]