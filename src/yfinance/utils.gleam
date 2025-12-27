//// Utility functions for Yahoo Finance API

import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

/// Convert interval to string for API calls
pub fn interval_to_string(interval: Interval) -> String {
  case interval {
    OneMinute -> "1m"
    TwoMinutes -> "2m"
    FiveMinutes -> "5m"
    FifteenMinutes -> "15m"
    ThirtyMinutes -> "30m"
    SixtyMinutes -> "60m"
    NinetyMinutes -> "90m"
    OneHour -> "1h"
    OneDay -> "1d"
    FiveDays -> "5d"
    OneWeek -> "1wk"
    OneMonth -> "1mo"
    ThreeMonths -> "3mo"
  }
}

/// Convert period to string for API calls
pub fn period_to_string(period: Period) -> String {
  case period {
    OneDay -> "1d"
    FiveDays -> "5d"
    OneMonth -> "1mo"
    ThreeMonths -> "3mo"
    SixMonths -> "6mo"
    OneYear -> "1y"
    TwoYears -> "2y"
    FiveYears -> "5y"
    TenYears -> "10y"
    YearToDate -> "ytd"
    Max -> "max"
  }
}

/// Convert instrument to Yahoo Finance symbol format
pub fn instrument_to_symbol(instrument: Instrument) -> String {
  case instrument {
    Stock(symbol) -> symbol
    Crypto(symbol, currency) -> symbol <> "-" <> currency
    Forex(from, to) -> from <> to <> "=X"
    Fund(symbol) -> symbol
    Index(symbol) -> symbol
    ETF(symbol) -> symbol
    Bond(symbol) -> symbol
  }
}

/// Check if interval is valid for the given period
pub fn validate_interval_period(interval: Interval, period: Period) -> Bool {
  case interval {
    OneMinute
    | TwoMinutes
    | FiveMinutes
    | FifteenMinutes
    | ThirtyMinutes
    | SixtyMinutes
    | NinetyMinutes
    | OneHour -> {
      case period {
        OneDay | FiveDays -> True
        _ -> False
      }
    }
    _ -> True
    // Other intervals work with all periods
  }
}

/// Convert boolean to string
pub fn bool_to_string(b: Bool) -> String {
  case b {
    True -> "true"
    False -> "false"
  }
}

/// Convert int to string safely
pub fn int_to_string_safe(value: Result(Int, String)) -> String {
  case value {
    Ok(int_val) -> int.to_string(int_val)
    Error(_) -> "N/A"
  }
}

/// Convert float to string safely with precision
pub fn float_to_string_safe(
  value: Result(Float, String),
  precision: Int,
) -> String {
  case value {
    Ok(float_val) -> {
      let precision_factor = int.to_float(int.pow(10, precision))
      let rounded =
        float.round(float_val *. precision_factor) /. precision_factor
      float.to_string(rounded)
    }
    Error(_) -> "N/A"
  }
}

/// Parse timestamp from string (handles various formats)
pub fn parse_timestamp(timestamp_str: String) -> Result(Int, String) {
  case int.parse(timestamp_str) {
    Ok(timestamp) -> Ok(timestamp)
    Error(_) -> Error("Failed to parse timestamp: " <> timestamp_str)
  }
}

/// Parse float from string safely
pub fn parse_float_safe(value: String) -> Result(Float, String) {
  case float.parse(value) {
    Ok(float_val) -> Ok(float_val)
    Error(_) -> Error("Failed to parse float: " <> value)
  }
}

/// Parse int from string safely
pub fn parse_int_safe(value: String) -> Result(Int, String) {
  case int.parse(value) {
    Ok(int_val) -> Ok(int_val)
    Error(_) -> Error("Failed to parse int: " <> value)
  }
}

/// Format error messages
pub fn format_error(error: YFinanceError) -> String {
  case error {
    NetworkError(msg) -> "Network Error: " <> msg
    ApiError(msg, code) -> "API Error (" <> int.to_string(code) <> "): " <> msg
    ParseError(msg) -> "Parse Error: " <> msg
    ValidationError(msg) -> "Validation Error: " <> msg
    RateLimitError(msg) -> "Rate Limit Error: " <> msg
    ProxyError(msg) -> "Proxy Error: " <> msg
    TimeoutError(msg) -> "Timeout Error: " <> msg
  }
}

/// Create headers for HTTP requests
pub fn create_headers(
  user_agent: String,
  proxy: Option(ProxyConfig),
) -> Dict(String, String) {
  let headers =
    dict.new()
    |> dict.insert("User-Agent", user_agent)
    |> dict.insert("Accept", "application/json")
    |> dict.insert("Accept-Encoding", "gzip, deflate")
    |> dict.insert("Connection", "keep-alive")

  case proxy {
    Some(proxy_config) -> {
      // Add proxy-specific headers if needed
      headers
      |> dict.insert("Proxy-Connection", "keep-alive")
    }
    None -> headers
  }
}

/// Build Yahoo Finance API URL
pub fn build_yahoo_url(
  endpoint: YahooEndpoint,
  params: Dict(String, String),
) -> String {
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

  let param_string =
    dict.to_list(params)
    |> list.map(fn(param) { param.0 <> "=" <> param.1 })
    |> string.join("&")

  case param_string {
    "" -> base_url <> endpoint_path
    _ -> base_url <> endpoint_path <> "?" <> param_string
  }
}

