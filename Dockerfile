# Build stage
FROM golang:1.25-alpine AS builder

RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    nodejs \
    npm \
    make \
    git

RUN npm install -g pnpm@9.15.3

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN make build

# Runtime stage
FROM alpine:3.18

RUN apk --no-cache add \
    ca-certificates \
    tzdata

WORKDIR /libredesk

COPY --from=builder /app/libredesk .
COPY --from=builder /app/config.sample.toml ./config.toml

EXPOSE 9000

CMD ["./libredesk"]