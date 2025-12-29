//// Sample usage examples for Yahoo Finance API client
//// Demonstrates how to fetch 1d data and calculate indicators

import gleam/io
import gleam/list
import gleam/result

import gleam/dict
import gleam/float
import gleam/int

import yfinance
import yfinance/types.{
  type Ohlcv, ExponentialMovingAverage, Ohlcv, OneDay, PeriodOneDay,
  RelativeStrengthIndex, SimpleMovingAverage,
}

/// Example 1: Fetch 1-day data for a single stock
pub fn fetch_single_stock_1d() {
  io.println("=== Example 1: Fetch 1-Day Data for AAPL ===")

  let config = yfinance.default_config()
  let symbol = "AAPL"

  case yfinance.get_stock_data(symbol, PeriodOneDay, OneDay, config) {
    Ok(stock_data) -> {
      io.println("Symbol: " <> stock_data.symbol)
      io.println("Currency: " <> stock_data.currency)
      io.println("Data Points: " <> int.to_string(list.length(stock_data.data)))

      case stock_data.data {
        [latest, ..] -> {
          io.println("Latest Price:")
          io.println("  Open: " <> float.to_string(latest.open))
          io.println("  High: " <> float.to_string(latest.high))
          io.println("  Low: " <> float.to_string(latest.low))
          io.println("  Close: " <> float.to_string(latest.close))
          io.println("  Volume: " <> int.to_string(latest.volume))
        }
        _ -> io.println("No data available")
      }
    }
    Error(e) -> {
      io.println("Error fetching data: " <> yfinance.format_error(e))
    }
  }

  io.println("")
}

/// Example 2: Fetch 1-day data for multiple stocks
pub fn fetch_multiple_stocks_1d() {
  io.println("=== Example 2: Fetch 1-Day Data for Multiple Stocks ===")

  let config = yfinance.default_config()
  let symbols = ["AAPL", "GOOGL", "MSFT", "AMZN", "META"]

  case yfinance.get_stock_data_batch(symbols, PeriodOneDay, OneDay, config) {
    Ok(data_dict) -> {
      io.println(
        "Successfully fetched data for "
        <> int.to_string(dict.size(data_dict))
        <> " symbols",
      )

      // Print summary for each symbol
      list.each(dict.to_list(data_dict), fn(item) {
        let #(symbol, data) = item
        case data.data {
          [latest, ..] -> {
            io.println(symbol <> ": $" <> float.to_string(latest.close))
          }
          _ -> io.println(symbol <> ": No data available")
        }
      })
    }
    Error(e) -> {
      io.println("Error fetching batch data: " <> yfinance.format_error(e))
    }
  }

  io.println("")
}

/// Example 3: Calculate Simple Moving Average (SMA)
pub fn calculate_sma_example() {
  io.println("=== Example 3: Calculate Simple Moving Average ===")

  // Create sample OHLCV data (in real usage, this would come from API)
  let sample_data: List(Ohlcv) = [
    Ohlcv(1_704_038_400, 100.0, 105.0, 95.0, 103.0, 102.0, 1_000_000),
    Ohlcv(1_704_124_800, 103.0, 108.0, 102.0, 106.0, 105.0, 1_100_000),
    Ohlcv(1_704_211_200, 106.0, 110.0, 105.0, 108.0, 107.0, 1_200_000),
    Ohlcv(1_704_297_600, 108.0, 112.0, 107.0, 110.0, 109.0, 1_300_000),
    Ohlcv(1_704_384_000, 110.0, 114.0, 109.0, 112.0, 111.0, 1_400_000),
    Ohlcv(1_704_470_400, 112.0, 116.0, 111.0, 115.0, 114.0, 1_500_000),
    Ohlcv(1_704_556_800, 115.0, 118.0, 114.0, 117.0, 116.0, 1_600_000),
    Ohlcv(1_704_643_200, 117.0, 120.0, 116.0, 119.0, 118.0, 1_700_000),
    Ohlcv(1_704_729_600, 119.0, 122.0, 118.0, 121.0, 120.0, 1_800_000),
    Ohlcv(1_704_816_000, 121.0, 124.0, 120.0, 123.0, 122.0, 1_900_000),
  ]

  // Calculate 3-period SMA
  let sma_3 = yfinance.calculate_indicator(sample_data, SimpleMovingAverage(3))
  io.println("3-period SMA values:")
  list.each(sma_3, fn(sma) { io.println("  " <> float.to_string(sma)) })

  // Calculate 5-period SMA
  let sma_5 = yfinance.calculate_indicator(sample_data, SimpleMovingAverage(5))
  io.println("\n5-period SMA values:")
  list.each(sma_5, fn(sma) { io.println("  " <> float.to_string(sma)) })

  io.println("")
}

