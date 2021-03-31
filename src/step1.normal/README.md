# Step 1 - normal 3tier app in IIS Express/kestrel

Nothing wild.

## Create the projects

- Create solution
  - Template: Blank solution
  - Name: febedb
  - File: \febedb\src\step1.iisexpress\febedb.sln
- Add project: front end
  - Template: ASP.NET Core Web App (Model-View-Controller)
  - Name: febedb.frontend
  - Targe framework: .NET 5.0 (Current)
  - Configure for HTTPS: Checked
  - Enable docker: **Unchecked** -> this will be enabled in step 2
- Add project: back end
  - Template: ASP.NET Core Web API
  - Name: febedb.backend
  - Target framework: .NET 5.0 (Current)
  - Authentication type: None
  - Configure for HTTPS: Checked
  - Enable docker: **Unchecked** -> this will be enabled in step 2
  - Enable OpenAPI support: Checked
- Add project: database
  - template: SQL Server Database Project
  - name: febedb.db

## Configure ports/settings

The port numbering is: 51xx

- 1st digit: 5 - for every ports in this repo/exercise
- 2nd digit: 1 - for step 1
- 3rd digit: 1 for back end, 2 for front end (relates to loading sequence)
- 4th digit: 3 for https (like in port 443), 0 for http (like in port 80)

| app | profile | https | http |
| --- | ---     | ---  | ---   |
| back end  | IIS Express | assigned by VS | assigned by VS |
|           | kestrel     | 5113           | 5110 |
| front end | IIS Express | assigned by VS | assigned by VS |
|           | kestrel     | 5123           | 5120 |

### Back end

Update the launchSettings.json:

- Config file: febedb\src\step1.iisexpress\febedb.backend\Properties\launchSettings.json
- Update: profiles > febedb.backend: ```"applicationUrl": "https://localhost:5113;http://localhost:5110",```

Result:

```json
{
  "$schema": "http://json.schemastore.org/launchsettings.json",
  "iisSettings": {
    "windowsAuthentication": false,
    "anonymousAuthentication": true,
    "iisExpress": {
      "applicationUrl": "http://localhost:30398",
      "sslPort": 44345
    }
  },
  "profiles": {
    "IIS Express": {
      "commandName": "IISExpress",
      "launchBrowser": true,
      "launchUrl": "swagger",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    },
    "febedb.backend": {
      "commandName": "Project",
      "dotnetRunMessages": "true",
      "launchBrowser": true,
      "launchUrl": "swagger",
      "applicationUrl": "https://localhost:5113;http://localhost:5110",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}

```

### Front end

Update the launchSettings.json:

- Config file: febedb\src\step1.iisexpress\febedb.frontend\Properties\launchSettings.json
- Update: profiles > febedb.backend: ```"applicationUrl": "https://localhost:5123;http://localhost:5120",```

Result:

```json
{
  "iisSettings": {
    "windowsAuthentication": false,
    "anonymousAuthentication": true,
    "iisExpress": {
      "applicationUrl": "http://localhost:39107",
      "sslPort": 44358
    }
  },
  "profiles": {
    "IIS Express": {
      "commandName": "IISExpress",
      "launchBrowser": true,
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    },
    "febedb.frontend": {
      "commandName": "Project",
      "dotnetRunMessages": "true",
      "launchBrowser": true,
      "applicationUrl": "https://localhost:5123;http://localhost:5120",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
```

## Project Dependencies

The projects don't reference others, but they depend on others.

- Right click solution > Properties
- Project Dependencies
- Projects
  - febedb.backend depends on febedb.db
  - febedb.frontend depends on febedb.backend

## Validate

Now, it's time to verify the setup.

- Startup projects: Select febedb.backend
  - Profile: Select IIS Express
    - Run: https://localhost:44345/swagger/index.html should load in browser
  - Profile: Select febedb.backend
    - Run: https://localhost:5113/swagger/index.html should load in browser

Logs in console:

