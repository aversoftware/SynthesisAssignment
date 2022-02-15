using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synthesis.Data
{
    public class JokeContextInitializer : System.Data.Entity.DropCreateDatabaseIfModelChanges<JokeContext>
    {
        protected override void Seed(JokeContext context)
        {
            AddJokes(context);
        }

        public  void AddJokes(JokeContext context)
        {
            var path = @"wocka.json";
            var jsonJokes = System.IO.File.ReadAllText(path);
            var jokes = JsonConvert.DeserializeObject<IEnumerable<Joke>>(jsonJokes);
            if (jokes != null)
            {
                var jokeCount = context.Jokes?.Count();
                if (jokeCount == 0)
                    foreach (var batch in jokes.Chunk(100))
                    {
                        context.Set<Joke>().AddRange(batch);
                        context.ChangeTracker.DetectChanges();
                        context.SaveChanges();
                        Console.WriteLine("Seeding RDS database");
                    }
            }
        }
    }
}
