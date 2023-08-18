using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Threading.Tasks;

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
      var client = new HttpClient();

      client.BaseAddress = new Uri(_settings.BackendUrl);
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
}
