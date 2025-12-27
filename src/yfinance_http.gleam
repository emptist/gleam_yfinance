//// HTTP client module for Yahoo Finance API
//// Handles proxy support, error handling, and JSON parsing

import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/int
import gleam/float
import gleam/option.{type Option, None, Some}
import gleam/dict.{type Dict}
import gleam/json
import gleam/result.{try}

// HTTP types (these would be imported from gleam_http when available)
pub type HttpMethod {
  GET
  POST
  PUT
  DELETE
}

pub type HttpRequest {
  HttpRequest(
    method: HttpMethod,
    url: String,
    headers: Dict(String, String),
    body: Option(String),
  )
}

pub type HttpResponse {
  HttpResponse(
    status_code: Int,
    headers: Dict(String, String),
    body: String,
  )
}

/// HTTP client result
pub type HttpResult(a) =
  Result(a, String)

/// Yahoo Finance API endpoints
pub type YahooEndpoint {
  QuoteEndpoint           // /quote
  ChartEndpoint           // /chart
  SummaryEndpoint         // /summary
  HistoricalEndpoint      // /historical
  SearchEndpoint          // /search
  ProfileEndpoint         // /profile
  StatisticsEndpoint      // /statistics
  FinancialDataEndpoint   // /financial-data
  DefaultKeyStatistics    // /default-key-statistics
}

/// Build Yahoo Finance API URL
fn build_yahoo_url(endpoint: YahooEndpoint, params: Dict(String, String)) -> String {
  let base_url = "https://query1.finance.yahoo.com"
  
  let endpoint_path = case endpoint {
    QuoteEndpoint -> "/v8/finance/chart"
    ChartEndpoint -> "/v8/finance/chart"
    SummaryEndpoint -> "/v10/finance/quoteSummary"
    HistoricalEndpoint -> "/v7/finance/download"
    SearchEndpoint -> "/v1/finance/search"
    ProfileEndpoint -> "/v10/finance/quoteSummary"
    StatisticsEndpoint -> "/v10/finance/quoteSummary"
    FinancialDataEndpoint -> "/v10/finance/quoteSummary"
    DefaultKeyStatistics -> "/v10/finance/quoteSummary"
  }
  
  let param_string = dict.to_list(params)
    |> list.map(fn(param) {
      param.0 <> "=" <> param.1
    })
    |> string.join("&")
  
  case param_string {
    "" -> base_url <> endpoint_path
    _ -> base_url <> endpoint_path <> "?" <> param_string
  }
}

/// Create headers for Yahoo Finance API request
fn create_headers(
  user_agent: String,
  proxy: Option(String),
) -> Dict(String, String) {
  let headers = dict.new()
    |> dict.insert("User-Agent", user_agent)
    |> dict.insert("Accept", "application/json")
    |> dict.insert("Accept-Encoding", "gzip, deflate")
    |> dict.insert("Connection", "keep-alive")
  
  case proxy {
    Some(_) -> headers |> dict.insert("Proxy-Connection", "keep-alive")
    None -> headers
  }
}

/// Build request parameters for Yahoo Finance API
fn build_request_params(
  symbol: String,
  period: String,
  interval: String,
  include_pre_post: Bool,
  include_adjustments: Bool,
) -> Dict(String, String) {
  dict.from_list([
    #("symbol", symbol),
    #("range", period),
    #("interval", interval),
    #("includePrePost", bool_to_string(include_pre_post)),
    #("events", "div%2Csplits"),
  ])
  |> case include_adjustments {
    True -> dict.insert(_, "includeAdjustedClose", "true")
    False -> _
  }
}

/// Convert boolean to string
fn bool_to_string(b: Bool) -> String {
  case b {
    True -> "true"
    False -> "false"
  }
}

