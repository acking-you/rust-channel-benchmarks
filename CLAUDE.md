# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rust channel library benchmarks comparing Kanal against other channel implementations (crossbeam-channel, flume, async-channel, futures-channel, std::mpsc, and Go channels).

## Commands

```bash
# Run full benchmark suite (builds all, runs benchmarks, generates plots)
./run.sh

# Run only Kanal benchmarks (faster iteration)
./krun.sh

# Build a single benchmark binary
RUSTFLAGS="-C target-cpu=native" cargo build --release --bin <name>
# Available bins: crossbeam-channel, kanal, kanal-async, kanal-std-mutex,
#                 kanal-std-mutex-async, flume, flume-async, futures-channel,
#                 mpsc, async-channel

# Run a single benchmark (outputs CSV to stdout)
./target/release/<bin-name>

# Generate plots from existing CSV files
./plot.py target/*.csv
```

## Architecture

Each benchmark binary is a standalone `.rs` file that includes shared modules via `std::include!()`:
- `settings.rs` - Constants: MESSAGES, THREADS, MIN_BENCH_TIME
- `z_types.rs` - Message types: BenchEmpty, BenchUsize, BenchFixedArray, BenchBoxed
- `z_run.rs` - `run!` and `run_async!` macros for timing
- `z_seq.rs`, `z_spsc.rs`, `z_mpsc.rs`, `z_mpmc.rs` - Test patterns

Each benchmark file implements a `new<T>(cap: Option<usize>)` function returning the channel's sender/receiver pair, then calls the shared test patterns.

Output format: `test_name,nanoseconds,messages_per_second`

## Dependencies

- Rust (latest), Go, Python with pygal/cairosvg/PIL
- `kanal2/` directory is cloned at runtime from https://github.com/fereidani/kanal for std-mutex variant testing
