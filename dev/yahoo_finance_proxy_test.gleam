//// Test: Fetch Yahoo Finance data with proxy support
//// Tests actual Yahoo Finance API calls with proxy configuration

import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import yfinance
import yfinance/types.{OneDay, PeriodOneDay}
import yfinance/utils

pub fn main() {
  io.println("=== Yahoo Finance Proxy Test ===")

  // Create proxy configuration
  let proxy = yfinance.proxy("127.0.0.1", 7890)
  let config = yfinance.config_with_proxy(proxy)

  io.println("Testing Yahoo Finance data fetching with proxy...")
  io.println("Proxy: 127.0.0.1:7890")
  io.println("Symbol: AAPL")
  io.println("Period: 1 day")
  io.println("Interval: 1 day")

  // Test fetching stock data
  case yfinance.get_stock_data("AAPL", PeriodOneDay, OneDay, config) {
    Ok(stock_data) -> {
      io.println("✓ SUCCESS: Stock data fetched successfully")
      io.println("  Symbol: " <> stock_data.symbol)
      io.println(
        "  Data points: " <> int.to_string(list.length(stock_data.data)),
      )
      io.println("  Currency: " <> stock_data.currency)

      // Display latest price if available
      case stock_data.data {
        [] -> io.println("  No price data available")
        [latest, ..] -> {
          io.println(
            "  Latest close: "
            <> float.to_string(latest.close)
            <> " "
            <> stock_data.currency,
          )
        }
      }
    }
    Error(error) -> {
      io.println("✗ FAILED: " <> utils.format_error(error))
      io.println("Note: This could be due to:")
      io.println("  - Proxy not running at 127.0.0.1:7890")
      io.println("  - Network connectivity issues")
      io.println("  - Yahoo Finance API changes")
      io.println("  - Rate limiting")
    }
  }

  io.println("")
  io.println("=== Proxy Configuration Test ===")

  // Test proxy configuration creation
  case config.proxy {
    Ok(proxy_config) -> {
      io.println("✓ Proxy configuration verified:")
      io.println("  Host: " <> proxy_config.host)
      io.println("  Port: " <> int.to_string(proxy_config.port))
      io.println("  Scheme: " <> proxy_config.scheme)

      // Test authenticated proxy
      let auth_proxy =
        yfinance.proxy_with_auth("proxy.example.com", 3128, "user", "pass")
      io.println("✓ Authenticated proxy configuration verified:")
      io.println("  Host: " <> auth_proxy.host)
      io.println("  Port: " <> int.to_string(auth_proxy.port))
      io.println("  Username: " <> result.unwrap(auth_proxy.username, "N/A"))
      io.println("  Password: " <> result.unwrap(auth_proxy.password, "N/A"))
    }
    Error(error) -> {
      io.println("✗ Proxy configuration error: " <> error)
    }
  }

  io.println("")
  io.println("=== Usage Examples ===")
  io.println("")
  io.println("Example 1: Default configuration (no proxy)")
  io.println("  let config = yfinance.default_config()")
  io.println(
    "  let result = yfinance.get_stock_data(\"AAPL\", PeriodOneDay, OneDay, config)",
  )
  io.println("")
  io.println("Example 2: With proxy")
  io.println("  let proxy = yfinance.proxy(\"127.0.0.1\", 7890)")
  io.println("  let config = yfinance.config_with_proxy(proxy)")
  io.println(
    "  let result = yfinance.get_stock_data(\"AAPL\", PeriodOneDay, OneDay, config)",
  )
  io.println("")
  io.println("Example 3: With authenticated proxy")
  io.println(
    "  let proxy = yfinance.proxy_with_auth(\"proxy.example.com\", 3128, \"user\", \"pass\")",
  )
  io.println("  let config = yfinance.config_with_proxy(proxy)")
  io.println(
    "  let result = yfinance.get_stock_data(\"AAPL\", PeriodOneDay, OneDay, config)",
  )
  io.println("")
  io.println("To run this test:")
  io.println(
    "  gleam run --module dev/yahoo_finance_proxy_test --target erlang",
  )
}
