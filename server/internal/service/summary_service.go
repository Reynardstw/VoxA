package service

import (
	"context"
	"database/sql"
	"fmt"
	"server/internal/entity"
	"server/internal/model/request"
	"server/internal/model/response"
	"server/internal/repository"
)

type SummaryService interface {
	Create(ctx context.Context, req request.SummaryRequest) (*response.SummaryResponse, error)
	Find(ctx context.Context, summaryID int) (*response.SummaryResponse, error)
}

type SummaryServiceImpl struct {
	DB                	*sql.DB
	UserRepository 		repository.UserRepository
	SummaryRepository 	repository.SummaryRepository
}

func NewSummaryService(db *sql.DB, userRepository repository.UserRepository, summaryRepository repository.SummaryRepository) SummaryService {
	return &SummaryServiceImpl{
		DB:                db,
		UserRepository:   userRepository,
		SummaryRepository: summaryRepository,
	}
}

func (s *SummaryServiceImpl) Create(ctx context.Context, req request.SummaryRequest) (*response.SummaryResponse, error) {
	tx, err := s.DB.Begin()
	if err != nil {
		return nil, err
	}

	defer func() {
		if err != nil {
			tx.Rollback()
		}
	}()

	// Get user by ID on context
	userIDInterface := ctx.Value("userID")
	userID, ok := userIDInterface.(int)
	if !ok {
		return nil, fmt.Errorf("invalid user ID in context")
	}

	summary := &entity.Summary{
		UserID:    userID,
		Title:     req.Title,
		Content:   req.Content,
	}

	createdSummary, err := s.SummaryRepository.Create(ctx, tx, summary)
	if err != nil {
		return nil, err
	}

	err = tx.Commit()
	if err != nil {
		return nil, err
	}

	result, err := s.Find(ctx, createdSummary.SummaryID)
	if err != nil {
		return nil, err
	}
	
	return result, nil
}

func (s *SummaryServiceImpl) Find(ctx context.Context, summaryID int) (*response.SummaryResponse, error) {
	summary, err := s.SummaryRepository.Find(ctx, s.DB, summaryID)
	if err != nil || summary == nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("summary with ID %d not found", summaryID)
		}
		return nil, fmt.Errorf("error retrieving summary: %v", err)
	}

	responseSummary := &response.SummaryResponse{
		SummaryID: summary.SummaryID,
		UserID:    summary.UserID,
		Title:     summary.Title,
		Content:   summary.Content,
		CreatedAt: summary.CreatedAt,
		UpdatedAt: summary.UpdatedAt,
	}

	return responseSummary, nil
}
