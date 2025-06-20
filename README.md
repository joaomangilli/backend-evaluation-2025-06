# Backend Evaluation Monorepo

This repository is structured as a monorepo. Each project lives in its own subdirectory.

## Projects

- **park42** – Ruby on Rails application that was previously the root of this repository.
- **mock-payment-api** – Sinatra application providing a stub payment service.

## Docker Compose

Use the `docker-compose.yml` at the repository root to start PostgreSQL, Redis and the mock payment API:

```bash
docker-compose up --build
```

PostgreSQL is exposed on port `5432`, Redis on `6379`, and the payment API on `4000`.

## Docker Compose

Use the `docker-compose.yml` at the repository root to start the supporting
services and the mock payment API:

```bash
docker-compose up --build
```

PostgreSQL is exposed on port `5432`, Redis on `6379`, and the payment API on
`4000`.

To work on the Rails project, `cd` into `park42` and follow its README instructions.
Common `bin` commands can also be run from the repository root via wrapper scripts:

```bash
bin/dev      # starts the Rails server
bin/rails    # runs the rails executable
bin/bundle   # runs bundler
bin/rubocop  # runs the linter
```
