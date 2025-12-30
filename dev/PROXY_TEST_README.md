# Proxy Test Suite

This directory contains examples to test the proxy functionality in the yfinance Gleam library.

## Overview

The proxy test suite (`proxy_test.gleam`) validates that proxy configuration works correctly by making HTTP requests to Google and YouTube.

## Files

- **`proxy_test.gleam`** - Main test suite with various proxy tests
- **`examples.gleam`** - General usage examples for the yfinance API

## Running the Tests

### Quick Test (Google with Proxy)

Run a quick smoke test to verify proxy connectivity:

```bash
gleam run --module dev/proxy_test
```

### Full Test Suite

Run all proxy tests:

```bash
gleam run --module proxy_test -- run_all_proxy_tests
```

### Individual Tests

You can run specific test functions:

```bash
# Test Google without proxy
gleam run --module dev/proxy_test -- test_google_no_proxy

# Test Google with proxy
gleam run --module dev/proxy_test -- test_google_with_proxy

# Test YouTube without proxy
gleam run --module dev/proxy_test -- test_youtube_no_proxy

# Test YouTube with proxy
gleam run --module dev/proxy_test -- test_youtube_with_proxy

# Performance comparison
gleam run --module dev/proxy_test -- test_performance_comparison

# Test different proxy ports
gleam run --module dev/proxy_test -- test_different_proxy_ports
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
- Whether the response contains expected content ("google" or "youtube")

When tests fail, you will see:
- ✗ FAILED
- Error message with suggestions for troubleshooting