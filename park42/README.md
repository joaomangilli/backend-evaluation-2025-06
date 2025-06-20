# Park42

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
* System dependencies
* Configuration
* Database creation
* Database initialization
* How to run the test suite
* Services (job queues, cache servers, search engines, etc.)
* Deployment instructions
* ...

## Development using Docker Compose

Ensure you have Docker and Docker Compose installed. From the repository root,
run the following to start PostgreSQL, Redis and the mock payment API:

```bash
docker-compose up --build
```

The Rails server will be available at http://localhost:3000 and the database at port 5432.

The `bin/dev` script binds the Rails server to `0.0.0.0` by default so that the `mock-payment-api` container can reach it. Pass `-b` if you need a different binding.
