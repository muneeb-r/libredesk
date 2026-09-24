# Build stage
FROM golang:1.24-alpine AS builder

RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    nodejs \
    npm \
    make \
    git

# Install pnpm 9.15.3
RUN npm install -g pnpm@9.15.3

WORKDIR /app

# Copy Go dependency files first for Docker caching
COPY go.mod go.sum ./
RUN go mod download

# Copy source
COPY . .

# Build LibreDesk exactly according to its Makefile
RUN make build

# Runtime stage
FROM alpine:3.18

RUN apk --no-cache add \
    ca-certificates \
    tzdata

WORKDIR /libredesk

COPY --from=builder /app/libredesk .

EXPOSE 9000

CMD ["./libredesk"]