package service

import (
	"context"
	"database/sql"
	"fmt"
	"server/internal/entity"
	"server/internal/model/request"
	"server/internal/model/response"
	"server/internal/repository"
	"server/internal/utils"
)

type UserService interface {
	Create(ctx context.Context, request request.UserRequest) (*response.UserResponse, error)
	Find(ctx context.Context, email string) (*response.UserResponse, error)
	Login(ctx context.Context, request request.AuthRequest) (*string, error)
}

type UserServiceImpl struct {
	DB *sql.DB
	UserRepository repository.UserRepository
}

func NewUserService(db *sql.DB, userRepository repository.UserRepository) UserService {
	return &UserServiceImpl {
		DB:             db,
		UserRepository: userRepository,
	}
}

func (s *UserServiceImpl) Create(ctx context.Context, request request.UserRequest) (*response.UserResponse, error) {
	tx, err := s.DB.Begin()
	if err != nil {
		return nil, err
	}

	defer func() {
		if err != nil {
			tx.Rollback()
		}
	}()

	user := entity.User{
		Name:     request.Name,
		Email:    request.Email,
		Password: request.Password,
	}

	if err := utils.ValidateUser(&user); err != nil {
		return nil, fmt.Errorf("validation failed: %w", err)
	}

	existingUser, err := s.UserRepository.Find(ctx, s.DB, user.Email)
	if err == nil && existingUser != nil {
		return nil, fmt.Errorf("user with email %s already exists", user.Email)
	}

	createdUser, err := s.UserRepository.Create(ctx, tx, &user)
	if err != nil {
		return nil, fmt.Errorf("failed to create user: %w", err)
	}

	err = tx.Commit()
	if err != nil {
		return nil, fmt.Errorf("failed to commit transaction: %w", err)
	}

	result, err := s.Find(ctx, createdUser.Email)
	if err != nil {
		return nil, fmt.Errorf("failed to find created user: %w", err)
	}

	return result, nil
}

func (s *UserServiceImpl) Find(ctx context.Context, email string) (*response.UserResponse, error) {
	user, err := s.UserRepository.Find(ctx, s.DB, email)
	if err != nil || user == nil{
		return nil, fmt.Errorf("failed to find user: %w", err)
	}

	searchedUser := &response.UserResponse{
		ID:       user.UserID,
		Name:     user.Name,
		Email:    user.Email,
		CreatedAt: user.CreatedAt,
		UpdatedAt: user.UpdatedAt,
	}

	return searchedUser, nil
}

func (s *UserServiceImpl) Login(ctx context.Context, request request.AuthRequest) (*string, error) {
	err := utils.ValidateUserLogin(request.Email, request.Password)
	if err != nil {
		return nil, fmt.Errorf("validation failed: %w", err)
	}

	user, err := s.UserRepository.Find(ctx, s.DB, request.Email)
	if err != nil || user == nil {
		return nil, fmt.Errorf("failed to find user: %w", err)
	}

	fmt.Print("User found: ", user.Email, "\n")
	fmt.Print("User password: ", user.Password, "\n")
	if user.Password != request.Password {
		return nil, fmt.Errorf("invalid credentials")
	}

	userResponse := &response.UserResponse{
		ID:        user.UserID,
		Name:      user.Name,
		Email:     user.Email,
		CreatedAt: user.CreatedAt,
		UpdatedAt: user.UpdatedAt,
	}

	token, err := GenerateToken(userResponse)
	if err != nil {
		return nil, fmt.Errorf("failed to generate token: %w", err)
	}

	return token, nil
}