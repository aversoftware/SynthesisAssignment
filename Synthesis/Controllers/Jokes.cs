
using Amazon;
using Amazon.SecretsManager;
using Amazon.SecretsManager.Model;

using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using Synthesis.Data;
using System.Net.NetworkInformation;
using System.Text;

namespace Synthesis
{
    [Route("api/[controller]")]
    [ApiController]
    public class JokesController : ControllerBase
    {
        private readonly ILogger<JokesController> _logger;
        private string cs;

        public JokesController(ILogger<JokesController> logger, IConfiguration configuration)
        {
            _logger = logger;
            cs = GetConnectionString(); 
        }
        public string GetConnectionString()
        { 
            //return "Initial catalog = synthesis;Server=synthesis-sql-db.cegkesrxgmvb.us-east-1.rds.amazonaws.com;user id=admin;password=76a20241fab85b8e623877ce79f664f5d59f5553e17708b97d39422ddc6dcc36;";

            string secretName = "synthesis-db-connection";
            string region = "us-east-1";
            string secret = "";

            MemoryStream memoryStream = new MemoryStream();

            IAmazonSecretsManager client = new AmazonSecretsManagerClient(RegionEndpoint.GetBySystemName(region));

            GetSecretValueRequest request = new GetSecretValueRequest();
            request.SecretId = secretName;
            request.VersionStage = "AWSCURRENT"; // VersionStage defaults to AWSCURRENT if unspecified.

            GetSecretValueResponse? response = null;

            try
            {
                response = client.GetSecretValueAsync(request).Result;
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                throw;
            }

            if (response.SecretString != null)
            {
                secret = response.SecretString;
            }
            else
            {
                memoryStream = response.SecretBinary;
                StreamReader reader = new StreamReader(memoryStream);
                secret = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(reader.ReadToEnd()));
            }

            return secret.Replace(":1433", "");
        }           

        [HttpGet("Random")]
        public Joke? Random()
        {
            Joke? randomOneLiner =null;
             using (JokeContext context = new JokeContext(cs))
            {
                Console.WriteLine("Seeding...");
                new JokeContextInitializer().AddJokes(context);

                var oneLiners = context.Jokes?.Where(joke => joke.Category == "One Liners").ToList();
                if(oneLiners?.Count>0)
                 randomOneLiner = oneLiners.OrderBy(x => Guid.NewGuid()).First();
            }
            return randomOneLiner;
        }
    }
}
