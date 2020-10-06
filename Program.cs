using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using OpenQA.Selenium;
using OpenQA.Selenium.Firefox;
using System.Net;
using System.IO;
using OpenQA.Selenium.Remote;
using System.Collections.ObjectModel;
using System.Security.Permissions;
using System.Diagnostics;
using OpenQA.Selenium.Html5;
using Microsoft.VisualBasic;
using Microsoft.VisualBasic.FileIO;

namespace ConsoleApplication3
{
    class Program
    {
        static void Main(string[] args)
        {

            /******************1 to 2*********************/
            List<string> certNum = new List<string>();
            List<string> bankName = new List<string>();
            using (TextFieldParser parser = new TextFieldParser(@"C:\Users\sara\Desktop\failedbanks.csv")) 
            {
                parser.TextFieldType = FieldType.Delimited;
                parser.SetDelimiters(",");
                while (!parser.EndOfData)
                {
                    string[] fields = parser.ReadFields();
                    certNum.Add(fields[3]);
                    bankName.Add(fields[0]);
                }
            }
            List<string> bankInfo = BankInfo(certNum, bankName);
            List<string> BankNameUrl = new List<string>(bankInfo);
            BankNameUrl = bankInfo.ToList();

            using (var writer = new CsvFileWriter(@"C:\Users\sara\Desktop\SecEco_Project\bankNameUrls.csv"))
            {
                for (int row = 0; row < 100; row++)
                {
                    writer.WriteRow(BankNameUrl);
                }
            }

            Console.Read(); 
        }

        /************************************************/
        public static void AlertDismiss(FirefoxDriver driver)
        {
            try
            {
                driver.SwitchTo().Alert().Dismiss();
            }
            catch (NoAlertPresentException Ex)
            {
            }
        }

      /*************************************************/
        public static List<string> BankInfo(List<string> certNumber, List<string> bankName)
        {
            List<string> bankCol = new List<string>();
            for (int i = 1; i < certNumber.Count()-1; i++){

                var driver1 = new FirefoxDriver();
                string url_1 = "https://research.fdic.gov/bankfind/results.html?fdic=" + certNumber[i];
                driver1.Navigate().GoToUrl(url_1);

                var driver2 = new FirefoxDriver();
                string url_2 = "https://research.fdic.gov/bankfind/detail.html?bank="+ certNumber[i]+"&name=" + bankName[i] +"&searchName=&searchFdic=" + certNumber[i]+"&city=&state=&zip=&address=&searchWithin=&activeFlag=&tabId=2";
                driver2.Navigate().GoToUrl(url_2);

               foreach (OpenQA.Selenium.Cookie c in driver1.Manage().Cookies.AllCookies)
                {
                    driver2.Manage().Cookies.AddCookie(new OpenQA.Selenium.Cookie(c.Name, c.Value, c.Domain.TrimStart('.'), c.Path, c.Expiry));
                }
                driver2.Navigate().Refresh();

                /******************2 to 3*********************/
                var driver3 = new FirefoxDriver();
                string url_3 = "https://www5.fdic.gov/idasp/confirmation_outside.asp?inCert1=" + certNumber[i];
                driver3.Navigate().GoToUrl(url_3);
                foreach (OpenQA.Selenium.Cookie c in driver2.Manage().Cookies.AllCookies)
                {
                    driver3.Manage().Cookies.AddCookie(new OpenQA.Selenium.Cookie(c.Name, c.Value, c.Domain.TrimStart('.'), c.Path, c.Expiry));
                }

                AlertDismiss(driver3);
                string url_4 = "https://www5.fdic.gov/idasp/advSearchConfirmation.asp?inCert1=" + certNumber[i];
                driver3.Navigate().GoToUrl(url_4);
                string DEMO_PAGE = driver3.PageSource;
                IList<IWebElement> webElements = driver3.FindElements(By.TagName("a"));
                string bankUrl = webElements[5].Text;
                bankCol.Add(bankUrl);
                driver1.Quit();
                driver2.Quit();
                driver3.Quit();
            }
            return (bankCol);
            
        
        }// End of BankInfo Method
    }
}
