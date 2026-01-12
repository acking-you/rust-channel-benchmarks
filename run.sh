#!/bin/bash
export RUSTFLAGS="-C target-cpu=native"
set -euxo pipefail
IFS=$'\n\t'
SLEEP_SEC=5
cd "$(dirname "$0")"

rm -rf kanal2
git clone https://github.com/fereidani/kanal/ kanal2

if [[ "${1:-}" == "--update" ]]; then
    cargo clean
    cargo update
fi

mkdir -p target

cargo build --release \
    --bin mpsc --bin futures-channel --bin flume --bin flume-async \
    --bin crossbeam-channel --bin async-channel \
    --bin kanal --bin kanal-async --bin kanal-std-mutex --bin kanal-std-mutex-async
go build -o target/release/go_bench go.go


sleep $SLEEP_SEC
./target/release/mpsc | tee target/mpsc.csv
sleep $SLEEP_SEC
./target/release/futures-channel | tee target/futures-channel.csv
sleep $SLEEP_SEC
./target/release/flume | tee target/flume.csv
sleep $SLEEP_SEC
./target/release/flume-async | tee target/flume_async.csv
sleep $SLEEP_SEC
./target/release/crossbeam-channel | tee target/crossbeam-channel.csv
sleep $SLEEP_SEC
./target/release/async-channel | tee target/async-channel.csv
sleep $SLEEP_SEC
./target/release/kanal | tee target/kanal.csv
sleep $SLEEP_SEC
./target/release/kanal-async | tee target/kanal-async.csv
sleep $SLEEP_SEC
./target/release/kanal-std-mutex | tee target/kanal-std-mutex.csv
sleep $SLEEP_SEC
./target/release/kanal-std-mutex-async | tee target/kanal-std-mutex-async.csv
sleep $SLEEP_SEC
./target/release/go_bench | tee target/go.csv

uv run ./plot.py target/*.csv

echo "Test Environment:"
uname -srvp
rustc --version
go version