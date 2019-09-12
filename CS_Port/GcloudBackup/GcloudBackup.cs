using System;
using Utilities;

namespace GcloudBackup
{
    class GcloudBackup
    {
        static void Main()
        {
           //Credentials creds = new Credentials(".\\Credentials\\", "testcreds");

            //creds.genCredentials();

            //Console.WriteLine();
            //Console.WriteLine(creds.User + " || " + creds.Password);
            //Console.ReadKey();

            Credentials creds = new Credentials(".\\Credentials\\", "testcreds");

            creds.loadCredentials(); 

            Console.WriteLine();
            Console.WriteLine(creds.User + " || " + creds.Password);
            Console.ReadKey();
        }
    }
}