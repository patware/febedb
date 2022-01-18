using febedb.frontend.Models;
using febedb.frontend.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;

namespace febedb.frontend.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly IWeatherService _weatherService;
        private Settings _settings { get; }

        public HomeController(ILogger<HomeController> logger, Services.IWeatherService weatherService, IOptions<Settings> settings)
        {
            _logger = logger;
            this._weatherService = weatherService;
            _settings = settings.Value;
        }

        public async Task<IActionResult> Index()
        {
            var viewModel = new Models.HomeIndexViewModel
            {
                CurrentWeather = await _weatherService.GetWeatherAsync(),
                BackEndUrl = _settings.BackendUrl
            };

            return View(viewModel);
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
