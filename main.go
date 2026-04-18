package main

import (
	"io"
	"log"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/logger"
)

func main() {
	app := fiber.New()

	app.Use(logger.New())

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World!")
	})

	app.Get("/health", func(c *fiber.Ctx) error {
		return c.SendStatus(200)
	})

	app.Get("/bye", func(c *fiber.Ctx) error {
		return c.SendString("Bye, World!")
	}) // <--- Ensure this is exactly: })

	app.Get("/weather", func(c *fiber.Ctx) error {
		url := "https://wttr.in"

		res, err := http.Get(url)
		if err != nil {
			return c.Status(500).SendString(err.Error())
		}
		defer res.Body.Close()

		data, err := io.ReadAll(res.Body)
		if err != nil {
			return c.Status(500).SendString(err.Error())
		}

		c.Set("Content-Type", "text/html")
		return c.Send(data)
	})

	log.Fatal(app.Listen(":3000"))
}