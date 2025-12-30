import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import yfinance/http_client
import yfinance/types

pub fn main() {
  // Try HTTP version instead of HTTPS to avoid SSL issues
  let url = "http://en.wikipedia.org/wiki/Tesla,_Inc."

  // Create a simple HTTP request
  let request =
    types.HttpRequest(
      method: types.GET,
      url: url,
      headers: dict.from_list([
        #(
          "User-Agent",
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        ),
      ]),
      body: Ok(""),
    )

  // Use proxy configuration (port 7890 worked in our test)
  let proxy_config =
    Ok(types.ProxyConfig(
      host: "127.0.0.1",
      port: 7890,
      username: Error(""),
      password: Error(""),
      scheme: "http",
    ))

  let config =
    types.YFinanceConfig(
      timeout: 30_000,
      max_retries: 3,
      user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
      proxy: proxy_config,
      batch_size: 10,
    )

  io.println("Fetching Tesla Wikipedia page (HTTP version)...")
  io.println("URL: " <> url)
  io.println("Using proxy: 127.0.0.1:7890")

  case http_client.execute_request(request, config, 3) {
    Ok(response) -> {
      io.println(
        "✅ Success! Status Code: " <> int.to_string(response.status_code),
      )
      io.println(
        "Response body length: "
        <> int.to_string(string.length(response.body))
        <> " characters",
      )

      // Extract and print first 15 lines
      let lines = string.split(response.body, "\n")
      io.println("\n=== First 15 lines of Tesla Wikipedia article ===")

      lines
      |> list.take(15)
      |> list.each(fn(line) { io.println("│ " <> line) })

      io.println("=== End of first 15 lines ===")
    }
    Error(error) -> {
      io.println("❌ Error fetching Wikipedia: " <> error)
      io.println("Trying with different proxy port...")

      // Try port 8080 which also worked
      let proxy_config_alt =
        Ok(types.ProxyConfig(
          host: "127.0.0.1",
          port: 8080,
          username: Error(""),
          password: Error(""),
          scheme: "http",
        ))

      let config_alt =
        types.YFinanceConfig(
          timeout: 30_000,
          max_retries: 3,
          user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
          proxy: proxy_config_alt,
          batch_size: 10,
        )

      io.println("Trying proxy port 8080...")
      case http_client.execute_request(request, config_alt, 3) {
        Ok(response) -> {
          io.println(
            "✅ Success with port 8080! Status Code: "
            <> int.to_string(response.status_code),
          )
          io.println(
            "Response body length: "
            <> int.to_string(string.length(response.body))
            <> " characters",
          )
        }
        Error(error2) -> {
          io.println("❌ Also failed with port 8080: " <> error2)
        }
      }
    }
  }
}
