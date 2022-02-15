
using Amazon;
using Amazon.SecretsManager;
using Amazon.SecretsManager.Model;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace Synthesis.Data
{
    public class JokeContext : DbContext, IDisposable
    {
        public JokeContext(string conn) : base(conn)
        {
            Database.SetInitializer<JokeContext>(new JokeContextInitializer());
        }

        public DbSet<Joke>? Jokes { get; set; }
       
    }
}
