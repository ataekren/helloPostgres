using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Microsoft.AspNetCore.Mvc;
using Npgsql;

namespace HelloPostgres.Controllers;

[ApiController]
[Route("[controller]")]
public class HelloController : ControllerBase
{
    private readonly IConfiguration _configuration;

    public HelloController(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    [HttpGet]
    public async Task<IActionResult> Get()
    {
        try
        {
            var keyVaultUri = Environment.GetEnvironmentVariable("KEYVAULT_URI");

            if (string.IsNullOrEmpty(keyVaultUri))
            {
                return StatusCode(500, "Key Vault URI not found. Please set KEYVAULT_URI environment variable.");
            }

            Console.WriteLine($"Key Vault URI: {keyVaultUri}");

            var client = new SecretClient(new Uri(keyVaultUri), new DefaultAzureCredential());
            KeyVaultSecret secret = await client.GetSecretAsync("ConnectionString");
            string connectionString = secret.Value;

            Console.WriteLine($"Connection string: {connectionString}");

            Console.WriteLine(connectionString);

            using var connection = new NpgsqlConnection(connectionString);
            connection.Open();
            connection.Close();

            return Ok("Successfully connected to Postgres!");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"{ex.Message}");
            return StatusCode(500, $"Database connection error: {ex.Message}");
        }
    }
} 