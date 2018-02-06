using System;
using Microsoft.Azure.Devices;
using Microsoft.Azure.Devices.Common.Exceptions;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.IO;
using Newtonsoft.Json;


namespace CreateDevices
{
    class Program
    {
        static RegistryManager registryManager;
        static string connectionString;
        static List<device> _devices = new List<device>();
        static string fileName = Environment.CurrentDirectory.ToString() + "\\devices.json";


        private static async Task RemoveDeviceAsync(string deviceId)
        {
            await registryManager.RemoveDeviceAsync(deviceId);
        }
        private static async Task AddDeviceAsync(string name, string devicetype)
        {
            string deviceId = name;
            Device device = null;
            try
            {
                device = await registryManager.AddDeviceAsync(new Device(deviceId));

                _devices.Add(new CreateDevices.device()
                {
                    DeviceId = device.Id,
                    DeviceType = devicetype,
                    DeviceKey = device.Authentication.SymmetricKey.PrimaryKey,
                    MessageType = "standard"
                });
            }
            catch (DeviceAlreadyExistsException ex)
            {
                Console.Write("'{0}', ", ex.Message);
            }
        }

        static void Main(string[] args)
        {
            if (args.Length == 0)
            {
                System.Console.WriteLine("Action [Add, Remove], Number of device types, and number per device type., and IoT Hub ConnectionString");
                System.Console.WriteLine("Usage: CreateDevices 4  5 HostName=<connection string>");
            }
            else
            {
                string action = args[0].ToLower();
                connectionString = args[3];
                registryManager = RegistryManager.CreateFromConnectionString(connectionString);

                switch (action)
                {
                    case "add":
                        {
                            AddDevices(args);
                            break;
                        }
                    case "remove":
                        {
                            RemoveDevices(args);
                            break;
                        }
                    default:
                        break;

                }

                Console.ReadLine();
            }
        }

        private static void RemoveDevices(string[] args)
        {
            string deviceJson = File.ReadAllText(fileName);
            dynamic devices = JsonConvert.DeserializeObject(deviceJson);

            foreach (var d in devices)
            {
                Console.WriteLine("Removing Device: " + d.DeviceId);
                registryManager.RemoveDeviceAsync(d.DeviceId.ToString()).Wait();
            }
        }
        private static void AddDevices(string[] args)
        {
            int iDeviceTypes = Convert.ToInt32(args[1]);
            int iNumberPerDevice = Convert.ToInt32(args[2]);
            string deviceName = null;

            for (int i = 0; i < iDeviceTypes; i++)
            {
                for (int d = 0; d < iNumberPerDevice; d++)
                {
                    string deviceType = "DeviceType-" + i;
                    deviceName = deviceType + "-" + d;
                    AddDeviceAsync(deviceName, deviceType).Wait();
                }

            }

            using (StreamWriter file = File.CreateText(fileName))
            {
                JsonSerializer serializer = new JsonSerializer();
                serializer.Serialize(file, _devices);
            }
            Console.WriteLine("Device file written to: " + fileName);
        }
    }

    public class device
    {
        public string DeviceId { get; set; }
        public string DeviceKey { get; set; }
        public string DeviceType { get; set; }
        public string MessageType { get; set; }
    }
}
