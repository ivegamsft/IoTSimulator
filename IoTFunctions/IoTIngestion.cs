//#r "Newtonsoft.Json"
//#r "Microsoft.ServiceBus"

using System;
using System.Diagnostics;
using Microsoft.ServiceBus;
using Microsoft.ServiceBus.Messaging;
using Newtonsoft.Json;
using System.IO;
using System.Text;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.DataContracts;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.Extensions.Logging;

private static string key = TelemetryConfiguration.Active.InstrumentationKey = System.Environment.GetEnvironmentVariable("APPINSIGHTS_INSTRUMENTATIONKEY", EnvironmentVariableTarget.Process);
private static TelemetryClient telemetry = new TelemetryClient() { InstrumentationKey = key };


[FunctionName("AILogger")]
//public static void Run(string myEventHubMessage, TraceWriter log)
public static void Run(string myIoTHubMessage, out string outputEventHubMessage, TraceWriter log)
{
    log.Info($"FuncIngest message: {myIoTHubMessage}");

    Stopwatch sw = new Stopwatch();
    sw.Start();

    string sStartTime = DateTime.UtcNow.ToString("MM:dd:yyyy:HH:mm:ss:fff");
    dynamic data = JsonConvert.DeserializeObject(myEventHubMessage);
    outputEventHubMessage = myIoTHubMessage;
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

    using (var operation = telemetry.StartOperation<RequestTelemetry>("ai-iot2-logger"))
    {
        telemetry.Context.Operation.Id = data.messageId;
        telemetry.Context.Operation.Name = "fa-iot2-srp-FuncIngest";
        var dimensions = new Dictionary<string, string> { { "messageType", data.messageType.ToString() }, { "elapsedTime", sElapsedTime }, { "startTime", sStartTime }, { "endTime", sEndTime } };
        var measurements = new Dictionary<string, double> { { "elapsedTime", dElapsed } };
        telemetry.TrackEvent(data.deviceId.ToString(), dimensions, measurements);

    }
}
