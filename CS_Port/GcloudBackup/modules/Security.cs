using System;
using System.IO;
using System.Text;
using System.Security;
using System.Security.Cryptography;
using System.Runtime.Serialization.Formatters.Binary;


namespace Security
{
    [Serializable]
    sealed class Credentials
    {
        private readonly string credDir;
        private readonly string credFile;
        private string password;
        private static readonly byte[] entropy = { 9, 2, 4, 1, 3, 5, 0 };

        public string User { get; set; }

        public string Password {

            get => usePassword().ToString();
            set => password = encrypt(value);
        }

        public SecureString usePassword()
        {
            SecureString securePassword = new SecureString();

            foreach(char c in decrypt(this.password))
            {
                securePassword.AppendChar(c);
            }

            return securePassword;
            
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


        public static string getPassword()
        {
            string password = string.Empty;

            ConsoleKeyInfo keyInfo = Console.ReadKey(true);

            while (keyInfo.Key != ConsoleKey.Enter)
            {
                if (keyInfo.Key != ConsoleKey.Backspace)
                {
                    Console.Write("*");
                    password += keyInfo.KeyChar;
                    keyInfo = Console.ReadKey(true);
                }
               
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
            Console.WriteLine("Introduce your credentials: ");

            Console.Write("\tUser: ");
            this.User = Console.ReadLine();

            Console.Write("\tPassword: ");
            this.Password = getPassword();

            saveCredentials();

        }

        private Boolean chkCredentials() => File.Exists(this.credFile);

        public void loadCredentials()
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

                    this.User = tmpCreds.User;
                    this.password = tmpCreds.password;

                    Console.WriteLine("Credentials were successfully loaded");
                    return;
                }
                catch (System.Runtime.Serialization.SerializationException)
                {
                    Console.WriteLine("Credentials' file is corrupted. Please regenerate the credentials or provide another file.");

                    //Console.WriteLine(e);
                    Console.ReadKey();
                    Environment.Exit(1);
                }
            }
            Console.WriteLine("Credentials were not found.");
            Console.ReadKey();
            return;
        }                


    }
}