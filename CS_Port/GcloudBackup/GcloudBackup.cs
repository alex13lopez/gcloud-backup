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

            creds.loadCredentials(); 

            Console.WriteLine();
            Console.WriteLine("User: " + creds.User + "\nPassword: " + creds.Password);
            Console.ReadKey();

         

        }
    }
}