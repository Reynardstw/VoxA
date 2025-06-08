package response

import "time"

type UserResponse struct {
	ID        	int       `json:"id"`
	Name      	string    `json:"username"`
	Email     	string    `json:"email"`
	ProfileURL 	string    `json:"profileUrl"`
	CreatedAt 	time.Time `json:"createdAt"`
	UpdatedAt 	time.Time `json:"updatedAt"`
}

type AuthResponse struct {
	Token string `json:"token"`
}