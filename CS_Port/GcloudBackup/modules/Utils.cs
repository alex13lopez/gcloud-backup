using System;

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
        private string usrFile;
        private string pwFile;
        
        public Boolean chkCredentials()
        {
            return true;
        }
    }
}