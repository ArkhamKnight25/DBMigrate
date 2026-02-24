# DBMigrate

DBMigrate is a small Go command-line tool for running SQL database migrations.
It keeps migration files in version order, applies `up` sections, rolls back
`down` sections, and records applied migrations in a `schema_migrations` table.

## Features

- Go CLI for creating, applying, rolling back, and listing migrations
- PostgreSQL and MySQL database drivers
- Timestamped SQL migration files with `-- migrate:up` and `-- migrate:down`
- `schema_migrations` metadata table with version, checksum, timestamp, and dirty-state fields
- Checksum validation to detect edited migrations after they have been applied
- Docker Compose setup for local PostgreSQL and MySQL testing
- GitHub Actions workflow for build and test validation

## Usage

Set `DATABASE_URL` and run the CLI:

```sh
export DATABASE_URL=postgres://postgres:postgres@localhost:5432/dbmigrate_test?sslmode=disable
go run . new create_users
go run . up
go run . status
go run . down
```

MySQL URLs are also supported:

```sh
export DATABASE_URL=mysql://root:root@localhost:3306/dbmigrate_test
go run . migrate
```

## Migration Format

```sql
-- migrate:up
create table users (
  id serial primary key,
  email text not null unique
);

-- migrate:down
drop table users;
```

## Local Databases

Start test databases with Docker:

```sh
docker compose up -d
```

Then point `DATABASE_URL` at either the PostgreSQL or MySQL service.
