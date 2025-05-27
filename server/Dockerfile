# ----------- BUILD STAGE -------------
FROM golang:1.24.2 AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Build binary statik, target folder cmd
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /app/main ./cmd

# ----------- RUN STAGE --------------
FROM alpine:latest

RUN apk add --no-cache ca-certificates

WORKDIR /app

COPY --from=builder /app/main .

COPY ./cmd/migrate/migrations ./cmd/migrate/migrations

EXPOSE 8080

CMD ["./main"]
