package response

import "time"

type SummaryResponse struct {
	SummaryID int       `json:"summaryid"`
	UserID    int       `json:"userid"`
	Title     string    `json:"title"`
	Content   string    `json:"content"`
	CreatedAt time.Time `json:"createdat"`
	UpdatedAt time.Time `json:"updatedat"`
}
