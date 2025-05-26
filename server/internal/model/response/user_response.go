package response

import "time"

type UserResponse struct {
	Name      string    `json:"username"`
	Email     string    `json:"email"`
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}

type AuthResponse struct {
	Token string `json:"token"`
}