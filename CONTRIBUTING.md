# Contributing to yfinance for Gleam

Thank you for your interest in contributing to the yfinance library for Gleam! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Running Tests](#running-tests)
- [Running Examples](#running-examples)
- [Code Style](#code-style)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

This project adheres to a code of conduct that all contributors are expected to follow:

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other community members

## Getting Started

### Prerequisites

- Gleam compiler (>= 0.44.0)
- Git
- A text editor or IDE (VS Code with Gleam extension recommended)

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/yfinance.git
   cd yfinance
   ```

3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/yfinance.git
   ```

## Development Setup

### Install Dependencies

```bash
gleam deps download
```

### Build the Project

```bash
gleam build
```

### Run Tests

```bash
gleam test
```

All tests should pass before submitting changes.

### Run Examples

The project includes comprehensive examples demonstrating various features:

```bash
gleam run -m examples
```

Or run specific examples in your code:

```gleam
import examples

examples.run_all_examples()
```

## Running Tests

### Run All Tests

```bash
gleam test
```

### Run Specific Test

```bash
gleam test yfinance_test
```

### Test Coverage

The test suite includes:
- Configuration tests
- Type conversion tests
- Utility function tests
- Technical indicator tests
- Mock API tests
- Error handling tests

Currently, all 22 tests pass successfully.

## Code Style

### Gleam Conventions

Follow Gleam's official style guide:
- Use 2-space indentation
- Use descriptive variable and function names
- Add doc comments for all public functions
- Use pattern matching where appropriate

### Documentation

All public functions must have doc comments:

```gleam
/// Get stock data for a symbol
///
/// ## Parameters
///   - symbol: The stock symbol (e.g., "AAPL")
///   - period: The time period for data
///   - interval: The time interval for data points
///   - config: The configuration for the API request
///
/// ## Returns
///   A Result containing StockData or a YFinanceError
///
/// ## Example
///   ```gleam
///   let config = yfinance.default_config()
///   case yfinance.get_stock_data("AAPL", PeriodOneDay, OneDay, config) {
///     Ok(data) -> io.println("Got data!")
///     Error(e) -> io.println("Error: " <> yfinance.format_error(e))
///   }
///   ```
pub fn get_stock_data(
  symbol: String,
  period: Period,
  interval: Interval,
  config: YFinanceConfig,
) -> YFinanceResult(StockData) {
  // implementation
}
```

### Type Safety

- Ensure all functions have proper type annotations
- Use Result types for operations that can fail
- Avoid using `Error` type constructors as types (see TYPE_FIX_SUMMARY.md)

### Error Handling

- Use the `YFinanceError` type for all error cases
- Provide descriptive error messages
- Handle all possible error cases in pattern matching

## Submitting Changes

### Workflow

1. Create a new branch for your feature or bugfix:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bugfix-name
   ```

2. Make your changes and write tests:
   - Write tests for new functionality
   - Ensure all existing tests pass
   - Update documentation if needed

3. Commit your changes:
   ```bash
   git add .
   git commit -m "feat: add new feature"  # or "fix: resolve issue"
   ```

   Use conventional commit messages:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `style:` for code style changes
   - `refactor:` for code refactoring
   - `test:` for test changes
   - `chore:` for maintenance tasks

4. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

5. Create a pull request on GitHub:
   - Provide a clear description of your changes
   - Reference any related issues
   - Include screenshots if applicable
   - Ensure all CI checks pass

### Pull Request Checklist

Before submitting a PR, ensure:

- [ ] All tests pass
- [ ] Code follows the project's style guidelines
- [ ] Public functions have doc comments
- [ ] Examples are updated if needed
- [ ] README.md is updated if needed
- [ ] No compiler warnings (unless documented)
- [ ] Changes are backward compatible

## Reporting Issues

### Bug Reports

When reporting a bug, include:

- Clear description of the bug
- Steps to reproduce
- Expected behavior
- Actual behavior
- Gleam version
- Operating system
- Code example demonstrating the issue

### Feature Requests

When requesting a feature, include:

- Clear description of the feature
- Use case or problem it solves
- Proposed API or implementation approach
- Examples of how it would be used

## Development Priorities

### Current Focus Areas

1. **HTTP Client Implementation**
   - Implement actual HTTP execution
   - Implement JSON parsing for all response types
   - Implement batch API calls for better performance

2. **Technical Indicators**
   - Implement MACD (Moving Average Convergence Divergence)
   - Implement Bollinger Bands
   - Implement Stochastic Oscillator
   - Implement additional indicators as needed

3. **Data Types**
   - Add support for options data
   - Add support for futures data
   - Add support for additional asset classes

4. **Error Handling**
   - Improve error messages
   - Add more specific error types
   - Implement retry logic with exponential backoff

5. **Performance**
   - Optimize batch operations
   - Implement caching strategies
   - Reduce memory usage for large datasets

## Questions?

If you have questions about contributing:

- Check existing issues and pull requests
- Read the [README.md](README.md) for project overview
- Review the [examples](examples/examples.gleam) for usage patterns
- Open an issue for questions not covered in documentation

## License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.