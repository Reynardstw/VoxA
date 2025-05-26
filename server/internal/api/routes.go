package api

import (
	"database/sql"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
)

type Handlers struct {
}

func SetupRoutes(db *sql.DB, redisClient *redis.Client) *gin.Engine {
	return initRoutes(initHandler(db, redisClient))
}

func initHandler(db *sql.DB, redisClient *redis.Client) Handlers {
	return Handlers{}
}

func initRoutes(h Handlers) *gin.Engine {
	router := gin.Default()
	api := router.Group("/api")
	return router
}