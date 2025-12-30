# Proxy Test Suite

This directory contains examples to test the proxy functionality in the yfinance Gleam library.

## Overview

The proxy test suite validates that proxy configuration works correctly by making HTTP requests to Wikipedia.

## Files

- **`proxy_test.gleam`** - Main test suite with various proxy tests (legacy functions kept for reference)
- **`proxy_test_no_proxy.gleam`** - Test fetching Wikipedia without proxy
- **`proxy_test_with_proxy.gleam`** - Test fetching Wikipedia with proxy (127.0.0.1:7890)
- **`proxy_test_article_no_proxy.gleam`** - Test fetching Wikipedia article without proxy
- **`proxy_test_article_with_proxy.gleam`** - Test fetching Wikipedia article with proxy
- **`proxy_test_performance.gleam`** - Compare performance with/without proxy
- **`proxy_test_ports.gleam`** - Test different proxy ports
- **`examples.gleam`** - General usage examples for the yfinance API

## Running the Tests

### Running Individual Tests

Each test module can be run independently using the `--module` flag:

```bash
# Test without proxy
gleam run --module proxy_test_no_proxy

# Test with proxy (127.0.0.1:7890)
gleam run --module proxy_test_with_proxy

# Test article without proxy
gleam run --module proxy_test_article_no_proxy

# Test article with proxy
gleam run --module proxy_test_article_with_proxy

# Performance comparison
gleam run --module proxy_test_performance

# Test different proxy ports
gleam run --module proxy_test_ports
```

### Show Available Tests

To see all available test modules:

```bash
gleam run --module proxy_test
```

### Legacy Functions (proxy_test.gleam)

The main [`proxy_test.gleam`](proxy_test.gleam) file contains legacy test functions that can be called programmatically. To use them, edit the `main()` function or import the module:

```gleam
import proxy_test

// Available functions:
//   - test_wikipedia_no_proxy()
//   - test_wikipedia_with_proxy()
//   - test_wikipedia_article_no_proxy()
//   - test_wikipedia_article_with_proxy()
//   - test_performance_comparison()
//   - test_different_proxy_ports()
//   - run_all_proxy_tests()
//   - run_quick_test()
```

## Proxy Configuration

Default proxy settings:
- Host: `127.0.0.1`
- Port: `7890`

Ensure your proxy server is running before executing the tests.

## Test Output

When tests run successfully, you will see output indicating:
- ✓ SUCCESS for successful requests
- Status code (e.g., 200)
- Response length in bytes
- Whether response contains Wikipedia content

When tests fail, you will see:
- ✗ FAILED
- Error message with suggestions for troubleshooting