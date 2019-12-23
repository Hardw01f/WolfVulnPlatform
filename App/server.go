package main

import (
	"github.com/labstack/echo"

    "./Handler/public"
)

func main() {
	e := echo.New()
	e.GET("/", public.FirstPrint())
	e.Logger.Fatal(e.Start(":1323"))
}
