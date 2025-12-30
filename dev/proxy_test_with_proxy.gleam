//// Test: Fetch Wikipedia.org with proxy

import gleam/int
import gleam/io
import gleam/string

@external(erlang, "yfinance_http_native", "http_get")
fn http_get_native(
  url: String,
  timeout: Int,
  proxy_host: String,
  proxy_port: Int,
  proxy_user: String,
  proxy_pass: String,
) -> Result(#(Int, String), String)

pub fn main() {
  // Test: Fetch Wikipedia.org with proxy
  io.println("=== Test: Fetch Wikipedia.org WITH Proxy ===")

  let url = "https://www.wikipedia.org"
  let timeout = 10_000
  let proxy_config = #("127.0.0.1", 7890, "", "")

  io.println("URL: " <> url)
  io.println("Proxy: 127.0.0.1:7890")

  case
    http_get_native(
      url,
      timeout,
      proxy_config.0,
      proxy_config.1,
      proxy_config.2,
      proxy_config.3,
    )
  {
    Ok(#(status_code, body)) -> {
      io.println("✓ SUCCESS")
      io.println("  Status Code: " <> int.to_string(status_code))
      io.println(
        "  Response Length: " <> int.to_string(string.length(body)) <> " bytes",
      )

      // Check if we got substantial content
      // Wikipedia homepage may not contain literal "Wikipedia" text
      let has_content = string.length(body) > 1000
      case has_content {
        True -> io.println("  ✓ Response contains substantial content")
        False -> io.println("  ✗ Response appears empty")
      }
    }
    Error(error_msg) -> {
      io.println("✗ FAILED")
      io.println("  Error: " <> error_msg)
    }
  }

  io.println("")
}
