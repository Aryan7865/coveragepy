FROM public.ecr.aws/d3j8x8q7/olympus-base-rust:latest

WORKDIR /app

COPY . .

# Test runner that writes JUnit XML reports.
RUN cargo install cargo-nextest --locked

# Download the dependencies and build the crate with its tests, so that
# everything is available offline.
RUN cargo fetch \
    && cargo build -p rhai --tests

ENV CARGO_NET_OFFLINE=true

CMD ["/bin/bash"]
