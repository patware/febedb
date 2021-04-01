# Step 2 - Docker

Let the fun begin.

In [step 1](../step1.normal/README.md), we created a classic 3 tier application: front end in ASP.Net Core MVC, a back end in ASP.Net Core Web Api and a Sql Database project.  Step 2 will dockerize our 3 tier app, so instead of running the apps in it's normal environment (kestrel or IIS Express), the apps will run in a Docker container.

## Docker

We're going to use Docker, so make sure Docker for Windows is installed and running.  It may or may not make a difference to you (much), but I'll be running in "Linux containers" mode.

Just to make it clear(er):  Docker for Windows - 3.2.2

## febedb.frontend

- Right click on the project > Add > Docker Support
- Choose Linux

If you choose febedb.frontend as the srartup, Docker will be the selected profile.  Click Start.

I got this.  Browser is sent to "https://localhost:49153/" but there's an error:

SocketException: Cannot assign requested address
System.Net.Sockets.Socket+AwaitableSocketAsyncEventArgs.ThrowException(SocketError error, CancellationToken cancellationToken)

HttpRequestException: Cannot assign requested address (localhost:5113)
System.Net.Http.ConnectHelper.ConnectAsync(Func<SocketsHttpConnectionContext, CancellationToken, ValueTask<Stream>> callback, DnsEndPoint endPoint, HttpRequestMessage requestMessage, CancellationToken cancellationToken)

That's because the backend needs to be running too, so re-select Multiple Startup Projects, and hit Start again.

You should now have see the kestrel command window for the backend, and two browsers.

But, same error.  What gives ?

febedb.backend logs:

```dos
info: Microsoft.Hosting.Lifetime[0]
      Now listening on: https://localhost:5113
info: Microsoft.Hosting.Lifetime[0]
      Now listening on: http://localhost:5110
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Development
```

When I navigate to those [URL](https://localhost:5113/swagger/index.html), I see the swagger output.

But there's that error again.  In the docker container's log:

```dos
info: Microsoft.Hosting.Lifetime[0]
Now listening on: https://[::]:443
info: Microsoft.Hosting.Lifetime[0]
Now listening on: http://[::]:80
info: Microsoft.Hosting.Lifetime[0]
Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
Hosting environment: Development
info: Microsoft.Hosting.Lifetime[0]
Content root path: /app
fail: Microsoft.AspNetCore.Diagnostics.DeveloperExceptionPageMiddleware[1]
An unhandled exception has occurred while executing the request.
System.Net.Http.HttpRequestException: Cannot assign requested address (localhost:5113)
---> System.Net.Sockets.SocketException (99): Cannot assign requested address
at System.Net.Sockets.Socket.AwaitableSocketAsyncEventArgs.ThrowException(SocketError error, CancellationToken cancellationToken)
at System.Net.Sockets.Socket.AwaitableSocketAsyncEventArgs.System.Threading.Tasks.Sources.IValueTaskSource.GetResult(Int16 token)
at System.Net.Sockets.Socket.<ConnectAsync>g__WaitForConnectWithCancellation|283_0(AwaitableSocketAsyncEventArgs saea, ValueTask connectTask, CancellationToken cancellationToken)
```

If I inspect the container:

- ASPNETCORE_URLS = https://+:443;http://+:80
- 443/tcp = 0.0.0.0:49153
- 90/tcp = 0.0.0.0:49154

The URLS's port match the output window.

But notice the ip: 0.0.0.0.

What if...  the frontend running in a container is running in another "localhost" context ?

```dos
docker exec -it b36b /bin/sh

apt-get update
apt-get install iputils-ping

# ping localhost
PING localhost (127.0.0.1) 56(84) bytes of data.
64 bytes from localhost (127.0.0.1): icmp_seq=1 ttl=64 time=0.034 ms
64 bytes from localhost (127.0.0.1): icmp_seq=2 ttl=64 time=0.026 ms
^C
--- localhost ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 99ms
rtt min/avg/max/mdev = 0.025/0.028/0.034/0.006 ms
# ping 0.0.0.0
PING 0.0.0.0 (127.0.0.1) 56(84) bytes of data.
64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.041 ms
64 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.032 ms

# ping 192.168.2.12
PING 192.168.2.12 (192.168.2.12) 56(84) bytes of data.
64 bytes from 192.168.2.12: icmp_seq=1 ttl=37 time=4.79 ms
64 bytes from 192.168.2.12: icmp_seq=2 ttl=37 time=1.17 ms

```

Haa... So localhost and 0.0.0.0 resolve to 127.0.0.1. And my machine is 192.168.2.12 and is pingable.

```dos
# apt-get install curl

# curl www.google.com
<!doctype html><html itemscope="" itemtype="http://schema.org/WebPage"...

# curl https://192.168.2.12:5113/swagger/index.html
curl: (7) Failed to connect to 192.168.2.12 port 5113: Connection refused

```

We're getting somewhere.  192.168.2.12 is reachable (ping) and but nothing was there to answer to the request (Connection refused) on that IP/Port combo.

In the febedb.backend > Properties > launchSettings.json: Change the

profiles > febedb.backend > applicationUrl : "applicationUrl": "https://+:5113;http://+:5110"

This should tell to bind the ports to whatever IP.

In the febedb.frontend > Properties > launchSettings.json: Change the

profiles > febedb.backend:

```json
    "febedb.backend": {
      "commandName": "Project",
      "dotnetRunMessages": "true",
      "launchBrowser": true,
      "launchUrl": "swagger",
      "applicationUrl": "https://192.168.2.12:5113;http://192.168.2.12:5110",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
```


This "//+:" tells kestrel to listen/bind to whatever IP.

For the febedb.frontend's "Settings", that's tricky, there's no variable substitution (well, not that I'm aware of anyway), so plan B (for now): hard code.

