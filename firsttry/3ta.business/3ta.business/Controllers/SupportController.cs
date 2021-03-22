using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using _3ta.business.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace _3ta.business.Controllers
{
    public class SupportController : Controller
    {
        private readonly ILogger<SupportController> logger;
        private readonly IOptions<AppSettings> appSettings;

        public SupportController(ILogger<SupportController> logger, IOptions<AppSettings> settings)
        {
            this.logger = logger;
            appSettings = settings;
        }

        public IActionResult Index()
        {
            return View();
        }

        public IActionResult Ping()
        {
            return new ContentResult() 
            { 
                Content = "Pong"
                , ContentType = "text/plain"
            };
        }

        public IActionResult Trace()
        {
            logger.LogInformation("Trace started");
            var l = new List<Data.TraceResult>();
            var tr = new TraceResult(new Guid("{0F643167-0C83-4D34-9D67-4FB9DA16E027}"))
            {
                Name = "3ta.business"
            };
            l.Add(tr);

            var gRPCtr = new TraceResult(new Guid("{A3A78F8A-CE39-430F-AA2D-59CC8B9DB235}"))
            {
                Name = "3ta.business.gRPC"  
            };
            l.Add(gRPCtr);

            logger.LogInformation("Calling gRPC for url:[{0}]", appSettings.Value.BusinessUrl);
            using var channel = Grpc.Net.Client.GrpcChannel.ForAddress(appSettings.Value.BusinessUrl);
            var client = new Greeter.GreeterClient(channel);
            var hr = new HelloRequest { Name = System.Reflection.Assembly.GetExecutingAssembly().GetName().Name };
            var reply = client.SayHello(hr);
            gRPCtr.Finish(reply.Message);

            tr.Finish(string.Empty);

            logger.LogInformation("Trace finished");

            return new JsonResult(l);
        }
    }
}
