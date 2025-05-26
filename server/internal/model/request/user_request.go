package request

type UserRequest struct {
	Name     string `json:"name" validate:"required,min=3,max=50"`
	Email    string `json:"email" validate:"required,email,max=100"`
	Password string `json:"password" validate:"required,min=8,max=255"`
}

type AuthRequest struct {
	Email    string `json:"email" validate:"required,email,max=100"`
	Password string `json:"password" validate:"required,min=8,max=255"`
}