//// Main API module for Yahoo Finance
//// Provides yfinance-like interface

import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

// Import types and utils
import yfinance/http_client.{
  fetch_stock_data, fetch_stock_data_batch, fetch_stock_info,
}
import yfinance/types.{
  type Indicator, type Interval, type Ohlcv, type OneDay, type OneYear,
  type Period, type ProxyConfig, type StockData, type StockInfo,
  type ValidationError, type YFinanceConfig, type YFinanceError,
}
import yfinance/utils.{
  calculate_ema, calculate_rsi, calculate_sma, chunk_list, format_error,
  interval_to_string, period_to_string, validate_interval_period,
}

/// Default configuration
pub fn default_config() -> YFinanceConfig {
  YFinanceConfig(
    proxy: Error("No proxy configured"),
    user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    timeout: 30_000,
    max_retries: 3,
    batch_size: 50,
  )
}

/// Create a configuration with proxy
pub fn config_with_proxy(proxy: ProxyConfig) -> YFinanceConfig {
  YFinanceConfig(
    proxy: Ok(proxy),
    user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    timeout: 30_000,
    max_retries: 3,
    batch_size: 50,
  )
}

/// Create a proxy configuration
pub fn proxy(host: String, port: Int) -> ProxyConfig {
  ProxyConfig(
    host: host,
    port: port,
    username: Error("No username"),
    password: Error("No password"),
    scheme: "http",
  )
}

/// Create a proxy configuration with authentication
pub fn proxy_with_auth(
  host: String,
  port: Int,
  username: String,
  password: String,
) -> ProxyConfig {
  ProxyConfig(
    host: host,
    port: port,
    username: Ok(username),
    password: Ok(password),
    scheme: "http",
  )
}

/// Main function to get stock data
pub fn get_stock_data(
  symbol: String,
  period: Period,
  interval: Interval,
  config: YFinanceConfig,
) -> YFinanceResult(StockData) {
  // Validate inputs
  case validate_interval_period(interval, period) {
    False -> Error(ValidationError("Invalid interval for given period"))
    True -> {
      let period_str = period_to_string(period)
      let interval_str = interval_to_string(interval)

      case fetch_stock_data(symbol, period_str, interval_str, config) {
        Ok(stock_data) -> Ok(stock_data)
        Error(e) -> Error(e)
      }
    }
  }
}

/// Get stock data for multiple symbols in batch
pub fn get_stock_data_batch(
  symbols: List(String),
  period: Period,
  interval: Interval,
  config: YFinanceConfig,
) -> YFinanceResult(Dict(String, StockData)) {
  let period_str = period_to_string(period)
  let interval_str = interval_to_string(interval)

  // Use batch API if available, otherwise make individual calls
  case fetch_stock_data_batch(symbols, period_str, interval_str, config) {
    Ok(data_dict) -> Ok(data_dict)
    Error(e) -> Error(e)
  }
}

/// Get comprehensive stock information
pub fn get_stock_info(
  symbol: String,
  config: YFinanceConfig,
) -> YFinanceResult(StockInfo) {
  case fetch_stock_info(symbol, config) {
    Ok(stock_info) -> Ok(stock_info)
    Error(e) -> Error(e)
  }
}

/// Get stock info for multiple symbols in batch
pub fn get_stock_info_batch(
  symbols: List(String),
  config: YFinanceConfig,
) -> YFinanceResult(Dict(String, StockInfo)) {
  list.fold(symbols, Ok(dict.new()), fn(acc, symbol) {
    case acc {
      Ok(info_dict) -> {
        case fetch_stock_info(symbol, config) {
          Ok(stock_info) -> Ok(dict.insert(info_dict, symbol, stock_info))
          Error(e) -> Error(e)
        }
      }
      Error(e) -> Error(e)
    }
  })
}

/// Get current price for a symbol
pub fn get_current_price(
  symbol: String,
  config: YFinanceConfig,
) -> YFinanceResult(Float) {
  case get_stock_data(symbol, OneDay, OneDay, config) {
    Ok(stock_data) -> {
      case stock_data.data {
        [] -> Error(ValidationError("No data available for symbol: " <> symbol))
        [latest_data, ..] -> Ok(latest_data.close)
        _ -> Error(ValidationError("No data available for symbol: " <> symbol))
      }
    }
    Error(e) -> Error(e)
  }
}

/// Get current price for multiple symbols
pub fn get_current_price_batch(
  symbols: List(String),
  config: YFinanceConfig,
) -> YFinanceResult(Dict(String, Float)) {
  list.fold(symbols, Ok(dict.new()), fn(acc, symbol) {
    case acc {
      Ok(price_dict) -> {
        case get_current_price(symbol, config) {
          Ok(price) -> Ok(dict.insert(price_dict, symbol, price))
          Error(e) -> Error(e)
        }
      }
      Error(e) -> Error(e)
    }
  })
}

