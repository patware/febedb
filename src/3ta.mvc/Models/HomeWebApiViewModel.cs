using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace _3ta.mvc.Models
{
    public class HomeWebApiViewModel
    {
        public string WebApiUrl { get; set; }

        public HomeWebApiViewModel()
        {
            Forecast = new List<WeatherForecast>();
        }

        public IList<WeatherForecast> Forecast { get; set; }

        public class WeatherForecast
        {
            public DateTime Date { get; set; }

            public int TemperatureC { get; set; }

            public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);

            public string Summary { get; set; }
        }
    }
}
