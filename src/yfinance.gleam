//// Yahoo Finance API client for Gleam
//// Similar to the Python yfinance package

import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/string

// Import all submodules
import yfinance/api
import yfinance/types
import yfinance/utils

// Re-export types for easy access
pub type Interval =
  types.Interval

pub type Period =
  types.Period

pub type Instrument =
  types.Instrument

pub type StockInfo =
  types.StockInfo

pub type OHLCV =
  types.OHLCV

pub type StockData =
  types.StockData

pub type Indicator =
  types.Indicator

pub type ProxyConfig =
  types.ProxyConfig

pub type YFinanceConfig =
  types.YFinanceConfig

pub type YFinanceError =
  types.YFinanceError

pub type YFinanceResult(a) =
  types.YFinanceResult(a)

pub type YahooEndpoint =
  types.YahooEndpoint

pub type HttpMethod =
  types.HttpMethod

pub type HttpRequest =
  types.HttpRequest

pub type HttpResponse =
  types.HttpResponse

pub type HttpResult(a) =
  types.HttpResult(a)

// Re-export configuration functions
pub fn default_config() -> YFinanceConfig {
  api.default_config()
}

pub fn config_with_proxy(proxy: ProxyConfig) -> YFinanceConfig {
  api.config_with_proxy(proxy)
}

pub fn proxy(host: String, port: Int) -> ProxyConfig {
  api.proxy(host, port)
}

pub fn proxy_with_auth(
  host: String,
  port: Int,
  username: String,
  password: String,
) -> ProxyConfig {
  api.proxy_with_auth(host, port, username, password)
}

// Re-export main API functions
pub fn get_stock_data(
  symbol: String,
  period: Period,
  interval: Interval,
  config: YFinanceConfig,
) -> YFinanceResult(StockData) {
  api.get_stock_data(symbol, period, interval, config)
}

pub fn get_stock_data_batch(
  symbols: List(String),
  period: Period,
  interval: Interval,
  config: YFinanceConfig,
) -> YFinanceResult(dict.Dict(String, StockData)) {
  api.get_stock_data_batch(symbols, period, interval, config)
}

pub fn get_stock_info(
  symbol: String,
  config: YFinanceConfig,
) -> YFinanceResult(StockInfo) {
  api.get_stock_info(symbol, config)
}

pub fn get_stock_info_batch(
  symbols: List(String),
  config: YFinanceConfig,
) -> YFinanceResult(dict.Dict(String, StockInfo)) {
  api.get_stock_info_batch(symbols, config)
}

pub fn get_current_price(
  symbol: String,
  config: YFinanceConfig,
) -> YFinanceResult(Float) {
  api.get_current_price(symbol, config)
}

pub fn get_current_price_batch(
  symbols: List(String),
  config: YFinanceConfig,
) -> YFinanceResult(dict.Dict(String, Float)) {
  api.get_current_price_batch(symbols, config)
}

pub fn calculate_indicator(
  data: List(OHLCV),
  indicator: Indicator,
) -> List(Float) {
  api.calculate_indicator(data, indicator)
}

pub fn format_error(error: YFinanceError) -> String {
  utils.format_error(error)
}

/// Main entry point for the yfinance library
pub fn main() {
  let config = default_config()
  io.println("Yahoo Finance API Client initialized")

  // Example usage
  let symbols = ["AAPL", "GOOGL", "MSFT"]
  io.println("Fetching batch data for: " <> string.join(symbols, ", "))

  case get_stock_info_batch(symbols, config) {
    Ok(info_dict) -> {
      io.println("Successfully fetched stock info for batch")
      // Print formatted information for each symbol
      list.each(dict.to_list(info_dict), fn(item) {
        let #(symbol, info) = item
        io.println("\n=== " <> symbol <> " ===")
        io.println("Short Name: " <> info.short_name)
        io.println("Long Name: " <> info.long_name)
        io.println("Currency: " <> info.currency)
        io.println("Sector: " <> result.unwrap(info.sector, "N/A"))
        io.println("Industry: " <> result.unwrap(info.industry, "N/A"))
      })
    }
    Error(e) -> {
      io.println("Error: " <> format_error(e))
    }
  }
}
