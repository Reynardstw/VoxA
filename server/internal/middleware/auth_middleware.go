package middleware

import (
	"context"
	"fmt"
	"log"
	"net/http"
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
		// step 1: ambil header authorization dari request
		authHeader := c.GetHeader("authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{
				"code": http.StatusUnauthorized,
				"message": "Unauthorized - Authorization header missing",
			})
			c.Abort()
			return
		}

		// step 2: validate token (sekalian ambil claims untuk digunakan sebagai data user)
		parsedClaims, err := ValidateToken(authHeader)
		if err != nil {
			log.Printf("Token validation error: %v\n", err)
			c.JSON(http.StatusUnauthorized, gin.H{
				"code":    http.StatusUnauthorized,
				"message": fmt.Sprintf("Unauthorized - Invalid token"),
			})
			c.Abort()
			return
		}

		// step 3: Simpan claims ke gin context, agar bisa diakses di handler apa saja.
		ctx := c.Request.Context() // inisalisasi context-nya
		contextKeyUsername := "username"
		contextKeyUserID := "userID"
		if parsedClaims.User != nil {
			ctx = context.WithValue(ctx, contextKeyUsername, parsedClaims.User.Name) // simpan username ke context
			if parsedClaims.User.ID != 0 {
				ctx = context.WithValue(ctx, contextKeyUserID, parsedClaims.User.ID) // simpan userID ke context
			} else {
				// seandainya userID tidak ada di token, biasanya error ini terjadi kalau token dibuat sebelum userID ditambahkan ke claims
				log.Println("UserID is missing or zero in token claims for user:", parsedClaims.User.Name)
				c.JSON(http.StatusUnauthorized, gin.H{
					"code":   http.StatusUnauthorized,
					"message": "Unauthorized - User identifier missing in token",
				})
				c.Abort()
				return
			}
		} else {
			// seandainya claims tidak ada user-nya, biasanya error ini terjadi kalau token dibuat sebelum user ditambahkan ke claims
			log.Println("User claim is nil in token for authorization header:", authHeader)
			c.JSON(http.StatusUnauthorized, gin.H{
				"code":    http.StatusUnauthorized,
				"message": "Unauthorized - User data missing in token claims",
			})
			c.Abort()
			return
		}

		// step 4: set context ke request, agar bisa diakses di handler
		c.Request = c.Request.WithContext(ctx)

		// step 5: simpan token ke context untuk digunakan di handler
		c.Set("token", authHeader)

		// step 6: lanjutkan ke handler berikutnya
		c.Next()
	}
}

func ValidateToken(authHeader string) (*Claims, error) {
	// step 1: pastiin token diawali dengan "Bearer "
	if !strings.HasPrefix(authHeader, "Bearer ") {
		return nil, fmt.Errorf("authorization header format must be Bearer {token}")
	}

	// step 2: ambil token dari header
	tokenString := strings.TrimPrefix(authHeader, "Bearer ")
	if tokenString == "" {
		return nil, fmt.Errorf("token string is empty")
	}

	// step 3: load JWT secret key dari .env file
	err := godotenv.Load()
	if err != nil {
		err = godotenv.Load()
		if err != nil {
			log.Println("Warning: .env file not found, relying on environment variables")
		}
	}
	jwtSecretKey := os.Getenv("JWT_SECRET_KEY")
	if jwtSecretKey == "" {
		log.Println("FATAL: JWT_SECRET_KEY environment variable is not set")
		return nil, fmt.Errorf("server configuration error: JWT_SECRET_KEY is not set")
	}

	// step 4: parse token menjadi claims dengan mengubah ke bentuk []byte dimana []byte adalah tipe data yang dibutuhkan oleh jwt.ParseWithClaims
	jwtSecret := []byte(jwtSecretKey) 

	// step 5: buat claims untuk menyimpan data user
	claims := &Claims{}
	jwtToken, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		// step 6: pastikan token menggunakan algoritma HS256
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return jwtSecret, nil
	})

	// step 7: jika ada error saat parsing token (termasuk jika token expired), kembalikan error (ERROR HANDLING)
	if err != nil {
		log.Printf("Token parsing error: %v\n", err)
		if err == jwt.ErrTokenExpired {
			return nil, fmt.Errorf("token expired")
		}
		return nil, fmt.Errorf("invalid token: %v", err)
	}

	// step 8: jika token tidak valid, kembalikan error
	if !jwtToken.Valid {
		return nil, fmt.Errorf("token is invalid")
	}

	// step 9: jika semua langkah berhasil, kembalikan claims yang berisi data user (tambah validasi sedikit)
	if claims.User == nil {
		return nil, fmt.Errorf("user data missing in token claims")
	}
	if claims.User.Name == "" {
		return nil, fmt.Errorf("username missing in token claims")
	}

	return claims, nil
}