/// Example 4: Calculate Exponential Moving Average (EMA)
pub fn calculate_ema_example() {
  io.println("=== Example 4: Calculate Exponential Moving Average ===")

  // Create sample OHLCV data
  let sample_data: List(Ohlcv) = [
    Ohlcv(1_704_038_400, 100.0, 105.0, 95.0, 103.0, 102.0, 1_000_000),
    Ohlcv(1_704_124_800, 103.0, 108.0, 102.0, 106.0, 105.0, 1_100_000),
    Ohlcv(1_704_211_200, 106.0, 110.0, 105.0, 108.0, 107.0, 1_200_000),
    Ohlcv(1_704_297_600, 108.0, 112.0, 107.0, 110.0, 109.0, 1_300_000),
    Ohlcv(1_704_384_000, 110.0, 114.0, 109.0, 112.0, 111.0, 1_400_000),
    Ohlcv(1_704_470_400, 112.0, 116.0, 111.0, 115.0, 114.0, 1_500_000),
    Ohlcv(1_704_556_800, 115.0, 118.0, 114.0, 117.0, 116.0, 1_600_000),
    Ohlcv(1_704_643_200, 117.0, 120.0, 116.0, 119.0, 118.0, 1_700_000),
    Ohlcv(1_704_729_600, 119.0, 122.0, 118.0, 121.0, 120.0, 1_800_000),
    Ohlcv(1_704_816_000, 121.0, 124.0, 120.0, 123.0, 122.0, 1_900_000),
  ]

  // Calculate 3-period EMA
  let ema_3 =
    yfinance.calculate_indicator(sample_data, ExponentialMovingAverage(3))
  io.println("3-period EMA values:")
  list.each(ema_3, fn(ema) { io.println("  " <> float.to_string(ema)) })

  // Calculate 5-period EMA
  let ema_5 =
    yfinance.calculate_indicator(sample_data, ExponentialMovingAverage(5))
  io.println("\n5-period EMA values:")
  list.each(ema_5, fn(ema) { io.println("  " <> float.to_string(ema)) })

  io.println("")
}

/// Example 5: Calculate Relative Strength Index (RSI)
pub fn calculate_rsi_example() {
  io.println("=== Example 5: Calculate Relative Strength Index ===")

  // Create sample OHLCV data with more points for RSI calculation
  let sample_data: List(Ohlcv) = [
    Ohlcv(1_704_038_400, 100.0, 105.0, 95.0, 103.0, 102.0, 1_000_000),
    Ohlcv(1_704_124_800, 103.0, 108.0, 102.0, 106.0, 105.0, 1_100_000),
    Ohlcv(1_704_211_200, 106.0, 110.0, 105.0, 108.0, 107.0, 1_200_000),
    Ohlcv(1_704_297_600, 108.0, 112.0, 107.0, 110.0, 109.0, 1_300_000),
    Ohlcv(1_704_384_000, 110.0, 114.0, 109.0, 112.0, 111.0, 1_400_000),
    Ohlcv(1_704_470_400, 112.0, 116.0, 111.0, 115.0, 114.0, 1_500_000),
    Ohlcv(1_704_556_800, 115.0, 118.0, 114.0, 117.0, 116.0, 1_600_000),
    Ohlcv(1_704_643_200, 117.0, 120.0, 116.0, 119.0, 118.0, 1_700_000),
    Ohlcv(1_704_729_600, 119.0, 122.0, 118.0, 121.0, 120.0, 1_800_000),
    Ohlcv(1_704_816_000, 121.0, 124.0, 120.0, 123.0, 122.0, 1_900_000),
    Ohlcv(1_704_902_400, 123.0, 126.0, 122.0, 125.0, 124.0, 2_000_000),
    Ohlcv(1_704_988_800, 125.0, 128.0, 124.0, 127.0, 126.0, 2_100_000),
    Ohlcv(1_705_075_200, 127.0, 130.0, 126.0, 129.0, 128.0, 2_200_000),
    Ohlcv(1_705_161_600, 129.0, 132.0, 128.0, 131.0, 130.0, 2_300_000),
    Ohlcv(1_705_248_000, 131.0, 134.0, 130.0, 133.0, 132.0, 2_400_000),
  ]

  // Calculate 14-period RSI (standard period)
  let rsi_14 =
    yfinance.calculate_indicator(sample_data, RelativeStrengthIndex(14))
  case rsi_14 {
    [rsi_value, ..] -> {
      io.println("14-period RSI: " <> float.to_string(rsi_value))
      io.println("RSI Interpretation:")
      case rsi_value {
        v if v >. 70.0 -> io.println("  Overbought condition (RSI > 70)")
        v if v <. 30.0 -> io.println("  Oversold condition (RSI < 30)")
        _ -> io.println("  Neutral zone (30 <= RSI <= 70)")
      }
    }
    _ ->
      io.println(
        "Not enough data points for RSI calculation (need at least 15)",
      )
  }

  io.println("")
}

