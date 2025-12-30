//// Proxy Test Examples
//// Tests the proxy functionality by making HTTP requests to Google and YouTube

import gleam/int
import gleam/io
import gleam/list
import gleam/string

// Import the native HTTP function
@external(erlang, "yfinance_http_native", "http_get")
fn http_get_native(
  url: String,
  timeout: Int,
  proxy_config: #(String, Int),
) -> Result(#(Int, String), String)

/// Test 1: Fetch Google.com without proxy
pub fn test_google_no_proxy() {
  io.println("=== Test 1: Fetch Google.com WITHOUT Proxy ===")

  let url = "https://www.google.com"
  let timeout = 10_000
  let proxy_config = #("no_proxy", 0)

  io.println("URL: " <> url)
  io.println("Proxy: None")

  case http_get_native(url, timeout, proxy_config) {
    Ok(#(status_code, body)) -> {
      io.println("✓ SUCCESS")
      io.println("  Status Code: " <> int.to_string(status_code))
      io.println(
        "  Response Length: " <> int.to_string(string.length(body)) <> " bytes",
      )

      // Check if we got Google's HTML
      case string.contains(body, "google") {
        True -> io.println("  ✓ Response contains 'google'")
        False -> io.println("  ✗ Response does not contain 'google'")
      }
    }
    Error(error_msg) -> {
      io.println("✗ FAILED")
      io.println("  Error: " <> error_msg)
    }
  }

  io.println("")
}

/// Test 2: Fetch Google.com with proxy
pub fn test_google_with_proxy() {
  io.println("=== Test 2: Fetch Google.com WITH Proxy ===")

  let url = "https://www.google.com"
  let timeout = 10_000
  let proxy_config = #("127.0.0.1", 7890)

  io.println("URL: " <> url)
  io.println(
    "Proxy: " <> proxy_config.0 <> ":" <> int.to_string(proxy_config.1),
  )

  case http_get_native(url, timeout, proxy_config) {
    Ok(#(status_code, body)) -> {
      io.println("✓ SUCCESS")
      io.println("  Status Code: " <> int.to_string(status_code))
      io.println(
        "  Response Length: " <> int.to_string(string.length(body)) <> " bytes",
      )

      // Check if we got Google's HTML
      case string.contains(body, "google") {
        True -> io.println("  ✓ Response contains 'google'")
        False -> io.println("  ✗ Response does not contain 'google'")
      }

      // Check for common proxy issues
      case string.contains(body, "Proxy") || string.contains(body, "proxy") {
        True ->
          io.println("  ⚠ Warning: Response may contain proxy-related text")
        False -> io.println("  ✓ No proxy-related issues detected")
      }
    }
    Error(error_msg) -> {
      io.println("✗ FAILED")
      io.println("  Error: " <> error_msg)

      // Provide helpful troubleshooting info
      case string.contains(error_msg, "timeout") {
        True ->
          io.println(
            "  💡 Suggestion: Proxy may not be running or is unreachable",
          )
        False ->
          case string.contains(error_msg, "econnrefused") {
            True ->
              io.println(
                "  💡 Suggestion: Connection refused - check proxy is running on port 7890",
              )
            False ->
              case string.contains(error_msg, "certificate") {
                True ->
                  io.println(
                    "  💡 Suggestion: SSL/TLS certificate issue with proxy",
                  )
                False ->
                  io.println(
                    "  💡 Suggestion: Check proxy configuration and network connectivity",
                  )
              }
          }
      }
    }
  }

  io.println("")
}

/// Test 3: Fetch YouTube.com without proxy
pub fn test_youtube_no_proxy() {
  io.println("=== Test 3: Fetch YouTube.com WITHOUT Proxy ===")

  let url = "https://www.youtube.com"
  let timeout = 10_000
  let proxy_config = #("no_proxy", 0)

  io.println("URL: " <> url)
  io.println("Proxy: None")

  case http_get_native(url, timeout, proxy_config) {
    Ok(#(status_code, body)) -> {
      io.println("✓ SUCCESS")
      io.println("  Status Code: " <> int.to_string(status_code))
      io.println(
        "  Response Length: " <> int.to_string(string.length(body)) <> " bytes",
      )

      // Check if we got YouTube's HTML
      case string.contains(body, "youtube") {
        True -> io.println("  ✓ Response contains 'youtube'")
        False -> io.println("  ✗ Response does not contain 'youtube'")
      }
    }
    Error(error_msg) -> {
      io.println("✗ FAILED")
      io.println("  Error: " <> error_msg)
    }
  }

  io.println("")
}

/// Test 4: Fetch YouTube.com with proxy
pub fn test_youtube_with_proxy() {
  io.println("=== Test 4: Fetch YouTube.com WITH Proxy ===")

  let url = "https://www.youtube.com"
  let timeout = 10_000
  let proxy_config = #("127.0.0.1", 7890)

  io.println("URL: " <> url)
  io.println(
    "Proxy: " <> proxy_config.0 <> ":" <> int.to_string(proxy_config.1),
  )

  case http_get_native(url, timeout, proxy_config) {
    Ok(#(status_code, body)) -> {
      io.println("✓ SUCCESS")
      io.println("  Status Code: " <> int.to_string(status_code))
      io.println(
        "  Response Length: " <> int.to_string(string.length(body)) <> " bytes",
      )

      // Check if we got YouTube's HTML
      case string.contains(body, "youtube") {
        True -> io.println("  ✓ Response contains 'youtube'")
        False -> io.println("  ✗ Response does not contain 'youtube'")
      }

      // Check for common proxy issues
      case string.contains(body, "Proxy") || string.contains(body, "proxy") {
        True ->
          io.println("  ⚠ Warning: Response may contain proxy-related text")
        False -> io.println("  ✓ No proxy-related issues detected")
      }
    }
    Error(error_msg) -> {
      io.println("✗ FAILED")
      io.println("  Error: " <> error_msg)

      // Provide helpful troubleshooting info
      case string.contains(error_msg, "timeout") {
        True ->
          io.println(
            "  💡 Suggestion: Proxy may not be running or is unreachable",
          )
        False ->
          case string.contains(error_msg, "econnrefused") {
            True ->
              io.println(
                "  💡 Suggestion: Connection refused - check proxy is running on port 7890",
              )
            False ->
              case string.contains(error_msg, "certificate") {
                True ->
                  io.println(
                    "  💡 Suggestion: SSL/TLS certificate issue with proxy",
                  )
                False ->
                  io.println(
                    "  💡 Suggestion: Check proxy configuration and network connectivity",
                  )
              }
          }
      }
    }
  }

  io.println("")
}

/// Test 5: Compare response times (with and without proxy)
pub fn test_performance_comparison() {
  io.println("=== Test 5: Performance Comparison ===")

  let url = "https://www.google.com"
  let timeout = 10_000

  io.println("Testing URL: " <> url)
  io.println("")

  // Test without proxy
  io.println("Test WITHOUT proxy:")
  let _start_no_proxy = 0
  // Note: Actual timing would require erlang:timestamp()
  case http_get_native(url, timeout, #("no_proxy", 0)) {
    Ok(#(status_code, body)) -> {
      io.println("  ✓ Status: " <> int.to_string(status_code))
      io.println("  ✓ Size: " <> int.to_string(string.length(body)) <> " bytes")
    }
    Error(error_msg) -> {
      io.println("  ✗ Error: " <> error_msg)
    }
  }

  io.println("")

  // Test with proxy
  io.println("Test WITH proxy (127.0.0.1:7890):")
  case http_get_native(url, timeout, #("127.0.0.1", 7890)) {
    Ok(#(status_code, body)) -> {
      io.println("  ✓ Status: " <> int.to_string(status_code))
      io.println("  ✓ Size: " <> int.to_string(string.length(body)) <> " bytes")
    }
    Error(error_msg) -> {
      io.println("  ✗ Error: " <> error_msg)
    }
  }

  io.println("")
}

/// Test 6: Test with different proxy ports (for debugging)
pub fn test_different_proxy_ports() {
  io.println("=== Test 6: Test Different Proxy Ports ===")

  let url = "https://www.google.com"
  let timeout = 10_000
  let test_ports = [7890, 1080, 8080, 3128]

  io.println("Testing URL: " <> url)
  io.println("")

  list.each(test_ports, fn(port) {
    io.println("Testing with proxy 127.0.0.1:" <> int.to_string(port))
    case http_get_native(url, timeout, #("127.0.0.1", port)) {
      Ok(#(status_code, body)) -> {
        io.println("  ✓ SUCCESS - Status: " <> int.to_string(status_code))
        io.println(
          "  ✓ Size: " <> int.to_string(string.length(body)) <> " bytes",
        )
      }
      Error(error_msg) -> {
        io.println("  ✗ FAILED - Error: " <> error_msg)
      }
    }
    io.println("")
  })
}

/// Run all proxy tests
pub fn run_all_proxy_tests() {
  io.println("========================================")
  io.println("Proxy Functionality Test Suite")
  io.println("========================================")
  io.println("")
  io.println("This test suite validates the proxy functionality")
  io.println("by making HTTP requests to Google and YouTube.")
  io.println("")
  io.println("Expected proxy configuration:")
  io.println("  Host: 127.0.0.1")
  io.println("  Port: 7890")
  io.println("")
  io.println("========================================")
  io.println("")

  test_google_no_proxy()
  test_google_with_proxy()
  test_youtube_no_proxy()
  test_youtube_with_proxy()
  test_performance_comparison()

  io.println("========================================")
  io.println("Proxy tests completed!")
  io.println("")
  io.println("Summary:")
  io.println("  - Compare results with and without proxy")
  io.println("  - Check if proxy is working correctly")
  io.println("  - Verify response content is as expected")
  io.println("========================================")
}

/// Run a quick smoke test (just Google with proxy)
pub fn run_quick_test() {
  io.println("========================================")
  io.println("Quick Proxy Smoke Test")
  io.println("========================================")
  io.println("")

  test_google_with_proxy()

  io.println("========================================")
  io.println("Quick test completed!")
  io.println("========================================")
}

/// Main entry point
pub fn main() {
  run_all_proxy_tests()
}
