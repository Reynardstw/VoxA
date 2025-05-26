package middleware

import (
	"context"
	"fmt"
	"log"
	"os"
	"server/internal/model/response"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/joho/godotenv"
)

type Claims struct {
	User *response.UserResponse `json:"user"`
	jwt.RegisteredClaims
}

func Authenticate() gin.HandlerFunc {
	return func(c *gin.Context) {
		token := c.GetHeader("authorization")
		if token == "" {
			c.JSON(401, gin.H{
				"code":    401,
				"message": "Unauthorized",
			})
			c.Abort()
			return
		}

		err := ValidateToken(c, token)
		if err != nil {
			c.JSON(401, gin.H{
				"code":    401,
				"message": "Unauthorized",
			})
			c.Abort()
			return
		}

		// lanjutkan ke handler berikutnya
		c.Next()
	}
}

func ValidateToken(c *gin.Context, token string) error {
	// Split token
	if !strings.Contains(token, "Bearer") {
		return nil
	}

	// Extract token string
	tokenString := strings.Split(token, " ")[1]
	if tokenString == "" {
		c.JSON(401, gin.H{
			"code":    401,
			"message": "Unauthorized",
		})
		c.Abort()
		return nil
	}

	// Load .env file
	err := godotenv.Load("../.env")
	if err != nil {
		err = godotenv.Load()
		if err != nil {
			log.Println("env not found, skipping...")
		}
	}
	
	// Parse token
	claims := &Claims{}
	jwtToken, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		jwtSecret := []byte(os.Getenv("jwt_secret_key"))
		return jwtSecret, nil
	})

	if err != nil || !jwtToken.Valid {
		c.JSON(401, gin.H{
			"code":    401,
			"message": "Unauthorized",
		})
		c.Abort()
		return nil
	}

	// Set user data to context
	ctx := context.WithValue(c.Request.Context(), "email", claims.User.Email)
	c.Request = c.Request.WithContext(ctx)
	c.Set("token", token)

	return nil
}