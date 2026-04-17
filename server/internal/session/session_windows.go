//go:build windows

package session

import (
	"fmt"
	"net/http"

	"github.com/gorilla/websocket"
)

// RunPTYSession is not supported on Windows; run termd in Linux (Docker/WSL).
func RunPTYSession(_ http.ResponseWriter, _ *http.Request, _ *websocket.Conn, _, _ string) error {
	return fmt.Errorf("termd PTY requires Unix (Linux/macOS); use Docker or WSL")
}
