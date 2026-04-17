# Build static-ish Linux binary, run as non-root in minimal image.
FROM golang:1.23-bookworm AS build
WORKDIR /src
COPY server/go.mod server/go.sum ./
RUN go mod download
COPY server/ ./
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/termd ./cmd/termd

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN useradd -r -s /bin/sh termd
USER termd
WORKDIR /home/termd
COPY --from=build /out/termd /usr/local/bin/termd
EXPOSE 8080
ENV TERMD_ADDR=:8080
ENTRYPOINT ["/usr/local/bin/termd"]