/// Execute HTTP request with retry logic
pub fn execute_request(
  request: HttpRequest,
  config: YFinanceConfig,
  max_retries: Int,
) -> HttpResult(HttpResponse) {
  // TODO: Implement actual HTTP request execution
  // For now, return a mock response for testing
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
      // For now, return mock response
      case request.url {
        _ -> Ok(HttpResponse(
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
        symbol: "AAPL", // Extract from JSON
        interval: OneDay, // Extract from request
        period: OneDay, // Extract from request
        data: [], // Parse OHLCV data
        currency: "USD", // Extract from JSON
        symbol_info: None, // Parse stock info
        is_crypto: False,
        is_forex: False,
        exchange: None,
      ))
    }
    Error(_) -> Error("Failed to parse JSON response")
  }
}

/// Parse Yahoo Finance summary response
pub fn parse_summary_response(response: HttpResponse) -> YFinanceResult(StockInfo) {
  case json.decode(response.body) {
    Ok(json_value) -> {
      // TODO: Parse the actual Yahoo Finance summary JSON structure
      Ok(StockInfo(
        symbol: "AAPL", // Extract from JSON
        short_name: "Apple Inc.", // Extract from JSON
        long_name: "Apple Inc.", // Extract from JSON
        currency: "USD", // Extract from JSON
        market_cap: None,
        enterprise_value: None,
        trailing_pe: None,
        forward_pe: None,
        peg_ratio: None,
        price_to_book: None,
        price_to_sales: None,
        dividend_yield: None,
        earnings_growth: None,
        revenue_growth: None,
        profit_margin: None,
        operating_margin: None,
        return_on_assets: None,
        return_on_equity: None,
        beta: None,
        shares_outstanding: None,
        book_value: None,
        fifty_two_week_high: None,
        fifty_two_week_low: None,
        sector: None,
        industry: None,
        country: None,
        website: None,
        business_summary: None,
        full_time_employees: None,
        timestamp: 0,
      ))
    }
    Error(_) -> Error("Failed to parse JSON response")
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
  let headers = create_headers(config.user_agent, None) // TODO: Add proxy support
  
  let request = HttpRequest(
    method: GET,
    url: url,
    headers: headers,
    body: None,
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
  let params = dict.from_list([
    #("symbol", symbol),
    #("modules", modules_param),
  ])
  
  let url = build_yahoo_url(SummaryEndpoint, params)
  let headers = create_headers(config.user_agent, None) // TODO: Add proxy support
  
  let request = HttpRequest(
    method: GET,
    url: url,
    headers: headers,
    body: None,
  )
  
  case execute_request(request, config, config.max_retries) {
    Ok(response) -> parse_summary_response(response)
    Error(error) -> Error(NetworkError(error))
  }
}

/// Build batch request URL for multiple symbols
fn build_batch_request_url(symbols: List(String), endpoint: YahooEndpoint) -> String {
  let symbols_param = string.join(symbols, ",")
  let params = dict.from_list([#("symbols", symbols_param)])
  build_yahoo_url(endpoint, params)
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
  list.fold(
    symbols,
    Ok(dict.new()),
    fn(acc, symbol) {
      case acc {
        Ok(data_dict) -> {
          case fetch_stock_data(symbol, period, interval, config) {
            Ok(stock_data) -> Ok(dict.insert(data_dict, symbol, stock_data))
            Error(e) -> Error(e)
          }
        }
        Error(e) -> Error(e)
      }
    }
  )
}

/// Handle proxy configuration
fn apply_proxy_config(
  headers: Dict(String, String),
  proxy: Option(ProxyConfig),
) -> Dict(String, String) {
  case proxy {
    Some(proxy_config) -> {
      // TODO: Implement proxy configuration
      // This would involve adding proxy headers or configuring the HTTP client
      headers
    }
    None -> headers
  }
}

/// Utility function to handle rate limiting
fn handle_rate_limit(response: HttpResponse, config: YFinanceConfig) -> Result(HttpResponse, YFinanceError) {
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
fn parse_ohlcv_data(json_data: json.Json) -> List(Ohlcv) {
  // TODO: Implement actual JSON parsing for OHLCV data
  // This would parse the timestamps, opens, highs, lows, closes, volumes
  []
}

/// Parse timestamp and convert to Unix timestamp
fn parse_timestamp(timestamp_str: String) -> Int {
  // TODO: Implement timestamp parsing
  // This would convert Yahoo Finance timestamp format to Unix timestamp
  0
}