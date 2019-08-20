using System;
using System.IO;

namespace Utilities {

    class Utils
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

        public Credentials(string cDir)
        {
            credDir = cDir;
            usrFile = Path.Combine(cDir, "Username");
            usrFile = Path.Combine(cDir, "Password");
        }
        public Boolean chkCredentials() => File.Exists(usrFile) && File.Exists(pwFile);


    }
}