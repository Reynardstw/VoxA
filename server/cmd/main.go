package main

import (
	"os"
	"server/infrastructure/db"

	"github.com/redis/go-redis/v9"
)

func main() {
	database := db.NewDbConnection()
	defer database.Close()

	db.Migrate(database, "up")
	redisUrl := os.Getenv("REDIS_URL")
	opt, err := redis.ParseURL(redisUrl)
	if err != nil {
		panic("Failed to parse Redis URL: " + err.Error())
	}
	rdb := redis.NewClient(opt)

	defer rdb.Close()
}