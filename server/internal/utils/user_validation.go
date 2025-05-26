package utils

import (
	"fmt"
	"server/internal/entity"
)

func validateEmail(email string) bool {
	if len(email) < 5 || len(email) > 254 {
		return false
	}

	at := -1
	for i, c := range email {
		if c == '@' {
			if at != -1 {
				return false // More than one '@' found
			}
			at = i
		} else if c == '.' && at != -1 && i > at+1 {
			return true // Found a valid '.' after '@'
		}
	}

	return false // No valid '.' found after '@'
}

func validatePassword(password string) bool {
	if len(password) < 8 || len(password) > 128 {
		return false
	}

	hasUpper := false
	hasLower := false
	hasDigit := false
	hasSpecial := false

	for _, c := range password {
		switch {
		case c >= 'A' && c <= 'Z':
			hasUpper = true
		case c >= 'a' && c <= 'z':
			hasLower = true
		case c >= '0' && c <= '9':
			hasDigit = true
		case (c >= '!' && c <= '/') || (c >= ':' && c <= '@') || (c >= '[' && c <= '`') || (c >= '{' && c <= '~'):
			hasSpecial = true
		}
	}

	return hasUpper && hasLower && hasDigit && hasSpecial
}

func validateName(name string) bool {
	if len(name) < 1 || len(name) > 100 {
		return false
	}

	for _, c := range name {
		if !(c >= 'A' && c <= 'Z') && !(c >= 'a' && c <= 'z') && !(c == ' ') {
			return false // Only allow letters and spaces
		}
	}

	return true
}

func ValidateUser(user *entity.User) error {
	if !validateName(user.Name) {
		return fmt.Errorf("name must be between 1 and 100 characters and can only contain letters and spaces")
	}
	if !validateEmail(user.Email) {
		return fmt.Errorf("invalid email format")
	}
	if !validatePassword(user.Password) {
		return fmt.Errorf("password must be between 8 and 128 characters, with at least one uppercase letter, one lowercase letter, one digit, and one special character")
	}
	return nil
}

func ValidateUserLogin(email, password string) error {
	if !validateEmail(email) {
		return fmt.Errorf("invalid email format")
	}
	if !validatePassword(password) {
		return fmt.Errorf("password must be between 8 and 128 characters, with at least one uppercase letter, one lowercase letter, one digit, and one special character")
	}
	return nil
}
