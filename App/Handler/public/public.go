package public

import (
    "net/http"
    "github.com/labstack/echo"
)

func FirstPrint() echo.HandlerFunc {
    return func(c echo.Context) error {
        return c.String(http.StatusOK, "goodmorning,world")
    }
}

