#!/usr/bin/env bash
# Run the test suites.
#
# Usage:
#   ./test.sh [--output_path <junit.xml>] <base|new>
#
#   base  the tests of the code generator, except the ones which require network
#         (to download a remote spec, or the dependencies of generated code).
#   new   the tests for responses shared by several operations.
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

case "$OUTPUT_PATH" in
    /*) ;;
    *) OUTPUT_PATH="$(pwd)/$OUTPUT_PATH" ;;
esac

cd "$(dirname "${BASH_SOURCE[0]}")"

NEW_TESTS='TestSharedNamedResponses'
NETWORK_TESTS='TestGenerateAndBuild|TestGenerateAndTest|TestGenClient'

case "$MODE" in
    base)
        ARGS=(-skip "^(${NEW_TESTS}|${NETWORK_TESTS})" ./generator/...)
        ;;
    new)
        ARGS=(-run "^${NEW_TESTS}" ./generator/)
        ;;
esac

gotestsum --junitfile "$OUTPUT_PATH" --format standard-verbose -- \
    -count=1 -timeout 45m "${ARGS[@]}"
