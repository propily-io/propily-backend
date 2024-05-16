package main

import (
	"fmt"
	"github.com/propily-io/propily-backend/database"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type User struct {
	ID    uint `gorm:"primaryKey"`
	Name  string
	Email string
}

func handler(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	name, found := os.LookupEnv("DEFAULT_NAME")
	if !found {
		name = "world"
	}
	if tempName, ok := request.QueryStringParameters["name"]; ok {
		name = tempName
	}

	database.ConnectDb()
	//database.DB.Db.AutoMigrate(User{})
	database.DB.Db.Create(User{
		Name:  name,
		Email: "Zeimedee",
	})
	var users []User
	database.DB.Db.Find(&users)
	fmt.Println(users)

	return events.APIGatewayProxyResponse{
		Body:       fmt.Sprintf("Hello, %s!\n", name),
		StatusCode: 200,
	}, nil
}

func main() {
	lambda.Start(handler)
}
