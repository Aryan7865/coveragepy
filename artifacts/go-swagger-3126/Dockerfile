FROM public.ecr.aws/d3j8x8q7/olympus-base-go:latest

WORKDIR /app

COPY . .

ENV GOBIN=/usr/local/bin
# go.mod may require a more recent toolchain than the one of the image: it is then downloaded (and cached) at build time.
ENV GOTOOLCHAIN=auto

# Dependencies of the repository, and a JUnit reporter for the test runs.
RUN go mod download && \
    go build ./... && \
    go install gotest.tools/gotestsum@v1.13.0

# The fixtures used by the tests are left out of the build context by .dockerignore:
# restore them from the module source at the same commit.
RUN cd /tmp && \
    SRC=$(go mod download -json github.com/go-swagger/go-swagger@435dc19b1c0a94ed6aa68e36e9918eb45b9f7049 | sed -n 's/^[[:space:]]*"Dir": "\(.*\)",$/\1/p') && \
    test -n "$SRC" && test -d "$SRC/fixtures" && \
    rm -rf /app/fixtures && cp -R "$SRC/fixtures" /app/fixtures && chmod -R u+w /app/fixtures

# Some tests build the code generated for a server, a client and a command line client,
# in a module requiring the same dependencies as this repository: fill the module cache
# with the dependencies of generated code, so these builds work without network.
RUN mkdir -p /tmp/generated && \
    sed '1s#.*#module example.com/generated#' go.mod > /tmp/generated/go.mod && \
    cp go.sum /tmp/generated/ && \
    go run ./cmd/swagger generate server -q -f fixtures/codegen/todolist.responses.yml -t /tmp/generated -A generated && \
    go run ./cmd/swagger generate cli -q -f fixtures/codegen/todolist.responses.yml -t /tmp/generated -A generated && \
    cd /tmp/generated && go mod tidy && go build ./... && \
    cd /app && rm -rf /tmp/generated

CMD ["/bin/bash"]
