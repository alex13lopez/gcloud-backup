using System;
using System.IO;
using System.Text;
using System.Security.Cryptography;

namespace Utilities
{

    abstract class Utils
    {

        public static string getTime()
        {
            return DateTime.Now.ToString("dd'-'MM'-'YYYY '@' HH':'mm");
        }      

    }

    class Credentials
    {
        private string credDir;
        private string usrFile;
        private string pwFile;
        private static readonly byte[] entropy = { 9, 2, 4, 1, 3, 5, 0 };


        public Credentials(string cDir)
        {
            credDir = cDir;
            usrFile = Path.Combine(cDir, "Username");
            usrFile = Path.Combine(cDir, "Password");
        }

        private string encrypt(string txt)
        {                        
            return Convert.ToBase64String(ProtectedData.Protect(Encoding.UTF8.GetBytes(txt), entropy, DataProtectionScope.CurrentUser));
        }

        private string decrypt(string encStr)
        {            
            return Encoding.UTF8.GetString(ProtectedData.Unprotect(Convert.FromBase64String(encStr), entropy, DataProtectionScope.CurrentUser));
        }

        private static string getPassword()
        {
            Console.WriteLine();
            Console.Write("Enter password: ");

            string password = string.Empty;

            ConsoleKeyInfo keyInfo = Console.ReadKey(true);

            while (keyInfo.Key != ConsoleKey.Enter)
            {
                Console.Write("*");
                password += keyInfo.KeyChar;
                keyInfo = Console.ReadKey(true);
            }

            return password;
        }

        private void saveCredentials(string usr, string passwd)
        {

        }

        public void genCredentials()
        {
            string user;
            string passwd;

            Console.WriteLine("Introduce your credentials: ");

            Console.Write("\t\tUser: ");
            user = Console.ReadLine();

            Console.WriteLine("\t\tPassword: ");
            passwd = encrypt(getPassword()); // We save the value already encrypted, so nobody can steal it from memory

            saveCredentials(user, passwd);

        }

        

        public Boolean chkCredentials() => File.Exists(usrFile) && File.Exists(pwFile);


    }
}