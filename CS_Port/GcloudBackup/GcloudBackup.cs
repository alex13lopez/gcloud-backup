using System;
using Utils = Utilities.Utils;

namespace GcloudBackup
{
    class GcloudBackup
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hola Dani la fecha de ahora es: " + Utils.getTime());
            Console.ReadKey();
        }
    }
}
