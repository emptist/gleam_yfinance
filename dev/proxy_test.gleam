//// Proxy Test Examples
//// Tests proxy functionality by making HTTP requests to Wikipedia

import gleam/int
import gleam/io
import gleam/list
import gleam/string

// Import the native HTTP function
@external(erlang, "yfinance_http_native", "http_get")
fn http_get_native(
  url: String,
  timeout: Int,
  proxy_config: #(String, Int, String, String),
) -> Result(#(Int, String), String)

/// Test 1: Fetch Wikipedia.org without proxy
pub fn test_wikipedia_no_proxy() {
  io.println("=== Test 1: Fetch Wikipedia.org WITHOUT Proxy ===")

  let url = "https://www.wikipedia.org"
  let timeout = 10_000
  let proxy_config = #("no_proxy", 0, "", "")

  io.println("URL: " <> url)
  io.println("Proxy: None")

  case http_get_native(url, timeout, proxy_config) {
    Ok(#(status_code, body)) -> {
      io.println("✓ SUCCESS")
      io.println("  Status Code: " <> int.to_string(status_code))
      io.println(
        "  Response Length: " <> int.to_string(string.length(body)) <> " bytes",
      )

      // Check if we got Wikipedia content
      let has_wiki =
        string.contains(body, "Wikipedia") || string.contains(body, "wikipedia")
      case has_wiki {
        True -> io.println("  ✓ Response contains Wikipedia content")
        False -> io.println("  ✗ Response does not contain Wikipedia content")
      }
    }
    Error(error_msg) -> {
      io.println("✗ FAILED")
      io.println("  Error: " <> error_msg)
    }
  }

  io.println("")
}

/// Test 2: Fetch Wikipedia.org with proxy
pub fn test_wikipedia_with_proxy() {
  io.println("=== Test 2: Fetch Wikipedia.org WITH Proxy ===")

  let url = "https://www.wikipedia.org"
  let timeout = 10_000
  let proxy_config = #("127.0.0.1", 7890, "", "")

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

      // Check if we got Wikipedia content
      let has_wiki =
        string.contains(body, "Wikipedia") || string.contains(body, "wikipedia")
      case has_wiki {
        True -> io.println("  ✓ Response contains Wikipedia content")
        False -> io.println("  ✗ Response does not contain Wikipedia content")
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

/// Test 3: Fetch Wikipedia article without proxy
pub fn test_wikipedia_article_no_proxy() {
  io.println("=== Test 3: Fetch Wikipedia Article WITHOUT Proxy ===")

  let url = "https://en.wikipedia.org/wiki/Gleam_(programming_language)"
  let timeout = 10_000
  let proxy_config = #("no_proxy", 0, "", "")

  io.println("URL: " <> url)
  io.println("Proxy: None")

  case http_get_native(url, timeout, proxy_config) {
    Ok(#(status_code, body)) -> {
      io.println("✓ SUCCESS")
      io.println("  Status Code: " <> int.to_string(status_code))
      io.println(
        "  Response Length: " <> int.to_string(string.length(body)) <> " bytes",
      )

      // Check if we got Wikipedia article content
      let has_gleam =
        string.contains(body, "Gleam")
        || string.contains(body, "programming language")
      case has_gleam {
        True -> io.println("  ✓ Response contains article content")
        False -> io.println("  ✗ Response does not contain article content")
      }
    }
    Error(error_msg) -> {
      io.println("✗ FAILED")
      io.println("  Error: " <> error_msg)
    }
  }

  io.println("")
}

/// Test 4: Fetch Wikipedia article with proxy
pub fn test_wikipedia_article_with_proxy() {
  io.println("=== Test 4: Fetch Wikipedia Article WITH Proxy ===")

  let url = "https://en.wikipedia.org/wiki/Gleam_(programming_language)"
  let timeout = 10_000
  let proxy_config = #("127.0.0.1", 7890, "", "")

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

      // Check if we got Wikipedia article content
      let has_gleam =
        string.contains(body, "Gleam")
        || string.contains(body, "programming language")
      case has_gleam {
        True -> io.println("  ✓ Response contains article content")
        False -> io.println("  ✗ Response does not contain article content")
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

  let url = "https://www.wikipedia.org"
  let timeout = 10_000

  io.println("Testing URL: " <> url)
  io.println("")

  // Test without proxy
  io.println("Test WITHOUT proxy:")
  let _start_no_proxy = 0
  // Note: Actual timing would require erlang:timestamp()
  case http_get_native(url, timeout, #("no_proxy", 0, "", "")) {
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
  case http_get_native(url, timeout, #("127.0.0.1", 7890, "", "")) {
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

  let url = "https://www.wikipedia.org"
  let timeout = 10_000
  let test_ports = [7890, 1080, 8080, 3128]

  io.println("Testing URL: " <> url)
  io.println("")

  list.each(test_ports, fn(port) {
    io.println("Testing with proxy 127.0.0.1:" <> int.to_string(port))
    case http_get_native(url, timeout, #("127.0.0.1", port, "", "")) {
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

/// Run all proxy tests (legacy - kept for reference)
pub fn run_all_proxy_tests() {
  io.println("========================================")
  io.println("Proxy Functionality Test Suite (Legacy)")
  io.println("========================================")
  io.println("")
  io.println("NOTE: For running individual tests, use the separate modules:")
  io.println("  gleam run --module proxy_test_no_proxy")
  io.println("  gleam run --module proxy_test_with_proxy")
  io.println("  gleam run --module proxy_test_article_no_proxy")
  io.println("  gleam run --module proxy_test_article_with_proxy")
  io.println("  gleam run --module proxy_test_performance")
  io.println("  gleam run --module proxy_test_ports")
  io.println("")
  io.println("This test suite validates proxy functionality")
  io.println("by making HTTP requests to Wikipedia.")
  io.println("")
  io.println("Expected proxy configuration:")
  io.println("  Host: 127.0.0.1")
  io.println("  Port: 7890")
  io.println("")
  io.println("========================================")
  io.println("")

  test_wikipedia_no_proxy()
  test_wikipedia_with_proxy()
  test_wikipedia_article_no_proxy()
  test_wikipedia_article_with_proxy()
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

/// Run a quick smoke test (just Wikipedia with proxy)
pub fn run_quick_test() {
  io.println("========================================")
  io.println("Quick Proxy Smoke Test")
  io.println("========================================")
  io.println("")

  test_wikipedia_with_proxy()

  io.println("========================================")
  io.println("Quick test completed!")
  io.println("========================================")
}

/// Main entry point - shows usage instructions
pub fn main() {
  io.println("========================================")
  io.println("Proxy Test Suite")
  io.println("========================================")
  io.println("")
  io.println("Available test modules:")
  io.println("")
  io.println("1. proxy_test_no_proxy")
  io.println("   - Fetch Wikipedia without proxy")
  io.println("   - Run: gleam run --module proxy_test_no_proxy")
  io.println("")
  io.println("2. proxy_test_with_proxy")
  io.println("   - Fetch Wikipedia with proxy (127.0.0.1:7890)")
  io.println("   - Run: gleam run --module proxy_test_with_proxy")
  io.println("")
  io.println("3. proxy_test_article_no_proxy")
  io.println("   - Fetch Wikipedia article without proxy")
  io.println("   - Run: gleam run --module proxy_test_article_no_proxy")
  io.println("")
  io.println("4. proxy_test_article_with_proxy")
  io.println("   - Fetch Wikipedia article with proxy")
  io.println("   - Run: gleam run --module proxy_test_article_with_proxy")
  io.println("")
  io.println("5. proxy_test_performance")
  io.println("   - Compare performance with/without proxy")
  io.println("   - Run: gleam run --module proxy_test_performance")
  io.println("")
  io.println("6. proxy_test_ports")
  io.println("   - Test different proxy ports")
  io.println("   - Run: gleam run --module proxy_test_ports")
  io.println("")
  io.println("Legacy functions (kept for reference):")
  io.println("  - run_quick_test(): Quick smoke test")
  io.println("  - run_all_proxy_tests(): Run all legacy tests")
  io.println("========================================")
}