/// Build request parameters for Yahoo Finance API
pub fn build_request_params(
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
    False -> headers
  }
}

/// Calculate Simple Moving Average
pub fn calculate_sma(data: List(Ohlcv), period: Int) -> List(Float) {
  let data_length = list.length(data)
  case data_length {
    0 -> []
    1 -> []
    _ if data_length < period -> []
    _ -> {
      // Get closing prices
      let closes = list.map(data, fn(ohlcv) { ohlcv.close })

      // Calculate SMA for each valid window
      list.range(0, data_length - period)
      |> list.map(fn(start_idx) {
        let window = list.take(list.drop(closes, start_idx), period)
        list.fold(window, 0.0, fn(sum, price) { sum +. price })
        /. int.to_float(period)
      })
    }
  }
}

/// Calculate Exponential Moving Average
pub fn calculate_ema(data: List(Ohlcv), period: Int) -> List(Float) {
  let data_length = list.length(data)
  case data_length {
    0 -> []
    1 -> []
    _ if data_length < period -> []
    _ -> {
      let closes = list.map(data, fn(ohlcv) { ohlcv.close })
      let multiplier = 2.0 /. int.to_float(period + 1)

      // Calculate initial SMA as first EMA value
      let initial_ema =
        list.take(closes, period)
        |> list.fold(0.0, fn(sum, price) { sum +. price })
        |> fn(sma) { sma /. int.to_float(period) }

      // Calculate EMA for remaining data points
      list.drop(closes, period)
      |> list.fold([initial_ema], fn(emas, price) {
        let last_ema = list.first(emas) |> option.unwrap(0.0)
        let new_ema = price *. multiplier +. last_ema *. { 1.0 -. multiplier }
        [new_ema, ..emas]
      })
      |> list.reverse
    }
  }
}

/// Calculate Relative Strength Index
pub fn calculate_rsi(data: List(Ohlcv), period: Int) -> List(Float) {
  let data_length = list.length(data)
  case data_length {
    0 -> []
    1 -> []
    _ if data_length < period + 1 -> []
    _ -> {
      let closes = list.map(data, fn(ohlcv) { ohlcv.close })

      // Calculate price changes
      let changes =
        list.range(0, data_length - 2)
        |> list.map(fn(i) {
          list.drop(closes, i + 1)
          |> list.first
          |> option.unwrap(closes.0)
          -. closes.0
        })

      // Calculate gains and losses
      let gains = list.filter(changes, fn(change) { change >. 0.0 })
      let losses =
        list.filter(changes, fn(change) { change <. 0.0 })
        |> list.map(fn(loss) { 0.0 -. loss })

      let gains_length = list.length(gains)
      let losses_length = list.length(losses)
      case gains_length >= period && losses_length >= period {
        True -> {
          let avg_gain =
            list.take(gains, period)
            |> list.fold(0.0, fn(sum, gain) { sum +. gain })
            /. int.to_float(period)
          let avg_loss =
            list.take(losses, period)
            |> list.fold(0.0, fn(sum, loss) { sum +. loss })
            /. int.to_float(period)

          case avg_loss >. 0.0 {
            True -> {
              let rs = avg_gain /. avg_loss
              let rsi = 100.0 -. { 100.0 /. { 1.0 +. rs } }
              [rsi]
            }
            False -> [100.0]
          }
        }
        False -> []
      }
    }
  }
}

/// Chunk a list into smaller lists of specified size
pub fn chunk_list(list: List(a), size: Int) -> List(List(a)) {
  case size <= 0 {
    True -> []
    False -> {
      list.chunk(list, fn(_) { 1 })
      |> list.fold([], fn(acc, chunk) {
        let chunk_length = list.length(chunk)
        case chunk_length == size {
          True -> [chunk, ..acc]
          False -> {
            let acc_length = list.length(acc)
            case acc {
              [current_chunk, ..rest] -> {
                let current_chunk_length = list.length(current_chunk)
                case current_chunk_length < size {
                  True -> [list.append(current_chunk, chunk), ..rest]
                  False -> [chunk, ..acc]
                }
              }
              _ -> [chunk, ..acc]
            }
          }
        }
      })
      |> list.reverse
    }
  }
}

/// Retry function with exponential backoff
pub fn retry_with_backoff(
  operation: fn() -> Result(a, YFinanceError),
  max_retries: Int,
  delay_ms: Int,
) -> Result(a, YFinanceError) {
  retry_with_backoff_impl(operation, max_retries, delay_ms, 0)
}

fn retry_with_backoff_impl(
  operation: fn() -> Result(a, YFinanceError),
  max_retries: Int,
  delay_ms: Int,
  attempt: Int,
) -> Result(a, YFinanceError) {
  case attempt >= max_retries {
    True -> {
      // Last attempt
      case operation() {
        Ok(result) -> Ok(result)
        Error(_) -> Error(NetworkError("Max retries exceeded"))
      }
    }
    False -> {
      case operation() {
        Ok(result) -> Ok(result)
        Error(error) -> {
          // Wait before retrying (in real implementation, this would be async)
          let backoff_delay = delay_ms * int.pow(2, attempt)
          retry_with_backoff_impl(operation, max_retries, delay_ms, attempt + 1)
        }
      }
    }
  }
}
