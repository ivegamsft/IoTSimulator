using System.Text;
using System.Collections.Generic;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.DataContracts;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.Extensions.Logging;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Azure.WebJobs.ServiceBus;
using System.Diagnostics;
using Newtonsoft.Json;
using System;



namespace IoTLogger
{
    public static class AILogger
    {
        [FunctionName("AILogger")]
        public static void Run([EventHubTrigger("messages", Connection = "IoT_EventHub_Connection")]string myEventHubMessage, TraceWriter log)
        {
            log.Info($"C# Event Hub trigger function processed a message: {myEventHubMessage}");

            Stopwatch sw = new Stopwatch();
            sw.Start();

            string sStartTime = DateTime.UtcNow.ToString("MM:dd:yyyy:HH:mm:ss:fff");
            dynamic data = JsonConvert.DeserializeObject(myEventHubMessage);
            sw.Stop();
            string sEndTime = DateTime.UtcNow.ToString("MM:dd:yyyy:HH:mm:ss:fff"); ;
            TimeSpan ts = sw.Elapsed;

            string sElapsedTime = String.Format("{0:00}:{1:00}:{2:00}.{3:00}", ts.Hours, ts.Minutes, ts.Seconds, ts.Milliseconds / 10);
            int iElappsed = sw.Elapsed.Milliseconds;
            double dElapsed = System.Convert.ToDouble(iElappsed);
            log.Info($"sElapsedTime: {sElapsedTime}");
            log.Info($"iElappsed: {iElappsed}");
            log.Info($"dElapsed: {dElapsed}");
            log.Info($"startTime: {sStartTime}");
            log.Info($"endTime: {sEndTime}");
        }
    }
}
