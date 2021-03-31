using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace febedb.backend.Services
{
    public class TemperatureAppreciationService : ITemperatureAppreciation
    {

        public string Summerize(int temperatureC)
        {
            if (temperatureC <= -50)
                return "Insane cold";
            if (temperatureC <= -40)
                return "Crazy cold";
            if (temperatureC <= -20)
                return "Super cold";
            else if (temperatureC <= -10)
                return "Very cold";
            else if (temperatureC <= 0)
                return "Freezing";
            else if (temperatureC <= 5)
                return "Cold";
            else if (temperatureC <= 10)
                return "Chilly";
            else if (temperatureC <= 15)
                return "Cool";
            else if (temperatureC <= 28)
                return "Warm";
            else if (temperatureC <= 34)
                return "Hot";
            else if (temperatureC <= 38)
                return "Scorching";
            else if (temperatureC <= 42)
                return "Stifling";
            else
                return "Sweltering";
        }

    }
}
