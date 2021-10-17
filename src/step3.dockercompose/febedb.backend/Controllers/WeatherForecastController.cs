using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using febedb.backend.Models;
using febedb.backend.Services;

namespace febedb.backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class WeatherForecastController : ControllerBase
    {
        private readonly WeatherContext _context;
        private readonly ITemperatureAppreciation _temperatureAppreciation;

        public WeatherForecastController(WeatherContext context, Services.ITemperatureAppreciation temperatureAppreciation)
        {
            _context = context;
            _temperatureAppreciation = temperatureAppreciation;
        }

        // GET: api/WeatherForecast
        [HttpGet]
        public async Task<ActionResult<IEnumerable<WeatherForecast>>> GetWeatherForecast()
        {
            await Task.CompletedTask;

            //return new List<WeatherForecast>(new[] { new WeatherForecast() { 
            //    Id = 123,
            //    Date = DateTime.Now,
            //    TemperatureC = 23,
            //    Summary = "Fake temperature"
            //} });


            var l = await _context.WeatherForecast.ToListAsync();

            l.ForEach(i => i.Summary = _temperatureAppreciation.Summerize(i.TemperatureC));

            return l;

        }

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

        // PUT: api/WeatherForecast/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutWeatherForecast(int id, WeatherForecast weatherForecast)
        {
            if (id != weatherForecast.Id)
            {
                return BadRequest();
            }

            _context.Entry(weatherForecast).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!WeatherForecastExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // POST: api/WeatherForecast
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<WeatherForecast>> PostWeatherForecast(WeatherForecast weatherForecast)
        {
            _context.WeatherForecast.Add(weatherForecast);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetWeatherForecast), new { id = weatherForecast.Id }, weatherForecast);
        }

        // DELETE: api/WeatherForecast/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteWeatherForecast(int id)
        {
            var weatherForecast = await _context.WeatherForecast.FindAsync(id);
            if (weatherForecast == null)
            {
                return NotFound();
            }

            _context.WeatherForecast.Remove(weatherForecast);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool WeatherForecastExists(int id)
        {
            return _context.WeatherForecast.Any(e => e.Id == id);
        }
    }
}
