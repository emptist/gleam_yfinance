//// Type definitions for Yahoo Finance API
//// Similar to the Python yfinance package

import gleam/dict

/// Time intervals for stock data
pub type Interval {
  OneMinute
  TwoMinutes
  FiveMinutes
  FifteenMinutes
  ThirtyMinutes
  SixtyMinutes
  NinetyMinutes
  OneHour
  OneDay
  FiveDays
  OneWeek
  OneMonth
  ThreeMonths
}

/// Time periods for stock data
pub type Period {
  PeriodOneDay
  PeriodFiveDays
  PeriodOneMonth
  PeriodThreeMonths
  SixMonths
  OneYear
  TwoYears
  FiveYears
  TenYears
  YearToDate
  Max
}

/// Types of financial instruments
pub type Instrument {
  Stock(String)
  Crypto(String, String)
  // crypto symbol, currency
  Forex(String, String)
  // forex pair
  Fund(String)
  // fund symbol
  Index(String)
  // index symbol
  ETF(String)
  // ETF symbol
  Bond(String)
  // bond symbol
}

/// Comprehensive stock information
pub type StockInfo {
  StockInfo(
    symbol: String,
    short_name: String,
    long_name: String,
    currency: String,
    market_cap: Result(Int, String),
    enterprise_value: Result(Int, String),
    trailing_pe: Result(Float, String),
    forward_pe: Result(Float, String),
    peg_ratio: Result(Float, String),
    price_to_book: Result(Float, String),
    price_to_sales: Result(Float, String),
    dividend_yield: Result(Float, String),
    earnings_growth: Result(Float, String),
    revenue_growth: Result(Float, String),
    profit_margin: Result(Float, String),
    operating_margin: Result(Float, String),
    return_on_assets: Result(Float, String),
    return_on_equity: Result(Float, String),
    beta: Result(Float, String),
    shares_outstanding: Result(Int, String),
    book_value: Result(Float, String),
    fifty_two_week_high: Result(Float, String),
    fifty_two_week_low: Result(Float, String),
    sector: Result(String, String),
    industry: Result(String, String),
    country: Result(String, String),
    website: Result(String, String),
    business_summary: Result(String, String),
    full_time_employees: Result(Int, String),
    timestamp: Int,
  )
}

/// OHLCV (Open, High, Low, Close, Volume) data point
pub type OHLCV {
  Ohlcv(
    timestamp: Int,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    adj_close: Float,
    volume: Int,
  )
}

/// Stock data with metadata
pub type StockData {
  StockData(
    symbol: String,
    interval: Interval,
    period: Period,
    data: List(OHLCV),
    currency: String,
    symbol_info: Result(StockInfo, String),
    is_crypto: Bool,
    is_forex: Bool,
    exchange: Result(String, String),
  )
}

/// Technical indicators
pub type Indicator {
  SimpleMovingAverage(Int)
  // period
  ExponentialMovingAverage(Int)
  // period
  RelativeStrengthIndex(Int)
  // period
  MovingAverageConvergence(Int)
  // fast, slow, signal
  BollingerBands(Int, Float)
  // period, standard deviations
  Stochastic(Int, Int)
  // %K period, %D period
}

/// Configuration for proxy settings
pub type ProxyConfig {
  ProxyConfig(
    host: String,
    port: Int,
    username: Result(String, String),
    password: Result(String, String),
    scheme: String,
    // "http" or "https"
  )
}

/// Configuration for Yahoo Finance API requests
pub type YFinanceConfig {
  YFinanceConfig(
    proxy: Result(ProxyConfig, String),
    user_agent: String,
    timeout: Int,
    // milliseconds
    max_retries: Int,
    batch_size: Int,
    // Number of symbols per batch request
  )
}

/// Error types
pub type YFinanceError {
  NetworkError(String)
  ApiError(String, Int)
  // message, status code
  ParseError(String)
  ValidationError(String)
  RateLimitError(String)
  ProxyError(String)
  TimeoutError(String)
}

/// Result type for API operations
pub type YFinanceResult(a) =
  Result(a, YFinanceError)

/// Yahoo Finance API endpoints
pub type YahooEndpoint {
  QuoteEndpoint
  // /quote
  ChartEndpoint
  // /chart
  SummaryEndpoint
  // /summary
  HistoricalEndpoint
  // /historical
  SearchEndpoint
  // /search
  ProfileEndpoint
  // /profile
  StatisticsEndpoint
  // /statistics
  FinancialDataEndpoint
  // /financial-data
  DefaultKeyStatistics
  // /default-key-statistics
}

/// HTTP types for the client
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
    headers: dict.Dict(String, String),
    body: Result(String, String),
  )
}

pub type HttpResponse {
  HttpResponse(
    status_code: Int,
    headers: dict.Dict(String, String),
    body: String,
  )
}

/// HTTP client result
pub type HttpResult(a) =
  Result(a, String)
