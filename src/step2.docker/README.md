# Step 2 - Docker

Let the fun begin.

In [step 1](../step1.normal/README.md), we created a classic 3 tier application: front end in ASP.Net Core MVC, a back end in ASP.Net Core Web Api and a Sql Database project.  Step 2 will dockerize our 3 tier app, so instead of running the apps in it's normal environment (kestrel or IIS Express), the apps will run in a Docker container.

## Docker

We're going to use Docker, so make sure Docker for Windows is installed and running.  It may or may not make a difference to you (much), but I'll be running in "Linux containers" mode.

Just to make it clear(er):  Docker for Windows - 3.2.2
