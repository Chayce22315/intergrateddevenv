package config

import (
	"os"
	"strconv"
)

// FromEnv loads server configuration. TERMD_TOKEN must be non-empty for WebSocket access.
func FromEnv() (addr, token, shell string, maxSessions int) {
	addr = getenv("TERMD_ADDR", ":8080")
	token = os.Getenv("TERMD_TOKEN")
	shell = getenv("TERMD_SHELL", "/bin/sh")
	maxSessions = 16
	if v := os.Getenv("TERMD_MAX_SESSIONS"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 {
			maxSessions = n
		}
	}
	return addr, token, shell, maxSessions
}

func getenv(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}
