package config

import "testing"

func TestFromEnv(t *testing.T) {
	t.Setenv("TERMD_ADDR", ":9999")
	t.Setenv("TERMD_TOKEN", "tok")
	t.Setenv("TERMD_SHELL", "/bin/bash")
	t.Setenv("TERMD_MAX_SESSIONS", "4")

	addr, token, shell, max := FromEnv()
	if addr != ":9999" || token != "tok" || shell != "/bin/bash" || max != 4 {
		t.Fatalf("FromEnv() = %q %q %q %d", addr, token, shell, max)
	}
}
