using System;
using Security;


namespace GcloudBackup
{
    class GcloudBackup
    {
        static void Main()
        {
            Credentials creds = new Credentials(".\\Credentials\\", "testcreds");
            //creds.genCredentials();           

            //creds.loadCredentials(); 

            //Console.WriteLine();
            //Console.WriteLine(creds.User + " || " + creds.usePassword());
            //Console.ReadKey();

            Console.Write("*");
            Console.Write("*");
            Console.Write("\r");
            Console.ReadKey();

        }
    }
}