//go:build !windows

package session

import (
	"io"
	"net/http"
	"os"
	"os/exec"
	"sync"

	"github.com/creack/pty"
	"github.com/gorilla/websocket"
	"golang.org/x/sync/errgroup"
)

// RunPTYSession bridges an already-upgraded WebSocket to a PTY running `shell`.
func RunPTYSession(_ http.ResponseWriter, _ *http.Request, conn *websocket.Conn, shell string, _ string) error {
	cmd := exec.Command(shell)
	cmd.Env = append(os.Environ(), "TERM=xterm-256color")

	ptty, err := pty.Start(cmd)
	if err != nil {
		return err
	}
	if err = pty.Setsize(ptty, &pty.Winsize{Rows: 24, Cols: 80}); err != nil {
		_ = ptty.Close()
		return err
	}

	var once sync.Once
	closeConn := func() {
		once.Do(func() {
			_ = conn.Close()
			_ = ptty.Close()
			_ = cmd.Process.Kill()
		})
	}

	var g errgroup.Group

	g.Go(func() error {
		defer closeConn()
		for {
			mt, data, rerr := conn.ReadMessage()
			if rerr != nil {
				return rerr
			}
			if mt == websocket.CloseMessage {
				return nil
			}
			if mt != websocket.BinaryMessage && mt != websocket.TextMessage {
				continue
			}
			if _, werr := ptty.Write(data); werr != nil {
				return werr
			}
		}
	})

	g.Go(func() error {
		defer closeConn()
		buf := make([]byte, 32*1024)
		for {
			n, rerr := ptty.Read(buf)
			if n > 0 {
				if werr := conn.WriteMessage(websocket.BinaryMessage, buf[:n]); werr != nil {
					return werr
				}
			}
			if rerr != nil {
				if rerr == io.EOF {
					return nil
				}
				return rerr
			}
		}
	})

	err = g.Wait()
	_ = cmd.Wait()
	return err
}
