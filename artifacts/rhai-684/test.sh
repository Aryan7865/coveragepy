#!/usr/bin/env bash
# Run the test suites and write a JUnit XML report.
#
# Usage:
#   ./test.sh [--output_path <junit.xml>] <base|new>
#
#   base  the existing tests of the rhai crate.
#   new   the tests for destructuring `let` and `const` statements.
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
            echo "Usage: $0 [--output_path <junit.xml>] <base|new>" >&2
            exit 2
            ;;
    esac
done

if [[ -z "$MODE" ]]; then
    echo "Usage: $0 [--output_path <junit.xml>] <base|new>" >&2
    exit 2
fi

cd "$(dirname "${BASH_SOURCE[0]}")"

case "$MODE" in
    base)
        FILTER="not binary(destructuring_b8f523)"
        ;;
    new)
        FILTER="binary(destructuring_b8f523)"
        ;;
esac

rm -f target/nextest/junit/junit.xml

cargo nextest run -p rhai --profile junit --no-fail-fast -E "$FILTER"
STATUS=$?

if [[ -f target/nextest/junit/junit.xml ]]; then
    mkdir -p "$(dirname "$OUTPUT_PATH")"
    cp target/nextest/junit/junit.xml "$OUTPUT_PATH"
fi

exit $STATUS
