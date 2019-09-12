using System;
using System.IO;
using System.Text;
using System.Security.Cryptography;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;

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
        private string credFile;
        private string user;
        private string password;
        private static readonly byte[] entropy = { 9, 2, 4, 1, 3, 5, 0 };

        public string User { get => user; set => user = value; }

        public string Password {
            // We make an accessor to store the password in case we want to set credentials in interactive mode
            get => "Password is encrypted so it cannot be shown.";
            set => password = value;
        }

        public Credentials(string cDir, string fileName)
        {
            credDir = cDir;
            credFile = Path.Combine(cDir, fileName);
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

        private void saveCredentials()
        {
            File credentialsFile = new File(this.credFile);
            Stream fileStream = credentialsFile.Open(FileMode.Create);
            BinaryFormatter binFormatter = new BinaryFormatter();

            binFormatter.Serialize(fileStream, this);
            fileStream.Close();

        }

        private string loadCredentials()
        {
            if (chkCredentials())
            {
                
                File credentialsFile = new File(this.credFile);
                Stream fileStream = credentialsFile.Open(FileMode.Open);
                BinaryFormatter binFormatter = new BinaryFormatter();

                this = (Credentials)binFormatter.Deserialize(fileStream); // I have to try if this works... Idk if it will let me overwrite the current instance of Credentials()
                fileStream.Close();

                return "Credentials were successfully loaded";
            }
            return "Credentials were not found.";
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

            this.User = user;
            this.Password = passwd;

            saveCredentials();

        }

        public Boolean chkCredentials() => File.Exists(this.credFile);


    }
}