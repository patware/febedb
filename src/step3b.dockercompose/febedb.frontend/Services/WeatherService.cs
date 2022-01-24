using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Net.Http.Json;
using Microsoft.Extensions.Options;
using Microsoft.Extensions.Logging;

namespace febedb.frontend.Services
{
    public class WeatherService : IWeatherService
    {
        private Settings _settings { get; }
        public ILogger<WeatherService> Logger { get; }

        public WeatherService(IOptions<Settings> settings, ILogger<WeatherService> logger)
        {
            _settings = settings.Value;
            Logger = logger;
        }

        public async Task<Data.WeatherForecast> GetWeatherAsync()
        {
            Logger.LogInformation("BackendUrl: {BackendUrl}", _settings.BackendUrl);

            Data.WeatherForecast forecast = new Data.WeatherForecast() { 
                Id = -1,
                Date = DateTime.Now,
                Summary = $"New HttpClient to {_settings.BackendUrl}",
                TemperatureC = 0
            };

            Logger.LogInformation("new HttpClient");

            var client = new HttpClient
            {
                BaseAddress = new Uri(_settings.BackendUrl)
            };

            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(
                new MediaTypeWithQualityHeaderValue("application/json"));

            HttpResponseMessage response;

            try
            {
                Logger.LogInformation("client.GetAsync(/api/WeatherForecast)");
                response = await client.GetAsync("/api/WeatherForecast");
                Logger.LogInformation("client.GetAsync(/api/WeatherForecast) PASS");
            }
            catch (Exception ex)
            {
                Logger.LogError("client.GetAsync(/api/WeatherForecast) FAIL {Message}", ex.Message);
                forecast.Summary = ex.Message;

                return forecast;
            }
            
            if (response != null && response.IsSuccessStatusCode)
            {
                Logger.LogInformation("ReadFromJsonAsync");
                var forecasts = await response.Content.ReadFromJsonAsync<IEnumerable<Data.WeatherForecast>>();

                Logger.LogInformation("First or Default");
                forecast = forecasts.FirstOrDefault();
                Logger.LogInformation("Done");
            }
            else
            {
                Logger.LogWarning("Unexpected response: {StatusCode}", response.StatusCode);
                forecast.Summary = $"Unexpected statusCode: {response.StatusCode}";
            }

            return forecast;
        }
    }
}
