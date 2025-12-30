//// Test: Compare performance with and without proxy

import gleam/int
import gleam/io
import gleam/list
import gleam/string

@external(erlang, "yfinance_http_native", "http_get")
fn http_get_native(
  url: String,
  timeout: Int,
  proxy_config: #(String, Int),
) -> Result(#(Int, String), String)

pub fn main() {
  io.println("=== Test: Performance Comparison ===")

  let url = "https://www.wikipedia.org"
  let timeout = 10_000
  let iterations = 3

  io.println("URL: " <> url)
  io.println("Iterations: " <> int.to_string(iterations))
  io.println("")
  io.println(
    "Note: This test makes " <> int.to_string(iterations) <> " HTTP requests",
  )
  io.println("      (with proxy only - non-proxy may have SSL issues)")
  io.println("")

  // Test with proxy (127.0.0.1:7890)
  io.println("--- With Proxy (127.0.0.1:7890) ---")
  let with_proxy_results =
    list.range(1, iterations)
    |> list.map(fn(i) {
      case http_get_native(url, timeout, #("127.0.0.1", 7890)) {
        Ok(#(status_code, body)) -> {
          io.println(
            "  Request "
            <> int.to_string(i)
            <> ": Success ("
            <> int.to_string(status_code)
            <> ", "
            <> int.to_string(string.length(body))
            <> " bytes)",
          )
          #(status_code, string.length(body))
        }
        Error(error_msg) -> {
          io.println(
            "  Request " <> int.to_string(i) <> ": Failed - " <> error_msg,
          )
          #(0, 0)
        }
      }
    })

  let with_proxy_success =
    with_proxy_results |> list.filter(fn(r) { r.0 > 0 }) |> list.length
  io.println(
    "  Successful requests: "
    <> int.to_string(with_proxy_success)
    <> "/"
    <> int.to_string(iterations),
  )

  // Summary
  io.println("")
  io.println("--- Summary ---")
  io.println(
    "  With proxy: "
    <> int.to_string(with_proxy_success)
    <> "/"
    <> int.to_string(iterations)
    <> " successful",
  )

  case with_proxy_success == iterations {
    True -> io.println("  ✓ All requests succeeded via proxy!")
    False -> io.println("  ℹ Some requests failed")
  }

  io.println("")
}
