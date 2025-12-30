//// Test: Test different proxy ports

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
  io.println("=== Test: Different Proxy Ports ===")

  let url = "https://www.wikipedia.org"
  let timeout = 10_000
  let proxy_host = "127.0.0.1"

  // Test different ports
  let test_ports = [7890, 7891, 7892, 8080, 3128]

  io.println("URL: " <> url)
  io.println("Proxy Host: " <> proxy_host)
  io.println(
    "Testing ports: " <> string.join(list.map(test_ports, int.to_string), ", "),
  )
  io.println("")

  let results =
    test_ports
    |> list.map(fn(port) {
      io.println("Testing port " <> int.to_string(port) <> "...")

      let proxy_config = #(proxy_host, port)

      case http_get_native(url, timeout, proxy_config) {
        Ok(#(status_code, body)) -> {
          io.println("  ✓ SUCCESS - Status: " <> int.to_string(status_code))
          io.println(
            "    Content: " <> int.to_string(string.length(body)) <> " bytes",
          )
          let has_content = string.length(body) > 1000
          case has_content {
            True -> io.println("    ✓ Response contains substantial content")
            False -> io.println("    ✗ Response appears empty")
          }
          #(port, "success", status_code)
        }
        Error(error_msg) -> {
          io.println("  ✗ FAILED - " <> error_msg)
          #(port, "failed", 0)
        }
      }
    })

  io.println("")
  io.println("--- Summary ---")

  let success_count =
    results
    |> list.filter(fn(r) { r.1 == "success" })
    |> list.length

  io.println(
    "  Successful ports: "
    <> int.to_string(success_count)
    <> " / "
    <> int.to_string(list.length(test_ports)),
  )

  let successful_ports =
    results
    |> list.filter(fn(r) { r.1 == "success" })
    |> list.map(fn(r) { int.to_string(r.0) })

  case successful_ports {
    [] -> io.println("  No working proxy ports found")
    _ -> io.println("  Working ports: " <> string.join(successful_ports, ", "))
  }

  io.println("")
}
