package api

import (
	"database/sql"
	"server/internal/handler"
	"server/internal/middleware"
	"server/internal/repository"
	"server/internal/service"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"github.com/redis/go-redis/v9"
)

type Handlers struct {
	UserHandler handler.UserHandler
	SummaryHandler handler.SummaryHandler
}

func SetupRoutes(db *sql.DB, redisClient *redis.Client) *gin.Engine {
	return initRoutes(initHandler(db, redisClient))
}

func initHandler(db *sql.DB, redisClient *redis.Client) Handlers {
	validator := validator.New()
	userRepository := repository.NewUserRepository()
	userService := service.NewUserService(db, userRepository)
	userHandler := handler.NewUserHandler(userService, *validator)

	summaryRepository := repository.NewSummaryRepository()
	summaryService := service.NewSummaryService(db, userRepository, summaryRepository)
	summaryHandler := handler.NewSummaryHandler(summaryService, *validator)
	return Handlers{
		UserHandler: userHandler,
		SummaryHandler: summaryHandler,
	}
}

func initRoutes(h Handlers) *gin.Engine {
	router := gin.Default()
	router.Use(middleware.HandlePanic())

	api := router.Group("/api")
	user := api.Group("/user")
	{
		user.POST("/register", h.UserHandler.Create)
		user.POST("/login", h.UserHandler.Login)
	}

	summary := api.Group("/summary")
	{
		summary.Use(middleware.Authenticate())
		summary.POST("/", h.SummaryHandler.Create)
		summary.GET("/:id", h.SummaryHandler.Find)
	}
	return router
}