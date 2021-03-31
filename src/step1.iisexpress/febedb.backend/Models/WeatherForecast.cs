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
