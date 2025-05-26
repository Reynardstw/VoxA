package entity

import "time"

type User struct {
	UserID    int       `gorm:"primaryKey;autoIncrement:true" json:"userID"`
	Name      string    `gorm:"type:varchar(50);not null" json:"name"`
	Email     string    `gorm:"type:varchar(100);unique;not null" json:"email"`
	Password  string    `gorm:"type:varchar(255);not null" json:"password"`
	ProfileUrl string    `gorm:"type:varchar(255);default:''" json:"profileUrl"`
	CreatedAt time.Time `gorm:"type:timestamp;default:CURRENT_TIMESTAMP" json:"createdAt"`
	UpdatedAt time.Time `gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" json:"updatedAt"`
}