/// Get multiple time series for the same symbol with different intervals
pub fn get_historical_data(
  symbol: String,
  start_date: Int,
  // Unix timestamp
  end_date: Int,
  // Unix timestamp
  interval: Interval,
  config: YFinanceConfig,
) -> YFinanceResult(StockData) {
  // TODO: Implement date-based historical data fetching
  // For now, use period-based approach
  let period = OneYear
  // Default period
  get_stock_data(symbol, period, interval, config)
}

/// Get dividends for a symbol
pub fn get_dividends(
  symbol: String,
  config: YFinanceConfig,
) -> YFinanceResult(List(#(Int, Float))) {
  // TODO: Implement dividends fetching
  Ok([])
}

/// Get splits for a symbol
pub fn get_splits(
  symbol: String,
  config: YFinanceConfig,
) -> YFinanceResult(List(#(Int, Float))) {
  // TODO: Implement splits fetching
  Ok([])
}

/// Search for symbols
pub fn search_symbols(
  query: String,
  config: YFinanceConfig,
) -> YFinanceResult(List(String)) {
  // TODO: Implement symbol search
  Ok([])
}

/// Calculate technical indicators for stock data
pub fn calculate_indicator(
  data: List(Ohlcv),
  indicator: Indicator,
) -> List(Float) {
  case indicator {
    SimpleMovingAverage(period) -> calculate_sma(data, period)
    ExponentialMovingAverage(period) -> calculate_ema(data, period)
    RelativeStrengthIndex(period) -> calculate_rsi(data, period)
    _ -> []
    // TODO: Implement other indicators
  }
}

/// Get multiple stocks with intelligent batching
pub fn get_multiple_stocks(
  symbols: List(String),
  period: Period,
  interval: Interval,
  config: YFinanceConfig,
) -> YFinanceResult(Dict(String, StockData)) {
  let batch_size = config.batch_size

  case symbols {
    [] -> Ok(dict.new())
    _ -> {
      // Split symbols into batches
      let symbol_batches = chunk_list(symbols, batch_size)

      // Process each batch
      list.fold(symbol_batches, Ok(dict.new()), fn(acc, batch) {
        case acc {
          Ok(all_data) -> {
            case get_stock_data_batch(batch, period, interval, config) {
              Ok(batch_data) -> {
                let combined_data = dict.merge(all_data, batch_data)
                Ok(combined_data)
              }
              Error(e) -> Error(e)
            }
          }
          Error(e) -> Error(e)
        }
      })
    }
  }
}

/// Get market data for indices
pub fn get_market_data(
  indices: List(String),
  // e.g., ["^GSPC", "^DJI", "^IXIC"]
  config: YFinanceConfig,
) -> YFinanceResult(Dict(String, StockData)) {
  list.fold(indices, Ok(dict.new()), fn(acc, index) {
    case acc {
      Ok(market_data) -> {
        case get_stock_data(index, OneDay, OneDay, config) {
          Ok(stock_data) -> Ok(dict.insert(market_data, index, stock_data))
          Error(e) -> Error(e)
        }
      }
      Error(e) -> Error(e)
    }
  })
}

/// Get cryptocurrency data
pub fn get_crypto_data(
  crypto_symbol: String,
  currency: String,
  // e.g., "USD", "USDT"
  period: Period,
  interval: Interval,
  config: YFinanceConfig,
) -> YFinanceResult(StockData) {
  let symbol = crypto_symbol <> "-" <> currency
  get_stock_data(symbol, period, interval, config)
}

/// Get forex data
pub fn get_forex_data(
  from_currency: String,
  to_currency: String,
  period: Period,
  interval: Interval,
  config: YFinanceConfig,
) -> YFinanceResult(StockData) {
  let symbol = from_currency <> to_currency <> "=X"
  get_stock_data(symbol, period, interval, config)
}

/// Get earnings data
pub fn get_earnings(
  symbol: String,
  config: YFinanceConfig,
) -> YFinanceResult(List(String)) {
  // TODO: Implement earnings data fetching
  Ok([])
}

/// Get financial statements
pub fn get_financial_data(
  symbol: String,
  config: YFinanceConfig,
) -> YFinanceResult(String) {
  // TODO: Implement financial data fetching
  Ok("Financial data not implemented")
}

/// Utility function to format stock data for display
pub fn format_stock_data(stock_data: StockData) -> String {
  let currency = stock_data.currency
  let data_points = list.length(stock_data.data)
  let latest_data = case stock_data.data {
    [] -> None
    [latest, ..] -> Some(latest)
  }

  let formatted = [
    "Symbol: " <> stock_data.symbol,
    "Currency: " <> currency,
    "Data Points: " <> int.to_string(data_points),
    case latest_data {
      Some(latest) ->
        "Latest Close: " <> float.to_string(latest.close) <> " " <> currency
      None -> "No price data available"
    },
  ]

  string.join(formatted, "\n")
}
