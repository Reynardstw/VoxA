package handler

import (
	"context"
	"net/http"
	"server/internal/model/request"
	"server/internal/service"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
)

type UserHandler interface {
	Create(c *gin.Context)
	Find(c *gin.Context)
	Login(c *gin.Context)
}

type UserHandlerImpl struct {
	UserService service.UserService
	validate validator.Validate
}

func NewUserHandler(userService service.UserService, validate validator.Validate) UserHandler {
	return &UserHandlerImpl{
		UserService: userService,
		validate:    validate,
	}
}

func (h *UserHandlerImpl) Create(c *gin.Context) {
	var request request.UserRequest
	err := c.ShouldBindJSON(&request)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    http.StatusBadRequest,
			"message": "Invalid request format",
		})
	}

	ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
	defer cancel()

	err = h.validate.Struct(request)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    http.StatusBadRequest,
			"message": "Validation failed",
			"errors":  err.Error(),
		})
		return
	}

	response, err := h.UserService.Create(ctx, request)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    http.StatusInternalServerError,
			"message": "Failed to create user",
			"errors":  err.Error(),
		})
		return
	} else {
		c.JSON(http.StatusOK, gin.H{
			"code":    http.StatusOK,
			"message": "User created successfully",
			"data":    response,
		})
		return
	}
}

func (h *UserHandlerImpl) Find(c *gin.Context) {
	email := c.Param("email")
	if email == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    http.StatusBadRequest,
			"message": "Email parameter is required",
		})
		return
	}

	ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
	defer cancel()

	response, err := h.UserService.Find(ctx, email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    http.StatusInternalServerError,
			"message": "Failed to find user",
			"errors":  err.Error(),
		})
		return
	} else {
		c.JSON(http.StatusOK, gin.H{
			"code":    http.StatusOK,
			"message": "User found successfully",
			"data":    response,
		})
		return
	}
}

func (h *UserHandlerImpl) Login(c *gin.Context) {
	var request request.AuthRequest
	err := c.ShouldBindJSON(&request)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    http.StatusBadRequest,
			"message": "Invalid request format",
		})
		return
	}

	err = h.validate.Struct(request)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    http.StatusBadRequest,
			"message": "Validation failed",
			"errors":  err.Error(),
		})
		return
	}

	ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
	defer cancel()

	token, err := h.UserService.Login(ctx, request)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    http.StatusInternalServerError,
			"message": "Login failed",
			"errors":  err.Error(),
		})
		return
	} else {
		c.JSON(http.StatusOK, gin.H{
			"code":    http.StatusOK,
			"message": "Login successful",
			"data":    token,
		})
		return
	}
}