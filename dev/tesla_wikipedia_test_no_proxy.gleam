import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import yfinance/http_client
import yfinance/types

pub fn main() {
  let url = "http://httpbin.org/get"
  // Using httpbin.org which is more reliable for testing

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

  // Use no proxy
  let proxy_config = Error("No proxy")

  let config =
    types.YFinanceConfig(
      timeout: 30_000,
      max_retries: 3,
      user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
      proxy: proxy_config,
      batch_size: 10,
    )

  io.println("Testing without proxy...")
  io.println("URL: " <> url)

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

      // Print first 10 lines for verification
      let lines = string.split(response.body, "\n")
      io.println("\n=== First 10 lines of response ===")

      lines
      |> list.take(10)
      |> list.each(fn(line) { io.println("│ " <> line) })

      io.println("=== End of first lines ===")
    }
    Error(error) -> {
      io.println("❌ Error: " <> error)
    }
  }
}
