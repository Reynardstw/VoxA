package repository

import (
	"context"
	"database/sql"
	"server/internal/entity"
)

type UserRepository interface {
	Create(ctx context.Context, tx *sql.Tx, user *entity.User) (*entity.User, error)
	Find(ctx context.Context, db *sql.DB, email string) (*entity.User, error)
}

type UserRepositoryImpl struct {
}

func NewUserRepository() UserRepository {
	return &UserRepositoryImpl{}
}

func (r *UserRepositoryImpl) Create(ctx context.Context, tx *sql.Tx, user *entity.User) (*entity.User, error) {
	query := `INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING userid, name, email, createdat, updatedat`
	row := tx.QueryRowContext(ctx, query, user.Name, user.Email, user.Password)

	var createdUser entity.User
	err := row.Scan(&createdUser.UserID, &createdUser.Name, &createdUser.Email, &createdUser.CreatedAt, &createdUser.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return &createdUser, nil
}

func (r *UserRepositoryImpl) Find(ctx context.Context, db *sql.DB, email string) (*entity.User, error) {
	query := `SELECT userid, name, email, password, profileurl, createdat, updatedat FROM users WHERE email = $1`
	row := db.QueryRowContext(ctx, query, email)
	var user entity.User
	err := row.Scan(&user.UserID, &user.Name, &user.Email, &user.Password, &user.ProfileUrl, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil // User not found
		}
		return nil, err // Other error
	}
	return &user, nil
}