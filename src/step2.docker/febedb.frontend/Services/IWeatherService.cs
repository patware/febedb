using febedb.frontend.Data;
using System.Threading.Tasks;

namespace febedb.frontend.Services
{
    public interface IWeatherService
    {
        Task<WeatherForecast> GetWeatherAsync();
    }
}