```json
  "Settings": {
    "BackendUrl": "https://192.168.2.12:5113"
  },
```

I would say it's better, we have two errors:

First, the browser opening https://192.168.2.12:5113/swagger/index.html complains that the connection isn't secure.  That's because the certificate (dotnet dev cert) is issued to a DNS name = localhost and we're asking for an IP that resolves to something else than localhost. 
```powershell
❯ ping -a 192.168.2.12

Pinging host.docker.internal [192.168.2.12] with 32 bytes of data:
Reply from 192.168.2.12: bytes=32 time<1ms TTL=128
Reply from 192.168.2.12: bytes=32 time<1ms TTL=128
Reply from 192.168.2.12: bytes=32 time<1ms TTL=128
```

And second, the frontend can't verify the validity of the certificate.

AuthenticationException: The remote certificate is invalid according to the validation procedure: RemoteCertificateNameMismatch, RemoteCertificateChainErrors
System.Net.Security.SslStream.SendAuthResetSignal(ProtocolToken message, ExceptionDispatchInfo exception)

HttpRequestException: The SSL connection could not be established, see inner exception.
System.Net.Http.ConnectHelper.EstablishSslConnectionAsyncCore(bool async, Stream stream, SslClientAuthenticationOptions sslOptions, CancellationToken cancellationToken)

For the same reasons as above.

So let's try plan C...

But first, revert the changes to launchSettings.json

```json
    "febedb.backend": {
      "commandName": "Project",
      "dotnetRunMessages": "true",
      "launchBrowser": true,
      "launchUrl": "swagger",
      "applicationUrl": "https://localhost:5113;http://localhost:5110",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
```

and in appsettings.json

```json
  "Settings": {
    "BackendUrl": "https://localhost:5113"
  },
```

## febedb.frontend

Let's make the febedb.backend run in docker also.

- Right click the febedb.backend > Add > Docker Support
- Choose linux

If we leave it as-is, we won't control what port will be handed out, so we won't be able to enter that port in the appSettings.json.

This is where the second set of ports come in.

By now, I think you know the drill:

| project | https | http |
| ------- | --- | --- |
| febedb.backend | 5213 | 5210 |
| febedb.frontend | 5223 | 5220 |

febedb.backend:

Properties > launchSettings.json

```json
    "Docker": {
      "commandName": "Docker",
      "launchBrowser": true,
      "launchUrl": "{Scheme}://{ServiceHost}:{ServicePort}/swagger",
      "environmentVariables": {
        "ASPNETCORE_URLS": "https://+:443;http://+:80",
        "ASPNETCORE_HTTPS_PORT": "5213"
      },
      "publishAllPorts": true,
      "httpPort": 5210,
      "useSSL": true,
      "sslPort": 5213
    }
```

febedb.frontend:

Properties > launchSettings.json

```json
    "Docker": {
      "commandName": "Docker",
      "launchBrowser": true,
      "launchUrl": "{Scheme}://{ServiceHost}:{ServicePort}",
      "environmentVariables": {
        "ASPNETCORE_URLS": "https://+:443;http://+:80",
        "ASPNETCORE_HTTPS_PORT": "5223"
      },
      "publishAllPorts": true,
      "httpPort": 5220,
      "useSSL": true,
      "sslPort": 5223
    }
```

appSettings.json

```json
  "Settings": {
    "BackendUrl": "https://localhost:5213"
  },
```

Select Multiple Startup Projects and Start.

Yep.... same thing.

It's because for your browser, localhost *is* localhost, but for each container, localhost is their own little localhost bubble.

In the febedb.frontend > Services > WeatherService, wrap the ```response = await client.GetAsync("/api/WeatherForecast");``` in a try catch:

```csharp
 try
            {
                response = await client.GetAsync("/api/WeatherForecast");
            }
            catch (Exception ex)
            {
                forecast = new Data.WeatherForecast()
                {
                    Id = -1,
                    Date = DateTime.Now,
                    TemperatureC = 0,
                    Summary = ex.Message
                };

                return forecast;
            }
```

Both pages will show up with a valid certificate, valid content, but the befedb.frontend will diplay a nasty forecast of "0 - Cannot assign requested address (localhost:5213)"

Because from that container's point of view, localhost is itself not your workstation.

This is where step 2 ends and the step 3 begins: docker-compose.
