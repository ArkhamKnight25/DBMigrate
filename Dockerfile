FROM golang:1.26.2 AS build
WORKDIR /src
COPY go.* ./
RUN go mod download
COPY . .
RUN go build -o /out/dbmigrate .

FROM alpine:3.23.4
RUN apk add --no-cache mysql-client postgresql-client tzdata
COPY --from=build /out/dbmigrate /usr/local/bin/dbmigrate
ENTRYPOINT ["/usr/local/bin/dbmigrate"]
