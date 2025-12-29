# Yahoo Finance API Client for Gleam

A comprehensive Yahoo Finance API client for the Gleam programming language, providing similar functionality to the popular Python `yfinance` package.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [API Reference](#api-reference)
- [Examples](#examples)
  - [Basic Stock Data](#basic-stock-data)
  - [Batch Data Fetching](#batch-data-fetching)
  - [Technical Analysis](#technical-analysis)
  - [Sample Usage Functions](#sample-usage-functions)
- [Error Handling](#error-handling)
- [Advanced Usage](#advanced-usage)
- [Performance Tips](#performance-tips)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)
- [Disclaimer](#disclaimer)
- [Acknowledgments](#acknowledgments)

## Features

### Core Functionality
- **Stock Data Fetching**: Get OHLCV (Open, High, Low, Close, Volume) data for stocks
- **Multiple Time Intervals**: Support for minute, hour, day, week, and month intervals
- **Multiple Time Periods**: From 1 day to 10 years, plus YTD and Max
- ** Limiting**: Intelligent handling of API rate limits
- **Configurable Timeouts**: Customizable request timeouts and retry attempts
- **Batch Processing**: Efficient handling of large symbol lists

### Data Types Supported
- **Stocks**: Individual company shares
- **Cryptocurrencies**: Crypto pairs with currency specification
- **Forex**: Currency exchange pairs
- **ETFs**: Exchange-traded funds
- **Indices**: Market indices (S&P 500, Dow Jones, etc.)
- **Bonds**: Government and corporate bonds
- **Funds**: Mutual funds and other investment funds

## Installation

Add this dependency to your `gleam.toml`:

```toml
[dependencies]
yfinance = ">= 1.0.0 and < 2.0.0"
gleam_stdlib = ">= 0.44.0 and < 2.0.0"
gleam_http = ">= 3.0.0 and < 4.0.0"
gleam_json = ">= 0.7.0 and < 1.0.0"
gleam_result = ">= 0.6.0 and < 1.0.0"
```

## Quick Start

```gleam
import gleam/io
import yfinance

pub fn main() {
  // Create default configuration
  let config = yfinance.default_config()
  
  // Get stock data for Apple
  case yfinance.get_stock_data("AAPL", yfinance.Period.OneMonth, yfinance.Interval.OneDay, config) {
    Ok(stock_data) -> {
      io.println("Symbol: " <> stock_data.symbol)
      io.println("Currency: " <> stock_data.currency)
      io.println("Data points: " <> int.to_string(list.length(stock_data.data)))
      
      // Print latest price
      case stock_data.data {
        [latest, ..] -> {
          io.println("Latest close: " <> float.to_string(latest.close) <> " " <> stock_data.currency)
        }
        _ -> io.println("No data available")
      }
    }
    Error(error) -> {
      io.println("Error: " <> yfinance.format_error(error))
    }
  }
}
```

## API Reference

### Configuration

#### `default_config() -> YFinanceConfig`
Create a default configuration with no proxy.

#### `config_with_proxy(proxy: ProxyConfig) -> YFinanceConfig`
Create a configuration with proxy settings.

#### `proxy(host: String, port: Int) -> ProxyConfig`
Create a simple proxy configuration.

#### `proxy_with_auth(host: String, port: Int, username: String, password: String) -> ProxyConfig`
Create a proxy configuration with authentication.

### Stock Data Fetching

#### `get_stock_data(symbol: String, period: Period, interval: Interval, config: YFinanceConfig) -> YFinanceResult(StockData)`
Get OHLCV data for a single stock symbol.

#### `get_stock_data_batch(symbols: List(String), period: Period, interval: Interval, config: YFinanceConfig) -> YFinanceResult(Dict(String, StockData))`
Get stock data for multiple symbols in a single call.

#### `get_current_price(symbol: String, config: YFinanceConfig) -> YFinanceResult(Float)`
Get the current price for a symbol.

#### `get_current_price_batch(symbols: List(String), config: YFinanceConfig) -> YFinanceResult(Dict(String, Float))`
Get current prices for multiple symbols.

### Stock Information

#### `get_stock_info(symbol: String, config: YFinanceConfig) -> YFinanceResult(StockInfo)`
Get comprehensive information about a stock symbol.

#### `get_stock_info_batch(symbols: List(String), config: YFinanceConfig) -> YFinanceResult(Dict(String, StockInfo))`
Get stock information for multiple symbols.

### Time Intervals

Supported intervals:
- `OneMinute`, `TwoMinutes`, `FiveMinutes`, `FifteenMinutes`, `ThirtyMinutes`
- `SixtyMinutes`, `NinetyMinutes`, `OneHour`
- `OneDay`, `FiveDays`, `OneWeek`, `OneMonth`, `ThreeMonths`

### Time Periods

Supported periods:
- `OneDay`, `FiveDays`
- `OneMonth`, `ThreeMonths`, `SixMonths`
- `OneYear`, `TwoYears`, `FiveYears`, `TenYears`
- `YearToDate`, `Max`

### Asset Types

#### Stocks
```gleam
yfinance.Instrument.Stock("AAPL")
```

#### Cryptocurrencies
```gleam
yfinance.Instrument.Crypto("BTC", "USD")  // Bitcoin in USD
yfinance.Instrument.Crypto("ETH", "USDT") // Ethereum in USDT
```

#### Forex
```gleam
yfinance.Instrument.Forex("USD", "EUR")   // USD to EUR
yfinance.Instrument.Forex("GBP", "JPY")   // GBP to JPY
```

#### Other Assets
```gleam
yfinance.Instrument.ETF("SPY")           // S&P 500 ETF
yfinance.Instrument.Index("^GSPC")       // S&P 500 Index
yfinance.Instrument.Bond("US10Y")        // 10-Year US Treasury
```

### Technical Indicators

#### `calculate_indicator(data: List(Ohlcv), indicator: Indicator) -> List(Float)`

Supported indicators:
- `SimpleMovingAverage(period: Int)`
- `ExponentialMovingAverage(period: Int)`
- `RelativeStrengthIndex(period: Int)`

Example:
```gleam
// Calculate 20-period simple moving average
let sma_20 = yfinance.calculate_indicator(
  stock_data.data,
  yfinance.Indicator.SimpleMovingAverage(20)
)

// Calculate 14-period RSI
let rsi_14 = yfinance.calculate_indicator(
  stock_data.data,
  yfinance.Indicator.RelativeStrengthIndex(14)
)
```

## Examples

### Basic Stock Data
```gleam
import yfinance

pub fn get_aapl_data() {
  let config = yfinance.default_config()
  
  case yfinance.get_stock_data("AAPL", yfinance.Period.OneMonth, yfinance.Interval.OneDay, config) {
    Ok(data) -> {
      io.println("AAPL Monthly Data:")
      io.println("Currency: " <> data.currency)
      io.println("Data Points: " <> int.to_string(list.length(data.data)))
    }
    Error(e) -> io.println("Error: " <> yfinance.format_error(e))
  }
}
```

### Batch Data Fetching
```gleam
pub fn get_market_data() {
  let config = yfinance.default_config()
  let tech_stocks = ["AAPL", "GOOGL", "MSFT", "AMZN", "META"]
  
  case yfinance.get_stock_data_batch(tech_stocks, yfinance.Period.OneWeek, yfinance.Interval.OneDay, config) {
    Ok(batch_data) -> {
      io.println("Fetched data for " <> int.to_string(dict.size(batch_data)) <> " symbols")
      
      dict.to_list(batch_data)
      |> list.each(fn(item) {
        let #(symbol, data) = item
        io.println(symbol <> ": " <> int.to_string(list.length(data.data)) <> " data points")
      })
    }
    Error(e) -> io.println("Error: " <> yfinance.format_error(e))
  }
}
```

### Using Proxy
```gleam
pub fn fetch_with_proxy() {
  // Create proxy configuration
  let proxy = yfinance.proxy("127.0.0.1", 8080)
  let config = yfinance.config_with_proxy(proxy)
  
  case yfinance.get_stock_data("AAPL", yfinance.Period.OneDay, yfinance.Interval.OneHour, config) {
    Ok(data) -> io.println("Success!")
    Error(e) -> io.println("Error: " <> yfinance.format_error(e))
  }
}

pub fn fetch_with_authenticated_proxy() {
  // Create authenticated proxy
  let proxy = yfinance.proxy_with_auth("proxy.example.com", 3128, "username", "password")
  let config = yfinance.config_with_proxy(proxy)
  
  // Use config for API calls
}
```

### Technical Analysis
```gleam
pub fn technical_analysis() {
  let config = yfinance.default_config()
  
  case yfinance.get_stock_data("AAPL", yfinance.Period.SixMonths, yfinance.Interval.OneDay, config) {
    Ok(stock_data) -> {
      let closes = list.map(stock_data.data, fn(ohlcv) { ohlcv.close })
      
      // Calculate moving averages
      let sma_20 = yfinance.calculate_indicator(stock_data.data, yfinance.Indicator.SimpleMovingAverage(20))
      let ema_20 = yfinance.calculate_indicator(stock_data.data, yfinance.Indicator.ExponentialMovingAverage(20))
      let rsi_14 = yfinance.calculate_indicator(stock_data.data, yfinance.Indicator.RelativeStrengthIndex(14))
      
      io.println("Latest 20-SMA: " <> float.to_string(list.first(sma_20) |> option.unwrap(0.0)))
      io.println("Latest RSI: " <> float.to_string(list.first(rsi_14) |> option.unwrap(0.0)))
    }
    Error(e) -> io.println("Error: " <> yfinance.format_error(e))
  }
}
```

### Cryptocurrency Data
```gleam
pub fn get_crypto_data() {
  let config = yfinance.default_config()
  
  // Bitcoin price in USD
  case yfinance.get_stock_data("BTC-USD", yfinance.Period.OneMonth, yfinance.Interval.OneHour, config) {
    Ok(data) -> {
      io.println("Bitcoin data fetched")
      io.println("Currency: " <> data.currency)
    }
    Error(e) -> io.println("Error: " <> yfinance.format_error(e))
  }
}
```

### Forex Data
```gleam
pub fn get_forex_data() {
  let config = yfinance.default_config()
  
  // EUR/USD exchange rate
  case yfinance.get_stock_data("EURUSD=X", yfinance.Period.OneWeek, yfinance.Interval.OneHour, config) {
    Ok(data) -> {
      io.println("EUR/USD data fetched")
    }
    Error(e) -> io.println("Error: " <> yfinance.format_error(e))
  }
}
```

## Error Handling

The library uses a comprehensive error handling system:

```gleam
case yfinance.get_stock_data("INVALID_SYMBOL", yfinance.Period.OneDay, yfinance.Interval.OneDay, config) {
  Ok(data) -> {
    // Success
  }
  Error(error) -> {
    case error {
      yfinance.YFinanceError.NetworkError(msg) -> {
        io.println("Network error: " <> msg)
      }
      yfinance.YFinanceError.ApiError(msg, code) -> {
        io.println("API error (" <> int.to_string(code) <> "): " <> msg)
      }
      yfinance.YFinanceError.ValidationError(msg) -> {
        io.println("Validation error: " <> msg)
      }
      yfinance.YFinanceError.RateLimitError(msg) -> {
        io.println("Rate limit error: " <> msg)
      }
      yfinance.YFinanceError.ParseError(msg) -> {
        io.println("Parse error: " <> msg)
      }
      yfinance.YFinanceError.ProxyError(msg) -> {
        io.println("Proxy error: " <> msg)
      }
    }
  }
}
```

## Sample Usage Functions

The library includes comprehensive sample usage functions in [`examples/examples.gleam`](examples/examples.gleam) that demonstrate how to:

### Running the Examples

To run all examples:

```bash
gleam run -m examples
```

Or run specific examples:

```gleam
import examples

// Run all examples
examples.run_all_examples()

// Run individual examples
examples.fetch_single_stock_1d()
examples.fetch_multiple_stocks_1d()
examples.calculate_sma_example()
examples.calculate_ema_example()
examples.calculate_rsi_example()
examples.fetch_and_calculate_indicators()
examples.get_current_prices()
examples.get_stock_information()
```

### Available Examples

1. **fetch_single_stock_1d**: Fetch 1-day data for a single stock (AAPL)
2. **fetch_multiple_stocks_1d**: Fetch 1-day data for multiple stocks in batch
3. **calculate_sma_example**: Calculate Simple Moving Average (SMA) with sample data
4. **calculate_ema_example**: Calculate Exponential Moving Average (EMA) with sample data
5. **calculate_rsi_example**: Calculate Relative Strength Index (RSI) with sample data
6. **fetch_and_calculate_indicators**: Fetch real data and calculate indicators
7. **get_current_prices**: Get current prices for multiple stocks
8. **get_stock_information**: Get comprehensive stock information

### Example Output

When you run the examples, you'll see output like:

```
========================================
Yahoo Finance API - Sample Usage Examples
========================================

=== Example 1: Fetch 1-Day Data for AAPL ===
Symbol: AAPL
Currency: USD
Data Points: 1
Latest Price:
  Open: 100.0
  High: 105.0
  Low: 95.0
  Close: 103.0
  Volume: 1000000

=== Example 2: Fetch 1-Day Data for Multiple Stocks ===
Successfully fetched data for 4 symbols
AAPL: $103.0
GOOGL: $106.0
MSFT: $108.0
AMZN: $110.0

=== Example 3: Calculate Simple Moving Average ===
3-period SMA values:
  105.66666666666667
  108.0
  111.33333333333333
  ...

========================================
All examples completed!
========================================
```

## Advanced Usage

### Custom Configuration
```gleam
pub fn custom_config() {
  // Create a proxy with custom settings
  let proxy = yfinance.proxy("proxy.company.com", 8080)
  
  // Create custom configuration
  let config = yfinance.YFinanceConfig(
    proxy: Ok(proxy),
    user_agent: "MyApp/1.0",
    timeout: 60000,      // 60 second timeout
    max_retries: 5,      // More retries
    batch_size: 25,      // Smaller batches
  )
  
  // Use the custom config
}
```

### Multiple Asset Types
```gleam
pub fn mixed_assets() {
  let config = yfinance.default_config()
  
  let assets = [
    yfinance.Instrument.Stock("AAPL"),
    yfinance.Instrument.Crypto("BTC", "USD"),
    yfinance.Instrument.Forex("USD", "EUR"),
    yfinance.Instrument.ETF("SPY"),
    yfinance.Instrument.Index("^GSPC"),
  ]
  
  list.each(assets, fn(asset) {
    let symbol = yfinance.utils.instrument_to_symbol(asset)
    io.println("Fetching data for: " <> symbol)
    
    case yfinance.get_stock_data(symbol, yfinance.Period.OneDay, yfinance.Interval.OneDay, config) {
      Ok(data) -> io.println("Success!")
      Error(e) -> io.println("Error: " <> yfinance.format_error(e))
    }
  })
}
```

## Performance Tips

1. **Use Batch Operations**: When fetching data for multiple symbols, use batch functions to reduce API calls.

2. **Configure Batch Size**: Adjust the `batch_size` in your configuration based on your needs.

3. **Use Appropriate Intervals**: Use larger intervals (daily, weekly) for long periods to reduce data size.

4. **Handle Rate Limiting**: The library automatically handles rate limiting, but you can also implement your own delays between batches.

5. **Use Proxy for Geo-restrictions**: If you're accessing from a region with restrictions, configure a proxy.

## Project Structure

```
src/
├── yfinance.gleam          # Main module with re-exports and public API
└── yfinance/
    ├── types.gleam         # Type definitions (Interval, Period, StockData, etc.)
    ├── utils.gleam         # Utility functions (indicators, conversions, validation)
    ├── http_client.gleam   # HTTP client implementation (mocked for now)
    └── api.gleam           # Main API functions (get_stock_data, etc.)

examples/
└── examples.gleam          # Comprehensive sample usage examples

test/
└── yfinance_test.gleam     # Comprehensive test suite

docs/
└── (additional documentation)
```

### Module Overview

#### `yfinance.gleam`
Main entry point that re-exports all public types and functions for convenient access.

#### `yfinance/types.gleam`
Contains all type definitions:
- `Interval`: Time intervals (OneMinute, OneDay, etc.)
- `Period`: Time periods (PeriodOneDay, OneYear, etc.)
- `Instrument`: Asset types (Stock, Crypto, Forex, etc.)
- `StockInfo`: Comprehensive stock information
- `Ohlcv`: OHLCV (Open, High, Low, Close, Volume) data point
- `StockData`: Stock data with metadata
- `Indicator`: Technical indicators (SMA, EMA, RSI, etc.)
- `ProxyConfig`: Proxy configuration
- `YFinanceConfig`: API request configuration
- `YFinanceError`: Error types

#### `yfinance/utils.gleam`
Utility functions including:
- Interval and period conversions
- Instrument to symbol conversion
- Technical indicator calculations (SMA, EMA, RSI)
- Validation functions
- Error formatting
- List chunking
- Retry logic with backoff

#### `yfinance/http_client.gleam`
HTTP client implementation (currently mocked):
- Request execution with retry logic
- Response parsing
- Rate limit handling
- Proxy support

#### `yfinance/api.gleam`
Main API functions:
- Configuration management
- Stock data fetching (single and batch)
- Stock information retrieval
- Current price queries
- Technical indicator calculations
- Specialized data fetching (crypto, forex, indices)

#### `examples/examples.gleam`
Comprehensive examples demonstrating:
- Fetching 1-day data for single and multiple stocks
- Calculating technical indicators
- Getting current prices
- Retrieving stock information
- Error handling patterns

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Disclaimer

This library is for educational and research purposes. The data provided by Yahoo Finance is subject to their terms of service. Please ensure compliance with Yahoo Finance's API terms when using this library in production applications.

## Acknowledgments

- Inspired by the Python `yfinance` package
- Built with the Gleam programming language
- Uses Yahoo Finance API for market data

## Getting Started Guide

### 1. Installation

Add the dependency to your `gleam.toml`:

```toml
[dependencies]
yfinance = ">= 1.0.0 and < 2.0.0"
gleam_stdlib = ">= 0.44.0 and < 2.0.0"
gleam_http = ">= 3.0.0 and < 4.0.0"
gleam_json = ">= 0.7.0 and < 1.0.0"
gleam_result = ">= 0.6.0 and < 1.0.0"
```

### 2. Basic Usage

```gleam
import gleam/io
import yfinance

pub fn main() {
  let config = yfinance.default_config()
  
  case yfinance.get_stock_data("AAPL", yfinance.PeriodOneDay, yfinance.OneDay, config) {
    Ok(stock_data) -> {
      io.println("Symbol: " <> stock_data.symbol)
      io.println("Latest Price: " <> float.to_string(latest.close))
    }
    Error(e) -> {
      io.println("Error: " <> yfinance.format_error(e))
    }
  }
}
```

### 3. Run Examples

```bash
# Run all examples
gleam run -m examples

# Or run specific examples in your code
import examples
examples.run_all_examples()
```

### 4. Explore the API

Check out the [API Reference](#api-reference) section for detailed documentation of all available functions.

### 5. Technical Analysis

The library includes built-in technical indicators:

```gleam
// Calculate moving averages
let sma_20 = yfinance.calculate_indicator(data, yfinance.SimpleMovingAverage(20))
let ema_20 = yfinance.calculate_indicator(data, yfinance.ExponentialMovingAverage(20))
let rsi_14 = yfinance.calculate_indicator(data, yfinance.RelativeStrengthIndex(14))
```

## Development Status

This project is currently in active development. The HTTP client implementation is mocked for testing purposes. Future versions will include:

- Full HTTP client implementation with real API calls
- Additional technical indicators (MACD, Bollinger Bands, Stochastic)
- Support for more data types (options, futures, etc.)
- Enhanced error handling and retry logic
- Performance optimizations for large-scale data fetching

## Troubleshooting

### Common Issues

**Issue**: "No data available" error
- **Solution**: Check if the symbol is valid and the market is open

**Issue**: "Invalid interval for given period" error
- **Solution**: Ensure the interval is compatible with the period (e.g., minute intervals only work with short periods)

**Issue**: "Rate limit exceeded" error
- **Solution**: Implement delays between requests or use a proxy

### Getting Help

- Check the [examples](#sample-usage-functions) for usage patterns
- Review the [test suite](test/yfinance_test.gleam) for more examples
- Open an issue on GitHub for bugs or feature requests
