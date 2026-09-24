#!/usr/bin/env bash
# Run the test suites.
#
# Usage:
#   ./test.sh [--output_path <junit.xml>] <base|new>
#
#   base  the existing tests for the measurement, data, combining and reporting
#         code.
#   new   the tests for recording when lines and branches are first executed.
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

# The C tracer is compiled in place, so rebuild it to pick up source changes.
if ! python setup.py -q build_ext --inplace >/tmp/build_ext.log 2>&1; then
    echo "Warning: couldn't build the C extension:" >&2
    cat /tmp/build_ext.log >&2
fi

# Like igor.py, run the tests with an explicit core: the C tracer if it's
# available, otherwise the Python tracer.
if [[ -z "${COVERAGE_CORE:-}" ]]; then
    if python -c "import coverage.tracer" >/dev/null 2>&1; then
        export COVERAGE_CORE=ctrace
    else
        export COVERAGE_CORE=pytrace
    fi
fi

case "$MODE" in
    base)
        TESTS=(
            tests/test_api.py
            tests/test_arcs.py
            tests/test_cmdline.py
            tests/test_collector.py
            tests/test_concurrency.py
            tests/test_config.py
            tests/test_context.py
            tests/test_core.py
            tests/test_coverage.py
            tests/test_data.py
            tests/test_debug.py
            tests/test_html.py
            tests/test_json.py
            tests/test_lcov.py
            tests/test_misc.py
            tests/test_numbits.py
            tests/test_oddball.py
            tests/test_plugins.py
            tests/test_process.py
            tests/test_report.py
            tests/test_results.py
            tests/test_sqlitedb.py
            tests/test_sysmon.py
            tests/test_xml.py
        )
        DESELECT=(
            # Checks unreadable files, which root can read anyway.
            --deselect "tests/test_api.py::ApiTest::test_combining_bad_data[noperms-unable to open database file|Could not open database]"
            # Depends on the environment passed through exec/spawn calls, and
            # fails the same way without any changes to coverage.py.
            --deselect tests/test_process.py::ExecvTest::test_execv_patch
        )
        ;;
    new)
        TESTS=(
            tests/test_timestamps.py
        )
        DESELECT=()
        ;;
esac

python -m pytest \
    -p no:cacheprovider \
    -o addopts="" \
    -q -rfEX -n auto --dist loadgroup -p no:legacypath --no-flaky-report \
    --junitxml="$OUTPUT_PATH" \
    "${DESELECT[@]}" \
    "${TESTS[@]}"
