using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Net.Http.Json;
using Microsoft.Extensions.Options;

namespace febedb.frontend.Services
{
    public class WeatherService : IWeatherService
    {
        private Settings _settings { get; }
        public WeatherService(IOptions<Settings> settings)
        {
            _settings = settings.Value;
        }

        public async Task<Data.WeatherForecast> GetWeatherAsync()
        {
            var client = new HttpClient
            {
                BaseAddress = new Uri(_settings.BackendUrl)
            };

            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(
                new MediaTypeWithQualityHeaderValue("application/json"));

            Data.WeatherForecast forecast = null;

            HttpResponseMessage response = null;

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
            
            if (response != null && response.IsSuccessStatusCode)
            {
                var forecasts = await response.Content.ReadFromJsonAsync<IEnumerable<Data.WeatherForecast>>();

                forecast = forecasts.FirstOrDefault();
            }

            return forecast;
        }
    }
}
