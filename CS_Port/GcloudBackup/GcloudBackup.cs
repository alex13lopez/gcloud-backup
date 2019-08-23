using System;
using Utilities;

namespace GcloudBackup
{
    class GcloudBackup
    {
        static void Main(string[] args)
        {
            Credentials creds = new Credentials(".\\Credentials\\");

            

            Console.WriteLine("Test fecha de ahora es: " + Utils.getTime());
            Console.ReadKey();
        }
    }
}
