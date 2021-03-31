# Classic C# 3tier app to orchestrated container

This repo is the chronicles of the transitioning of a classic [3tier app](https://docs.microsoft.com/en-us/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures#traditional-n-layer-architecture-applications) app to one running in an orchestrated container, paving the way towards microservices like [eShopOnContainers](https://github.com/dotnet-architecture/eShopOnContainers) experience.

Febedb stands for Front End, Back End, DataBase.

In order to make this as relevant as possible to everyone, the [technologies](#technologies) and patterns used are classic (Asp.Net MVC, Web services) and Sql Server.  

There won't be cooler/better frameworks or patterns used to build modern [frontend](https://docs.microsoft.com/en-us/dotnet/architecture/modern-web-apps-azure/common-client-side-web-technologies) like [Angular](https://angular.io/), [React]()]https://reactjs.org/) or [Vue.js]()]https://vuejs.org/), [backend]() using [Web API](https://docs.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/microservice-application-layer-implementation-web-api) or [gRPC](https://docs.microsoft.com/en-us/dotnet/architecture/cloud-native/grpc), nor any NoSql like [MongoDb](https://www.mongodb.com/).

On the other hand, at the end of the transition, your app will in position/state to make it easy to adopt them.

## Methodology

Each step will have its own directory, with a "before" and an "after".

For each step, the app will be executable from Visual Studio or from the command line.

Steps:

1. story begins with a 3 tier app. [README](./src/step1.normal/README.md)
1. app will be "dockerized".
1. container orchestration with docker-compose
1. Kubernetes

## Technologies

Starting technologies and software:

- Visual Studio 2019
- .Net Core 5
- Language: C#
- Frontend: Web App (MVC)
- Backend: Web service
- Database: Sql Server

Target technologies and software:

- Visual Studio 2019
- .Net Core 5
- Docker
- Kubernetes
- Language: C#
- Frontend: Web App (MVC)
- Backend: Web service
- Database: Sql Server

> [!Note]
> .Net core 5 is probably more "modern" than your situation, simply [convert](https://github.com/dotnet/try-convert) your .net Framework app.

## Requirements

- Windows 10
- Docker for Windows with Kubernetes - Windows Containers
- WSL2
- Visual Studio 2019
- .Net Core 5.0

## Naming convention for ports

It's easier to troubleshoot errors when ports follow a certain pattern.  The web ports will be using the 5xxx range:

1. First digit: 5 - for convenience.
1. Second digit: step-ish: 0: IIS Express, 1: kestrel, 2: docker, 3: docker-compose, 4: Kubernetes
1. Third digit: 1 = back end, 2 = front end (follows the loading order)
1. Fourth digit 0 = http, 3 = https (like in 0 for 80 and 3 for 443 ;))

## 3 tier applications

For a long time, the [3tier architecture](https://docs.microsoft.com/en-us/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures#traditional-n-layer-architecture-applications) was a well-established software application architecture that organizes applications into 3 logical and physical computing tiers:

- the presentation tier, or user interface
- the application tier, where information is processed
- the data tier, where the data associated with the application is stored

Today, a more modern way of building these is via [microcontainers](https://docs.microsoft.com/en-us/dotnet/architecture/microservices/).

## This is not

This repo is not a course or lecture on micro containers, containers, serverless, or any cloud native technology offerings.
