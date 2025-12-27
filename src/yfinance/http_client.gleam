//// HTTP client for Yahoo Finance API
//// Handles proxy support, error handling, and JSON parsing

import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

// Import types and utils
import yfinance/types.{
  type HttpRequest, type HttpResponse, type HttpResult, type YFinanceConfig,
  type YFinanceError, type NetworkError, type ParseError, type RateLimitError,
  type StockData, type StockInfo, type Interval, type Period, type OneDay,
  type Ohlcv, type ProxyConfig, type YahooEndpoint, type ChartEndpoint,
  type SummaryEndpoint, type HttpMethod, type GET
}
import yfinance/utils.{
  build_request_params, build_yahoo_url, create_headers
}

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
    True -> Error("Max retries exceeded")
    False -> {
      // TODO: Implement actual HTTP execution
      // For now, return mock response for testing
      case request.url {
        _ ->
          Ok(HttpResponse(
            status_code: 200,
            headers: dict.from_list([]),
            body: "{\"quoteResponse\": {\"result\": []}}",
          ))
      }
    }
  }
}

/// Parse Yahoo Finance quote response
pub fn parse_quote_response(response: HttpResponse) -> YFinanceResult(StockData) {
  case json.decode(response.body) {
    Ok(json_value) -> {
      // TODO: Parse the actual JSON structure
      Ok(StockData(
        symbol: "AAPL",
        // Extract from JSON
        interval: OneDay,
        // Extract from request
        period: OneDay,
        // Extract from request
        data: [],
        // Parse OHLCV data
        currency: "USD",
        // Extract from JSON
        symbol_info: Error("Not implemented"),
        // Parse stock info
        is_crypto: False,
        is_forex: False,
        exchange: Error("Not implemented"),
      ))
    }
    Error(_) -> Error(ParseError("Failed to parse JSON response"))
  }
}

/// Parse Yahoo Finance summary response
pub fn parse_summary_response(
  response: HttpResponse,
) -> YFinanceResult(StockInfo) {
  case json.decode(response.body) {
    Ok(json_value) -> {
      // TODO: Parse the actual Yahoo Finance summary JSON structure
      Ok(StockInfo(
        symbol: "AAPL",
        // Extract from JSON
        short_name: "Apple Inc.",
        // Extract from JSON
        long_name: "Apple Inc.",
        // Extract from JSON
        currency: "USD",
        // Extract from JSON
        market_cap: Error("Not implemented"),
        enterprise_value: Error("Not implemented"),
        trailing_pe: Error("Not implemented"),
        forward_pe: Error("Not implemented"),
        peg_ratio: Error("Not implemented"),
        price_to_book: Error("Not implemented"),
        price_to_sales: Error("Not implemented"),
        dividend_yield: Error("Not implemented"),
        earnings_growth: Error("Not implemented"),
        revenue_growth: Error("Not implemented"),
        profit_margin: Error("Not implemented"),
        operating_margin: Error("Not implemented"),
        return_on_assets: Error("Not implemented"),
        return_on_equity: Error("Not implemented"),
        beta: Error("Not implemented"),
        shares_outstanding: Error("Not implemented"),
        book_value: Error("Not implemented"),
        fifty_two_week_high: Error("Not implemented"),
        fifty_two_week_low: Error("Not implemented"),
        sector: Error("Not implemented"),
        industry: Error("Not implemented"),
        country: Error("Not implemented"),
        website: Error("Not implemented"),
        business_summary: Error("Not implemented"),
        full_time_employees: Error("Not implemented"),
        timestamp: 0,
      ))
    }
    Error(_) -> Error(ParseError("Failed to parse JSON response"))
  }
}

/// Fetch stock data from Yahoo Finance
pub fn fetch_stock_data(
  symbol: String,
  period: String,
  interval: String,
  config: YFinanceConfig,
) -> YFinanceResult(StockData) {
  let params = build_request_params(symbol, period, interval, True, True)
  let url = build_yahoo_url(ChartEndpoint, params)
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
    Error(error) -> Error(NetworkError(error))
  }
}

/// Fetch stock summary/info from Yahoo Finance
pub fn fetch_stock_info(
  symbol: String,
  config: YFinanceConfig,
) -> YFinanceResult(StockInfo) {
  let modules = [
    "summaryDetail",
    "summaryProfile",
    "financialData",
    "defaultKeyStatistics",
    "price",
    "assetProfile",
  ]

  let modules_param = string.join(modules, ",")
  let params =
    dict.from_list([
      #("symbol", symbol),
      #("modules", modules_param),
    ])

  let url = build_yahoo_url(SummaryEndpoint, params)
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
    Ok(response) -> parse_summary_response(response)
    Error(error) -> Error(NetworkError(error))
  }
}

/// Fetch multiple symbols in batch
pub fn fetch_stock_data_batch(
  symbols: List(String),
  period: String,
  interval: String,
  config: YFinanceConfig,
) -> YFinanceResult(Dict(String, StockData)) {
  // TODO: Implement batch API call for better performance
  // For now, make individual calls
  list.fold(symbols, Ok(dict.new()), fn(acc, symbol) {
    case acc {
      Ok(data_dict) -> {
        case fetch_stock_data(symbol, period, interval, config) {
          Ok(stock_data) -> Ok(dict.insert(data_dict, symbol, stock_data))
          Error(e) -> Error(e)
        }
      }
      Error(e) -> Error(e)
    }
  })
}

/// Handle rate limiting
pub fn handle_rate_limit(
  response: HttpResponse,
  config: YFinanceConfig,
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
pub fn parse_ohlcv_data(json_data: json.Json) -> List(Ohlcv) {
  // TODO: Implement actual JSON parsing for OHLCV data
  // This would parse the timestamps, opens, highs, lows, closes, volumes
  []
}
