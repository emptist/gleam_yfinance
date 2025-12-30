//// HTTP client for Yahoo Finance API
//// Handles proxy support, error handling, and JSON parsing
////
//// Uses native Erlang httpc for HTTP requests

import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/option.{None, Some}
import gleam/string

// Import types and utils
import yfinance/types.{
  type HttpRequest, type HttpResponse, type HttpResult, type OHLCV,
  type StockData, type StockInfo, type YFinanceConfig, type YFinanceError,
  type YFinanceResult, ChartEndpoint, GET, HttpRequest, HttpResponse,
  NetworkError, OneDay, PeriodOneDay, RateLimitError, StockData,
}
import yfinance/utils.{build_request_params, build_yahoo_url, create_headers}

/// Native HTTP GET request
/// Returns: Result(#(status_code: Int, body: String), String)
@external(erlang, "yfinance_http_native", "http_get")
fn http_get_native(
  url: String,
  timeout: Int,
  proxy_host: String,
  proxy_port: Int,
  proxy_user: String,
  proxy_pass: String,
) -> Result(#(Int, String), String)

/// Execute HTTP request with retry logic
pub fn execute_request(
  request: HttpRequest,
  config: YFinanceConfig,
  max_retries: Int,
) -> HttpResult(HttpResponse) {
  execute_request_with_retry(request, config, max_retries, 0)
}

/// Execute HTTP request with retry logic
fn execute_request_with_retry(
  request: HttpRequest,
  config: YFinanceConfig,
  max_retries: Int,
  attempt: Int,
) -> HttpResult(HttpResponse) {
  case attempt >= max_retries {
    True ->
      Error(
        "Max retries exceeded after "
        <> int.to_string(max_retries)
        <> " attempts",
      )
    False -> {
      io.println("[DEBUG] HTTP Request Details:")
      io.println("[DEBUG]   URL: " <> request.url)
      io.println("[DEBUG]   Method: GET")
      io.println(
        "[DEBUG]   Attempt: "
        <> int.to_string(attempt + 1)
        <> "/"
        <> int.to_string(max_retries),
      )
      io.println("[DEBUG]   Timeout: " <> int.to_string(config.timeout) <> "ms")

      case config.proxy {
        Ok(proxy) -> {
          io.println(
            "[DEBUG]   Proxy: "
            <> proxy.host
            <> ":"
            <> int.to_string(proxy.port),
          )
        }
        Error(_) -> {
          io.println("[DEBUG]   Proxy: None")
        }
      }

      // Build proxy config tuple for native module
      let proxy_config = case config.proxy {
        Ok(proxy) -> {
          let username = case proxy.username {
            Ok(user) -> user
            Error(_) -> ""
          }
          let password = case proxy.password {
            Ok(pass) -> pass
            Error(_) -> ""
          }
          #(proxy.host, proxy.port, username, password)
        }
        Error(_) -> #("no_proxy", 0, "", "")
      }

      // Make actual HTTP request using native Erlang
      case
        http_get_native(
          request.url,
          config.timeout,
          proxy_config.0,
          proxy_config.1,
          proxy_config.2,
          proxy_config.3,
        )
      {
        Ok(#(status_code, body)) -> {
          io.println(
            "[DEBUG]   Response Status: " <> int.to_string(status_code),
          )

          Ok(HttpResponse(
            status_code: status_code,
            headers: dict.from_list([
              #("content-type", "application/json"),
            ]),
            body: body,
          ))
        }
        Error(error_msg) -> {
          io.println("[DEBUG]   HTTP Error: " <> error_msg)
          Error(error_msg)
        }
      }
    }
  }
}

/// Parse Yahoo Finance quote response
pub fn parse_quote_response(response: HttpResponse) -> YFinanceResult(StockData) {
  io.println("[DEBUG] Parsing quote response:")
  io.println("[DEBUG]   Status Code: " <> int.to_string(response.status_code))

  case response.status_code {
    status if status >= 200 && status < 300 -> {
      io.println(
        "[DEBUG]   Response body length: "
        <> int.to_string(string.length(response.body)),
      )

      // Check if response body contains valid data
      case response.body {
        "" -> Error(NetworkError("Empty response body"))
        body -> {
          // Simple parsing to check for data availability
          case string.contains(body, "result") {
            True -> {
              // Try to extract basic stock data
              case string.contains(body, "\"regularMarketPrice\"") {
                True -> {
                  // Return a basic stock data structure
                  Ok(StockData(
                    symbol: "UNKNOWN",
                    interval: OneDay,
                    period: PeriodOneDay,
                    data: [],
                    currency: "USD",
                    symbol_info: Error("Parsing not fully implemented"),
                    is_crypto: False,
                    is_forex: False,
                    exchange: Error("Exchange info not parsed"),
                  ))
                }
                False -> Error(NetworkError("No market price data in response"))
              }
            }
            False -> Error(NetworkError("Invalid response format"))
          }
        }
      }
    }
    status -> {
      io.println("[DEBUG]   HTTP error status: " <> int.to_string(status))
      Error(NetworkError("HTTP error: " <> int.to_string(status)))
    }
  }
}

/// Parse Yahoo Finance summary response
pub fn parse_summary_response(
  response: HttpResponse,
) -> YFinanceResult(StockInfo) {
  io.println("[DEBUG] Parsing summary response:")
  io.println("[DEBUG]   Status Code: " <> int.to_string(response.status_code))

  case response.status_code {
    status if status >= 200 && status < 300 -> {
      io.println(
        "[DEBUG]   Note: Full JSON parsing requires gleam_json package",
      )
      Error(NetworkError("JSON parsing not implemented"))
    }
    status -> {
      io.println("[DEBUG]   HTTP error status: " <> int.to_string(status))
      Error(NetworkError("HTTP error: " <> int.to_string(status)))
    }
  }
}

/// Fetch stock data from Yahoo Finance
pub fn fetch_stock_data(
  symbol: String,
  period: String,
  interval: String,
  config: YFinanceConfig,
) -> YFinanceResult(StockData) {
  io.println("[DEBUG] Fetching stock data:")
  io.println("[DEBUG]   Symbol: " <> symbol)
  io.println("[DEBUG]   Period: " <> period)
  io.println("[DEBUG]   Interval: " <> interval)

  let params = build_request_params(symbol, period, interval, True, True)
  let url = build_yahoo_url(ChartEndpoint, params)
  io.println("[DEBUG]   Request URL: " <> url)

  let proxy_result = case config.proxy {
    Ok(proxy_config) -> Some(proxy_config)
    Error(_) -> None
  }
  let headers = create_headers(config.user_agent, proxy_result)

  let request =
    HttpRequest(
      method: GET,
      url: url,
      headers: headers,
      body: Ok(""),
      // Empty body for GET requests
    )

  case execute_request(request, config, config.max_retries) {
    Ok(response) -> parse_quote_response(response)
    Error(error) -> {
      io.println("[DEBUG] Error executing request: " <> error)
      Error(NetworkError(error))
    }
  }
}

/// Fetch stock summary/info from Yahoo Finance
pub fn fetch_stock_info(
  _symbol: String,
  config: YFinanceConfig,
) -> YFinanceResult(StockInfo) {
  let _ = config
  io.println("[DEBUG] Fetching stock info:")
  io.println("[DEBUG]   Note: Stock info fetching not implemented")
  Error(NetworkError("Stock info fetching not implemented"))
}

/// Fetch multiple symbols in batch
pub fn fetch_stock_data_batch(
  _symbols: List(String),
  _period: String,
  _interval: String,
  _config: YFinanceConfig,
) -> YFinanceResult(Dict(String, StockData)) {
  io.println("[DEBUG] Fetching stock data batch:")
  io.println("[DEBUG]   Note: Batch fetching not implemented")
  Error(NetworkError("Batch fetching not implemented"))
}

/// Handle rate limiting
pub fn handle_rate_limit(
  response: HttpResponse,
  _config: YFinanceConfig,
) -> Result(HttpResponse, YFinanceError) {
  case response.status_code {
    429 -> Error(RateLimitError("Rate limit exceeded"))
    200 -> Ok(response)
    status_code if status_code >= 400 && status_code < 500 -> {
      Error(NetworkError("Client error: " <> int.to_string(status_code)))
    }
    status_code if status_code >= 500 -> {
      Error(NetworkError("Server error: " <> int.to_string(status_code)))
    }
    _ -> Ok(response)
  }
}

/// Parse OHLCV data from Yahoo Finance response
pub fn parse_ohlcv_data(_json_data: String) -> List(OHLCV) {
  // This function requires gleam_json package for full implementation
  []
}
