using System;
using System.IO;
using System.Text;
using System.Security.Cryptography;
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

    [Serializable]
    class Credentials
    {
        private readonly string credDir;
        private readonly string credFile;
        private string user;
        private string password;
        private static readonly byte[] entropy = { 9, 2, 4, 1, 3, 5, 0 };

        public string User { get => user; set => user = value; }

        public string Password {
            // We make an accessor to store the password in case we want to set credentials in interactive mode
            get {
                return !(String.IsNullOrEmpty(password)) ? "Password is encrypted so it cannot be shown." : "";
            }

            set => password = value;
        }

        public Credentials(string cDir = "", string fileName = "")
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
            try
            {
                Stream fileStream = File.OpenWrite(this.credFile);
                BinaryFormatter binFormatter = new BinaryFormatter();

                binFormatter.Serialize(fileStream, this);
                fileStream.Close();
            }
            catch (DirectoryNotFoundException)  {
                Directory.CreateDirectory(this.credDir);
                saveCredentials(); // We call ourselves again
            }


        }

            public void genCredentials()
        {
            string user;
            string passwd;

            Console.WriteLine("Introduce your credentials: ");

            Console.Write("\tUser: ");
            user = Console.ReadLine();

            Console.Write("\tPassword: ");
            passwd = encrypt(getPassword()); // We save the value already encrypted, so nobody can steal it from memory

            this.User = user;
            this.Password = passwd;

            saveCredentials();

        }

        private Boolean chkCredentials() => File.Exists(this.credFile);

        public Boolean loadCredentials()
        {
            if (chkCredentials())
            {

                try
                {
                    Credentials tmpCreds = new Credentials();

                    Stream fileStream = File.OpenRead(this.credFile);
                    BinaryFormatter binFormatter = new BinaryFormatter();

                    tmpCreds = (Credentials)binFormatter.Deserialize(fileStream);
                    fileStream.Close();

                    this.User = tmpCreds.user;
                    this.Password = tmpCreds.password;

                    Console.WriteLine("Credentials were successfully loaded");
                    return true;
                }
                catch (System.Runtime.Serialization.SerializationException)
                {
                    Console.WriteLine("Credentials' file is corrupted. Please regenerate the credentials or provide another file.");
                    Console.ReadKey();
                    Environment.Exit(1);
                }
            }
            Console.WriteLine("Credentials were not found.");
            Console.ReadKey();
            return false;
        }                


    }
}