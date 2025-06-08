package handler

import (
	"context"
	"net/http"
	"server/internal/model/request"
	"server/internal/service"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
)

type SummaryHandler interface {
	Create(c *gin.Context)
	Find(c *gin.Context)
}

type SummaryHandlerImpl struct {
	SummaryService service.SummaryService
	validate validator.Validate
}

func NewSummaryHandler(summaryService service.SummaryService, validate validator.Validate) SummaryHandler {
	return &SummaryHandlerImpl{
		SummaryService: summaryService,
		validate:       validate,
	}
}

func (h *SummaryHandlerImpl) Create(c *gin.Context) {
	var req request.SummaryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":	http.StatusBadRequest,
			"message": "Invalid request format",
			"error": "Invalid request format",
		})
		return
	}

	ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
	defer cancel()

	response, err := h.SummaryService.Create(ctx, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code": http.StatusInternalServerError,
			"message": "Failed to create summary",
			"error": err.Error(),
		})
		return
	} else {
		c.JSON(http.StatusOK, gin.H{
			"code": http.StatusOK,
			"message": "Summary created successfully",
			"data": response,
		})
		return
	}
}

func (h *SummaryHandlerImpl) Find(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"code": http.StatusBadRequest,
			"message": "Summary ID is required",
			"error": "Summary ID is required",
		})
		return
	}

	idInt, err := strconv.Atoi(id)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code": http.StatusBadRequest,
			"message": "Invalid summary ID format",
			"error": "Invalid summary ID format",
		})
		return
	}

	ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
	defer cancel()

	response, err := h.SummaryService.Find(ctx, idInt)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code": http.StatusInternalServerError,
			"message": "Failed to find summary",
			"error": err.Error(),
		})
		return
	} else {
		c.JSON(http.StatusOK, gin.H{
			"code": http.StatusOK,
			"message": "Summary found successfully",
			"data": response,
		})
		return
	}
}