```dos
nfo: Microsoft.Hosting.Lifetime[0]
     Now listening on: https://localhost:5113
nfo: Microsoft.Hosting.Lifetime[0]
     Now listening on: http://localhost:5110
nfo: Microsoft.Hosting.Lifetime[0]
     Application started. Press Ctrl+C to shut down.
nfo: Microsoft.Hosting.Lifetime[0]
     Hosting environment: Development
nfo: Microsoft.Hosting.Lifetime[0]
     Content root path: D:\dev\Github\Patware\febedb\src\step1.iisexpress\febedb.backend
```

- Startup projects: Select febedb.frontend
  - Profile: Select IIS Express
    - Run: https://localhost:44358/ should load in browser
  - Profile: Select febedb.frontend
    - Run: https://localhost:5123/ should load in browser

Logs in console:

```dos
info: Microsoft.Hosting.Lifetime[0]
      Now listening on: https://localhost:5123
info: Microsoft.Hosting.Lifetime[0]
      Now listening on: http://localhost:5120
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Development
info: Microsoft.Hosting.Lifetime[0]
      Content root path: D:\dev\Github\Patware\febedb\src\step1.iisexpress\febedb.frontend
```

- Right click solution: Choose [Set Startup Projects]
  - Select: Multiple startup projects
    - febedb.backend : Action = Start
    - febedb.frontend: Action = Start
  - Profile: Make sure [\<Multiple Startup Projects\>] is selected
    - Start:
      - febedb.backend console should open
      - febedb.frontend console should open
      - https://localhost:5113/swagger/index.html should load in browser
    - Navigate to https://localhost:5123/: page should load

Good job. The initial setup is done.

## beyond the generated code, put real code

Beyond the basics, let's add "real code".  The WeatherForecast in the backend is a great start, let's improve it:

- Move the data to Sql
- The back end will fetch the data from sql instead of hard coded
- The front end landing page should show the current weather

### Database

In the febedb.db project:

- Add > New Folder: dbo
- Add > New Folder: dbo/Tables
- Add > New Table: dbo/Tables/WeatherForecast
  - Add columns/fields:  
    - Date DATETIME
    - TemperatureC INT

Result:

```sql
CREATE TABLE [dbo].[WeatherForecast]
(
  [Id] INT IDENTITY(1,1) PRIMARY KEY NOT NULL
  , [Date] DATETIME NOT NULL
  , [TemperatureC] INT NOT NULL
)
```

- Right click febedb.db project > Build
- Right click febedb.db project > Publish
  - Target database connection > Edit
    - Server Name: (localdb)\ProjectsV13
  - Save Profile As : D:\dev\Github\Patware\febedb\src\step1.iisexpress\febedb.db\Profiles\febedb.db.localhost.publish.xml
  - Publish
- View > SQL Server Object Explorer
  - Expand: SQL Server > (localdb)\ProjectsV13 > Databases > febedb.db should be there
    - Expand Tables: dbo.WeatherForecast should be there

### febedb.backend

The backend will fetch SQL data using Entity Framework.  I'll be following Microsoft's [documentation](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio), but instead of working with an inMemory database, we'll use a real database.

Back to the code, follow the rest of Microsoft's tutorial... Here are the instructions from Microsoft, but with a twist.  Instead of working with TodoItems, we'll work with WeatherForecast.

