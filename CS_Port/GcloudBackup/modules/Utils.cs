using System;


namespace Utilities
{

    abstract class Utils
    {

        public static string getTime()
        {
            return DateTime.Now.ToString("dd'-'MM'-'YYYY '@' HH':'mm");
        }                

    }
}