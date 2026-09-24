# Python base image; override BASE_IMAGE with the platform's Python image if needed.
ARG BASE_IMAGE=python:3.11-slim
FROM ${BASE_IMAGE}

ENV PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends git gcc libc6-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Repository checked out at 50d865908dfeb21a0bf1e6f05db578c11662f8dd.
COPY . /app

RUN python -m pip install -r requirements/pytest.pip \
    && python -m pip install -e .

CMD ["/bin/bash"]
