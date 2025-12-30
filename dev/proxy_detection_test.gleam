import gleam/dict
import gleam/int
import gleam/io
import gleam/string
import yfinance/http_client
import yfinance/types

pub fn test_proxy_connection(proxy_host: String, proxy_port: Int) {
  let test_url = "http://httpbin.org/get"

  let request =
    types.HttpRequest(
      method: types.GET,
      url: test_url,
      headers: dict.new(),
      body: Ok(""),
    )

  let proxy_config =
    Ok(types.ProxyConfig(
      host: proxy_host,
      port: proxy_port,
      username: Error(""),
      password: Error(""),
      scheme: "http",
    ))

  let config =
    types.YFinanceConfig(
      timeout: 10_000,
      // Shorter timeout for testing
      max_retries: 1,
      user_agent: "ProxyTest/1.0",
      proxy: proxy_config,
      batch_size: 1,
    )

  io.println(
    "Testing proxy connection to "
    <> proxy_host
    <> ":"
    <> int.to_string(proxy_port),
  )
  io.println("Test URL: " <> test_url)

  case http_client.execute_request(request, config, 1) {
    Ok(response) -> {
      io.println("✅ Proxy connection successful!")
      io.println("Status: " <> int.to_string(response.status_code))
      io.println(
        "Response length: "
        <> int.to_string(string.length(response.body))
        <> " chars",
      )
    }
    Error(error) -> {
      io.println("❌ Proxy connection failed: " <> error)
      io.println(
        "This suggests the proxy at "
        <> proxy_host
        <> ":"
        <> int.to_string(proxy_port)
        <> " is not available",
      )
    }
  }
}

pub fn main() {
  // Test common proxy ports
  io.println("=== Testing Proxy Connections ===")

  test_proxy_connection("127.0.0.1", 7890)
  io.println("")
  test_proxy_connection("127.0.0.1", 8080)
  io.println("")
  test_proxy_connection("127.0.0.1", 1080)
  io.println("")
  test_proxy_connection("127.0.0.1", 3128)
  io.println("")

  io.println("=== Testing Direct Connection (No Proxy) ===")

  // Test direct connection for comparison
  let request =
    types.HttpRequest(
      method: types.GET,
      url: "http://httpbin.org/get",
      headers: dict.new(),
      body: Ok(""),
    )

  let config =
    types.YFinanceConfig(
      timeout: 10_000,
      max_retries: 1,
      user_agent: "DirectTest/1.0",
      proxy: Error("No proxy"),
      batch_size: 1,
    )

  case http_client.execute_request(request, config, 1) {
    Ok(response) -> {
      io.println("✅ Direct connection successful!")
      io.println("Status: " <> int.to_string(response.status_code))
    }
    Error(error) -> {
      io.println("❌ Direct connection also failed: " <> error)
      io.println("This suggests general network connectivity issues")
    }
  }
}
