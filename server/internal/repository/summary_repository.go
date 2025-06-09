package repository

import (
	"context"
	"database/sql"
	"server/internal/entity"
)

type SummaryRepository interface {
	Create(ctx context.Context, tx *sql.Tx, summary *entity.Summary) (*entity.Summary, error)
	Find(ctx context.Context, db *sql.DB, summaryID int) (*entity.Summary, error)
	GetSummaries(ctx context.Context, db *sql.DB, userID int) ([]*entity.Summary, error)
}

type SummaryRepositoryImpl struct {
}

func NewSummaryRepository() SummaryRepository {
	return &SummaryRepositoryImpl{}
}

func (r *SummaryRepositoryImpl) Create(ctx context.Context, tx *sql.Tx, summary *entity.Summary) (*entity.Summary, error) {
	query := `INSERT INTO summary (userid, title, content) VALUES ($1, $2, $3) RETURNING summaryid, userid, title, content, createdat, updatedat`
	row := tx.QueryRowContext(ctx, query, summary.UserID, summary.Title, summary.Content)
	var createdSummary entity.Summary
	err := row.Scan(&createdSummary.SummaryID, &createdSummary.UserID, &createdSummary.Title, &createdSummary.Content, &createdSummary.CreatedAt, &createdSummary.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return &createdSummary, nil
}

func (r *SummaryRepositoryImpl) Find(ctx context.Context, db *sql.DB, summaryID int) (*entity.Summary, error) {
	query := `SELECT summaryid, userid, title, content, createdat, updatedat FROM summary WHERE summaryid = $1`
	row := db.QueryRowContext(ctx, query, summaryID)
	var summary entity.Summary
	err := row.Scan(&summary.SummaryID, &summary.UserID, &summary.Title, &summary.Content, &summary.CreatedAt, &summary.UpdatedAt)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil // Summary not found
		}
		return nil, err // Other error
	}
	return &summary, nil
}

func (r *SummaryRepositoryImpl) GetSummaries(ctx context.Context, db *sql.DB, userID int) ([]*entity.Summary, error) {
	query := `SELECT summaryid, userid, title, content, createdat, updatedat FROM summary WHERE userid = $1 ORDER BY createdat DESC`
	rows, err := db.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err // Error executing query
	}
	defer rows.Close()

	var summaries []*entity.Summary
	for rows.Next() {
		var summary entity.Summary
		err := rows.Scan(&summary.SummaryID, &summary.UserID, &summary.Title, &summary.Content, &summary.CreatedAt, &summary.UpdatedAt)
		if err != nil {
			return nil, err // Error scanning row
		}
		summaries = append(summaries, &summary)
	}
	if err := rows.Close(); err != nil {
		return nil, err // Error closing rows
	}
	return summaries, nil // Return the list of summaries
}