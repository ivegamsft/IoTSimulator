using System;
using System.Text;
using Microsoft.Azure.Devices.Client;
using Newtonsoft.Json;
using System.Threading.Tasks;

namespace CoreSimulatedDevice
{
    class Program
    {

        static DeviceClient deviceClient;
        static string iotHubUri = null;
        static string deviceKey = null;
        static string deviceName = null;
        static string deviceLatitude = null;
        static string deviceLongitude = null;

        private static async Task SendDeviceToCloudMessagesAsync()
        {
            double minTemperature = 20;
            double minHumidity = 60;
            string[] messageTypes = new string[4] { "standard", "heartbeat", "telemetry", "event" };

            Random rand = new Random();

            while (true)
            {
                double currentTemperature = minTemperature + rand.NextDouble() * 15;
                double currentHumidity = minHumidity + rand.NextDouble() * 20;
                int msgType = rand.Next(messageTypes.Length);

                var telemetryDataPoint = new
                {
                    messageId = Guid.NewGuid().ToString(),
                    timestamp = System.DateTime.UtcNow.ToString(),
                    messageType = messageTypes[msgType],
                    deviceId = deviceName,
                    temperature = currentTemperature,
                    humidity = currentHumidity
                };
                var messageString = JsonConvert.SerializeObject(telemetryDataPoint);
                var message = new Message(Encoding.ASCII.GetBytes(messageString));
                message.Properties.Add("temperatureAlert", (currentTemperature > 30) ? "true" : "false");

                Console.WriteLine("{0} > Sending message: {1}", DateTime.Now, messageString);

                await deviceClient.SendEventAsync(message);
                await Task.Delay(5000);
            }
        }
        static void Main(string[] args)
        {
            iotHubUri = Environment.GetEnvironmentVariable("IOTHUB_URI");
            deviceName = Environment.GetEnvironmentVariable("DEVICE_NAME");
            deviceKey = Environment.GetEnvironmentVariable("DEVICE_KEY");

            Console.WriteLine("Device Name: " + deviceName);
            Console.WriteLine("Device Key: " + deviceKey);
            try
            {
                deviceClient = DeviceClient.Create(iotHubUri, new DeviceAuthenticationWithRegistrySymmetricKey(deviceName, deviceKey), TransportType.Mqtt);
                SendDeviceToCloudMessagesAsync().Wait();
            }
            catch (Exception ex)
            {
                Console.WriteLine("Exception Source: " + ex.InnerException.Source);
                Console.WriteLine("Exception Message: " + ex.InnerException.Message);
                Console.WriteLine("Exception InnerException: " + ex.InnerException.InnerException);
                Console.WriteLine("Exception StackTrace: " + ex.InnerException.StackTrace);
            }

        }
    }
}
