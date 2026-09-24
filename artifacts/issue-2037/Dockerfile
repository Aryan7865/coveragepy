FROM public.ecr.aws/d3j8x8q7/olympus-base-python:latest

WORKDIR /app

COPY . .

# A C compiler is needed to build coverage.py's C tracer.
RUN if ! command -v cc >/dev/null 2>&1 && command -v apt-get >/dev/null 2>&1; then \
        apt-get update \
        && apt-get install -y --no-install-recommends build-essential \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# Test dependencies, setuptools for rebuilding the C tracer in place, the
# package itself in editable mode, and the zipped test modules the test suite
# expects.
RUN python -m pip install --no-cache-dir -r requirements/pytest.pip \
    && python -m pip install --no-cache-dir setuptools==82.0.1 \
    && python -m pip install --no-cache-dir -e . \
    && python setup.py -q build_ext --inplace \
    && python igor.py zip_mods

CMD ["/bin/bash"]