/// Example 6: Fetch real data and calculate indicators
pub fn fetch_and_calculate_indicators() {
  io.println("=== Example 6: Fetch 1-Day Data and Calculate Indicators ===")

  let config = yfinance.default_config()
  let symbol = "AAPL"

  case yfinance.get_stock_data(symbol, PeriodOneDay, OneDay, config) {
    Ok(stock_data) -> {
      io.println("Fetched data for " <> stock_data.symbol)
      io.println("Data points: " <> int.to_string(list.length(stock_data.data)))

      // Calculate indicators if we have enough data
      let data_count = list.length(stock_data.data)

      case data_count >= 3 {
        True -> {
          let sma_3 =
            yfinance.calculate_indicator(
              stock_data.data,
              SimpleMovingAverage(3),
            )
          io.println(
            "\n3-period SMA calculated: "
            <> int.to_string(list.length(sma_3))
            <> " values",
          )
          case list.first(sma_3) {
            Ok(value) ->
              io.println("  Latest SMA(3): " <> float.to_string(value))
            Error(_) -> io.println("  No SMA value available")
          }
        }
        False -> io.println("Not enough data for SMA(3) calculation")
      }

      case data_count >= 5 {
        True -> {
          let ema_5 =
            yfinance.calculate_indicator(
              stock_data.data,
              ExponentialMovingAverage(5),
            )
          io.println(
            "\n5-period EMA calculated: "
            <> int.to_string(list.length(ema_5))
            <> " values",
          )
          case list.first(ema_5) {
            Ok(value) ->
              io.println("  Latest EMA(5): " <> float.to_string(value))
            Error(_) -> io.println("  No EMA value available")
          }
        }
        False -> io.println("Not enough data for EMA(5) calculation")
      }

      case data_count >= 15 {
        True -> {
          let rsi_14 =
            yfinance.calculate_indicator(
              stock_data.data,
              RelativeStrengthIndex(14),
            )
          io.println(
            "\n14-period RSI calculated: "
            <> int.to_string(list.length(rsi_14))
            <> " values",
          )
          case list.first(rsi_14) {
            Ok(value) -> {
              io.println("  Latest RSI(14): " <> float.to_string(value))
              case value {
                v if v >. 70.0 -> io.println("  Signal: Overbought")
                v if v <. 30.0 -> io.println("  Signal: Oversold")
                _ -> io.println("  Signal: Neutral")
              }
            }
            Error(_) -> io.println("  No RSI value available")
          }
        }
        False ->
          io.println(
            "Not enough data for RSI(14) calculation (need at least 15 data points)",
          )
      }
    }
    Error(e) -> {
      io.println("Error fetching data: " <> yfinance.format_error(e))
    }
  }

  io.println("")
}

/// Example 7: Get current prices for multiple stocks
pub fn get_current_prices() {
  io.println("=== Example 7: Get Current Prices for Multiple Stocks ===")

  let config = yfinance.default_config()
  let symbols = ["AAPL", "GOOGL", "MSFT", "AMZN"]

  case yfinance.get_current_price_batch(symbols, config) {
    Ok(prices_dict) -> {
      io.println("Current prices:")
      list.each(dict.to_list(prices_dict), fn(item) {
        let #(symbol, price) = item
        io.println("  " <> symbol <> ": $" <> float.to_string(price))
      })
    }
    Error(e) -> {
      io.println("Error fetching prices: " <> yfinance.format_error(e))
    }
  }

  io.println("")
}

/// Example 8: Get stock information
pub fn get_stock_information() {
  io.println("=== Example 8: Get Stock Information ===")

  let config = yfinance.default_config()
  let symbol = "AAPL"

  case yfinance.get_stock_info(symbol, config) {
    Ok(stock_info) -> {
      io.println("Stock Information for " <> stock_info.symbol)
      io.println("  Short Name: " <> stock_info.short_name)
      io.println("  Long Name: " <> stock_info.long_name)
      io.println("  Currency: " <> stock_info.currency)
      io.println("  Sector: " <> result.unwrap(stock_info.sector, "N/A"))
      io.println("  Industry: " <> result.unwrap(stock_info.industry, "N/A"))
      io.println("  Website: " <> result.unwrap(stock_info.website, "N/A"))

      case stock_info.market_cap {
        Ok(cap) -> io.println("  Market Cap: $" <> int.to_string(cap))
        Error(_) -> io.println("  Market Cap: N/A")
      }

      case stock_info.trailing_pe {
        Ok(pe) -> io.println("  P/E Ratio: " <> float.to_string(pe))
        Error(_) -> io.println("  P/E Ratio: N/A")
      }
    }
    Error(e) -> {
      io.println("Error fetching stock info: " <> yfinance.format_error(e))
    }
  }

  io.println("")
}

/// Run all examples
pub fn run_all_examples() {
  io.println("========================================")
  io.println("Yahoo Finance API - Sample Usage Examples")
  io.println("========================================")
  io.println("")

  fetch_single_stock_1d()
  fetch_multiple_stocks_1d()
  calculate_sma_example()
  calculate_ema_example()
  calculate_rsi_example()
  fetch_and_calculate_indicators()
  get_current_prices()
  get_stock_information()

  io.println("========================================")
  io.println("All examples completed!")
  io.println("========================================")
}

pub fn main() {
  run_all_examples()
}
