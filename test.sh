#!/usr/bin/env bash
# Run the test suites: "base" is existing behavior, "new" is exclude_origin.
set -uo pipefail

OUTPUT_PATH="results.xml"
MODE=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --output_path)
            OUTPUT_PATH="$2"
            shift 2
            ;;
        --output_path=*)
            OUTPUT_PATH="${1#*=}"
            shift
            ;;
        base|new)
            MODE="$1"
            shift
            ;;
        *)
            echo "Unknown argument: $1" >&2
            echo "Usage: $0 --output_path <file.xml> base|new" >&2
            exit 2
            ;;
    esac
done

if [[ -z "$MODE" ]]; then
    echo "Usage: $0 --output_path <file.xml> base|new" >&2
    exit 2
fi

cd "$(dirname "${BASH_SOURCE[0]}")"

case "$MODE" in
    base)
        TESTS=(
            tests/test_config.py
            tests/test_collector.py
            tests/test_core.py
            tests/test_arcs.py
        )
        ;;
    new)
        TESTS=(
            tests/test_exclude_origin.py
        )
        ;;
esac

python -m pytest \
    -p no:cacheprovider \
    -o addopts="" \
    -q -n auto --dist loadgroup -p no:legacypath --no-flaky-report -rfEX \
    --junitxml="$OUTPUT_PATH" \
    "${TESTS[@]}"