In this (Microsoft's) article:

- [MSDoc](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio#overview): Overview - not TodoItems but WeatherForecast
- [MSDoc](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio#prerequisites): Prerequisites - same
- [MSDoc](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio#create-a-web-project): Create a web project - same, but don't change the launchUrl
- [MSDoc](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio#add-a-model-class): Add a model class - don't add a new model class.  But do:
  - create a Models folder
  - move the WeatherForecast there
  - set class's namespace to febedb.backend.Models
  - add a field: ``` public int Id { get; set; } ```
  - mark the fields TemperatureF and "Summary" as ```[NotMapped]```

```csharp
using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace febedb.backend.Models
{
    public class WeatherForecast
    {

        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }
        public DateTime Date { get; set; }

        public int TemperatureC { get; set; }

        [NotMapped]
        public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);

        [NotMapped]
        public string Summary { get; set; }
    }
}
```

- [MSDoc](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio#add-a-database-context): Add a database context - almost the same, but WeatherContext and with WeatherForecast db set.

```csharp
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace febedb.backend.Models
{
    public class WeatherContext : DbContext
    {
        public WeatherContext(DbContextOptions<WeatherContext> options) : base(options)
        {

        }

        public DbSet<WeatherForecast> WeatherForecast { get; set; }
    }
}

```

- [MSDoc](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio#add-a-database-context): Add the TodoContext database context - Microsoft.EntityFrameworkCore
- [MSDoc](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio#register-the-database-context): Register the database context - not TodoContext but WeatherContext, and don't delete the UseSwagger.

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddDbContext<Models.WeatherContext>(opt => 
        opt.UseSqlServer("Data Source=(localdb)\\ProjectsV13;Initial Catalog=febedb.db;Integrated Security=True;Connect Timeout=30;Encrypt=False;TrustServerCertificate=False;ApplicationIntent=ReadWrite;MultiSubnetFailover=False"));
    services.AddControllers();
    services.AddSwaggerGen(c =>
    {
        c.SwaggerDoc("v1", new OpenApiInfo { Title = "febedb.backend", Version = "v1" });
    });
}

```

- [MSDoc](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio#scaffold-a-controller): Scaffold a controller
  - Delete the Models > WeatherForecastController
  - Scaffold for Weather instead: Controllers > Add Controller
    - Common > API > API Controller with actions, using Entity Framework

If you receive this error:

There was an error running the selected code generator:

'No database provider has been configured for this DbContext. A provider can be configured by overriding the 'DbContext.OnConfiguring' method or by using 'AddDbContext' on the application service provider. If 'AddDbContext' is used, then also ensure that your DbContext type accepts a DbContextOptions<TContext> object in its constructor and passes it to the base constructor for DbContext.'

It's because the scaffolding can't reach the database.  Make sure the ```ConfigureServices``` UseSqlServer has the right connection string.  Tip: View > SQL Server Object Explorer > locate the febedb.db look at the properties.  There's a connection string.

- [MSDoc](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio#update-the-posttodoitem-create-method): Update the PostTodoItem create method - same, but for GetWeatherForecast
- [MSDoc](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio#examine-the-get-methods): Examine the GET methods - same, but for weather
- [MSDoc](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio#routing-and-url-paths): Routing and URL paths - same. but for weather
- [MSDoc](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio#return-values): Return values, same but...

In our scenario, the summary is empty; it`s not stored in the db.  The value is provided by a service and is based on the temperature.  Create a service that will return the appreciation:

- In the febedb.backend
- Create a folder named Services
- Add a class TemperatureAppreciationService.  
- Add a function public ```string Summerize(int temperatureC)``` - Nothing fancy:

```csharp
        public string Summerize(int temperatureC)
        {
            if (temperatureC <= -50)
                return "Insane cold";
            if (temperatureC <= -40)
                return "Crazy cold";
            if (temperatureC <= -20)
                return "Super cold";
            else if (temperatureC <= -10)
                return "Very cold";
            else if (temperatureC <= 0)
                return "Freezing";
            else if (temperatureC <= 5)
                return "Cold";
            else if (temperatureC <= 10)
                return "Chilly";
            else if (temperatureC <= 15)
                return "Cool";
            else if (temperatureC <= 28)
                return "Warm";
            else if (temperatureC <= 34)
                return "Hot";
            else if (temperatureC <= 38)
                return "Scorching";
            else if (temperatureC <= 42)
                return "Stifling";
            else
                return "Sweltering";
        }
```

Choose your own range of cold versus warm.  By the way, the range above is based on real [Canadian weather](https://www.thecanadianencyclopedia.ca/en/article/cold-places-in-canada).  If you're a downhill skier, you'll find similar cold weather on the top of a hill in Jay Peak Vermont, USA.  I froze my face (really) skiing at -64.2F (-53.4C) and got scares to prove it. anyhow, back to our regular program.

- Extract interface from this service. Name it "ITemperatureAppreciation"
- In the Startup > ConfigureServices, register the interface/service
- ```services.AddSingleton<Services.ITemperatureAppreciation, Services.TemperatureAppreciationService>();```
- Modify the WeatherForecastController's constructor to require the ITemperatureAppreciation interface

```csharp

        private readonly WeatherContext _context;
        private readonly ITemperatureAppreciation _temperatureAppreciation;

        public WeatherForecastController(WeatherContext context, Services.ITemperatureAppreciation temperatureAppreciation)
        {
            _context = context;
            _temperatureAppreciation = temperatureAppreciation;
        }
```

- Last step, change the GetWeatherForecast function to leverage the Summarize method.

```csharp
        // GET: api/WeatherForecast
        [HttpGet]
        public async Task<ActionResult<IEnumerable<WeatherForecast>>> GetWeatherForecast()
        {
            var l = await _context.WeatherForecast.ToListAsync();

            l.ForEach(i => i.Summary = _temperatureAppreciation.Summerize(i.TemperatureC));

            return l;
        }
```

> [!NOTE] probably not the most efficient or elegant code, but it works.

You could do the same for GetWeatherForecast.

```csharp
        // GET: api/WeatherForecast/5
        [HttpGet("{id}")]
        public async Task<ActionResult<WeatherForecast>> GetWeatherForecast(int id)
        {
            var weatherForecast = await _context.WeatherForecast.FindAsync(id);

            if (weatherForecast == null)
            {
                return NotFound();
            }

            weatherForecast.Summary = _temperatureAppreciation.Summerize(weatherForecast.TemperatureC);

            return weatherForecast;
        }
```

- [MSDoc](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio#the-puttodoitem-method): The PutTodoItem method

Nothing special to do.

- [MSDoc](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio#the-deletetodoitem-method): The DeleteTodoItem method

Nothing special to do.

- [MSDoc](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio#the-deletetodoitem-method): Prevent over-posting

Nothing special to do.

- [MSDoc](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio#call-the-web-api-with-javascript): Call the web API with JavaScript

Nothing special to do.

- [MSDoc](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio#add-authentication-support-to-a-web-api-21): Add authentication support to a web API 2.1

Nothing special to do. (for now at least.)

- [MSDoc](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-5.0&tabs=visual-studio#additional-resources-21): Additional resources 2.1

Nothing special to do.

### febedb.frontend

The scenario is simple.  The FrontEnd will call the backend's WebApi to fetch the current weather and display the info on the landing page.

In the febedb.frontend project:

- Create a new folder > /Data
- Data > Add a new class: name: WeatherForecast

```csharp
using System;

namespace febedb.frontend.Data
{
    public class WeatherForecast
    {
        public int Id { get; set; }

        public DateTime Date { get; set; }

        public int TemperatureC { get; set; }

        public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);

        public string Summary { get; set; }
    }
}
```

- Create a new folder > /Services
- Services > Add a new class: name: WeatherService

We'll come back to this later.  This is just a stub.

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace febedb.frontend.Services
{
    public class WeatherService
    {
        public async Task<Data.WeatherForecast> GetWeatherAsync()
        {
            return new Data.WeatherForecast() { 
                Id = 123
                , Date = DateTime.Now
                , TemperatureC = 25
                , Summary = "Todo"
            };
        }
    }
}
```

- Extract the service's interface. name: IWeatherService

```csharp
using febedb.frontend.Data;

namespace febedb.frontend.Services
{
    public interface IWeatherService
    {
        Task<WeatherForecast> GetWeatherAsync();
    }
}
```

- Register the Service and interface in the startup's ConfigureServices

```csharp
        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddSingleton<Services.IWeatherService, Services.WeatherService>();

            services.AddControllersWithViews();
        }
```

- Models > Add a new class: name: HomeIndexViewModel

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace febedb.frontend.Models
{
    public class HomeIndexViewModel
    {
        public Data.WeatherForecast CurrentWeather { get; set; }
    }
}

```

- Controllers > HomeController
  - update the constructor to have the IWeatherService injected

```csharp
        private readonly ILogger<HomeController> _logger;
        private readonly IWeatherService _weatherService;

        public HomeController(ILogger<HomeController> logger, Services.IWeatherService weatherService)
        {
            _logger = logger;
            this._weatherService = weatherService;
        }
```

And change the Index to call the WeatherService and pass the result to a new HomeIndexViewModel.  Note, the method signature was converted to ```async Task<IActionResult>``.

```csharp
        public async Task<IActionResult> Index()
        {
            var viewModel = new Models.HomeIndexViewModel
            {
                CurrentWeather = await _weatherService.GetWeatherAsync()
            };

            return View(viewModel);
        }
```

I know... async...

- Views > Home > Index.cshtml

Add the Model to the page and show the days's forecast.

```html
@{
    ViewData["Title"] = "Home Page";
}

@model HomeIndexViewModel

<div class="text-center">
    <h1 class="display-4">Today's weather forecast</h1>
    <div class="display-2">@Model.CurrentWeather.TemperatureC - @Model.CurrentWeather.Summary</div>
</div>

```

- Reselect the febedb.frontend project as the Startup Project and Start.

An incredible UI that shows forecast.

### Contortionist's performance - the frontend joins the backend

As a reference, I'll be using Microsoft's [Call a Web API From a .Net Client (C#)](https://docs.microsoft.com/en-us/aspnet/web-api/overview/advanced/calling-a-web-api-from-a-net-client), (another contribution from [Rick Anderson](https://github.com/Rick-Anderson)).

Let's change the WeatherService to call the WebApi.  

- Head to Services > WeatherService.
- Replace the GetWeatherAsync's code with the following:

```csharp
    public class WeatherService : IWeatherService
    {
        public async Task<Data.WeatherForecast> GetWeatherAsync()
        {
            var client = new HttpClient();

            client.BaseAddress = new Uri("https://localhost:5113");
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(
                new MediaTypeWithQualityHeaderValue("application/json"));

            Data.WeatherForecast forecast = null;

            HttpResponseMessage response = await client.GetAsync("/api/WeatherForecast");
            if (response.IsSuccessStatusCode)
            {
                var forecasts = await response.Content.ReadFromJsonAsync<IEnumerable<Data.WeatherForecast>>();

                forecast = forecasts.FirstOrDefault();
            }

            return forecast;
        }

    }
```

Don't worry, we'll parameterize the Uri later.

Reset the solution to run Multiple Startup Projects (frontend + backend) and hit Start

Woot!

### Last improvement - that backend url

For this, I'm going to refer to Microsoft's [Use multiple environments in ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/environments?view=aspnetcore-5.0), especially the [Bind hierarchical configuration data using the options pattern](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/configuration/?view=aspnetcore-5.0#bind-hierarchical-configuration-data-using-the-options-pattern) yes with [Rick Anderson](https://twitter.com/RickAndMSFT), maybe I should request a [live share](https://visualstudio.microsoft.com/services/live-share/) session with him about this project ;)

- Start with the appsettings.json, add a section at the top

```json
  "Settings": {
    "BackendUrl": "https://localhost:5113"
  },
```

- Create a new class (at the root of project): name = Settings

```csharp
namespace febedb.frontend
{
    /// <summary>
    /// See appsettings.json or appsettings.{Environment}.json for the values
    /// </summary>
    public class Settings
    {
        /// <summary>
        /// appsettings.json > "Settings"
        /// </summary>
        public const string Key = "Settings";

        /// <summary>
        /// appsettings.json > Settings > BackendUrl
        /// </summary>        
        public string BackendUrl { get; set; }
    }
}

```

Simple enough.

- Startup > change the ConfigureServices to bind the config

```csharp
        public void ConfigureServices(IServiceCollection services)
        {
            services.Configure<Settings>(Configuration.GetSection(Settings.Key));

            services.AddSingleton<Services.IWeatherService, Services.WeatherService>();

            services.AddControllersWithViews();
        }
```

Update the Services > WeatherService:

- create a constructor, injecting the settings

```csharp
        private Settings _settings { get; }
        public WeatherService(IOptions<Settings> settings)
        {
            _settings = settings.Value;
        }
```

and finally,

- GetWeatherAsync() > use the settings instead of the hard code url:
 
```csharp
client.BaseAddress = new Uri(_settings.BackendUrl);
```

Make sure again that you're still running Multiple Startup Projects, and Start.

And I'm happy.
