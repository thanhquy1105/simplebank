# 1. RUN SIMPLE_BANK USING POSTGRES CONTAINER AND `make server`
# 1.1 run postgres
postgres:
	docker run --name postgres -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:13.12

# 1.2 create db
# 	make createdb

# 1.3 migrate simple_bank db
#	make migrateup

# 1.4 run server
# 	make server

# 2. RUN SIMPLE_BANK USING DOCKER NETWORK TO CONNECT 2 STAND-ALONE CONTAINERS 
# 2.1 create network
network:
	docker network create bank-network

# 2.2 run postgres container with network 
postgreswithnetwork:
	docker run --name postgres --network bank-network -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:13.12

# 2.3 create db
# 	make createdb

# 2.4 migrate simple_bank db
#	make migrateup

# 2.5 build app into docker image
build:
	docker build -t simplebank:latest .

# 2.6 run app with network 
appwithnetwork:
	docker run --name simplebank --network bank-network -p 8080:8080 -e GIN_MODE=release -e DB_SOURCE="postgresql://root:secret@postgres:5432/simple_bank?sslmode=disable" simplebank:latest

# (optional) connect postgres container with network if not yet
connectdb:
	docker network connect bank-network postgres

# 3. RUN SIMPLE_BANK USING DOCKER COMPOSE
# 3.1 docker compose up
composeup:
	docker compose up

# (optional) delete/clear docker compose
#	docker compose down
#	docker rmi <image>

# -------------------(general)------------------------

# create simple_bank database on postgres container
createdb:
	docker exec -it postgres createdb --username=root --owner=root simple_bank

# drop simple_bank database on postgres container
dropdb:
	docker exec -it postgres dropdb simple_bank

# migrate simple_bank database from app to postgres container
migrateup:
	soda migrate -p ./db/migrations -c ./db/database.yml

# migrate all down simple_bank database from app to postgres container
migratedown:
	soda migrate down -p ./db/migrations -c ./db/database.yml --step 2

# migrate 1 down simple_bank database from app to postgres container
migratedown1:
	soda migrate down -p ./db/migrations -c ./db/database.yml --step 1

# generate queries to golang code
sqlc:
	docker run --rm -v "${CURDIR}:/src" -w /src kjconroy/sqlc generate

# run test
test:
	go test -v -cover -short ./...
	# go test -v -cover -coverprofile cover.out -outputdir ./covers/ ./...
	# go tool cover -html ./covers/cover.out -o ./covers/cover.html

server:
	go run main.go

# generate gomock for testing
mock:
	mockgen -package mockdb -destination db/mock/store.go github.com/thanhquy1105/simplebank/db/sqlc Store

.PHONY: postgres createdb dropdb migrateup migratedown sqlc test