using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using _3ta.mvc.Models;
using _3ta.mvc.Services;
using Microsoft.Extensions.Options;

namespace _3ta.mvc.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly IOptions<AppSettings> appSettings;

        public HomeController(ILogger<HomeController> logger, Microsoft.Extensions.Options.IOptions<AppSettings> appSettings)
        {
            _logger = logger;
            this.appSettings = appSettings;
        }

        public IActionResult Index()
        {
            return View();
        }
        
        public IActionResult TryConnectingTogrpc()
        {
            var g = new Models.HomeGrpcViewModel()
            {
                GrpcUrl = appSettings.Value.BusinessUrl,
                Greeting = ""
            };
            return View(g);
        }

        [HttpPost]
        public IActionResult TryConnectingTogrpc(Models.HomeGrpcViewModel model)
        {
            
            using var channel = Grpc.Net.Client.GrpcChannel.ForAddress(model.GrpcUrl);
            var client = new Greeter.GreeterClient(channel);
            var hr = new HelloRequest { Name = System.Reflection.Assembly.GetExecutingAssembly().GetName().Name };
            var reply = client.SayHello(hr);

            model.Greeting = reply.Message;

            return View(model);

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
