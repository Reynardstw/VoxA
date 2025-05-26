package service

import (
	"log"
	"os"
	"server/internal/model/response"
	"strconv"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/joho/godotenv"
)

type Claims struct {
	User *response.UserResponse `json:"user"`
	jwt.RegisteredClaims
}

func GenerateToken(user *response.UserResponse) (*string, error) {
	err := godotenv.Load()
	if err != nil {
		err = godotenv.Load("../.env")
		if err != nil {
			log.Fatalf("Error loading .env file: %v", err)
			return nil, err
		}
	}

	expTime, _ := strconv.Atoi(os.Getenv("JWT_EXPIRATION_TIME"))
	expirationTime := time.Now().Add(time.Duration(expTime) * time.Minute).Unix()
	claims := &Claims{
		User: user,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Unix(expirationTime, 0)),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(os.Getenv("jwt_secret_key")))
	if err != nil {
		return nil, err
	}

	// return token-nya
	return &tokenString, nil
}