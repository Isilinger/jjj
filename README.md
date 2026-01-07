```markdown
# Codespace Browser (noVNC + Firefox)

This devcontainer runs Firefox inside an X virtual framebuffer (Xvfb) and exposes it over noVNC so you can open a real browser UI from your local browser.

How to use
1. Commit these files into the repo and open it in GitHub Codespaces.
2. Wait for the container to build/start (the container runs start.sh).
3. In Codespaces UI, open the Ports tab and find port `6080` — click "Open in Browser."

Troubleshooting
- If the page shows HTTP 502:
  - In the Codespace terminal run:
    - ps aux | egrep "Xvfb|x11vnc|fluxbox|firefox|websockify" || true
    - sudo ss -tulpen | egrep "5900|6080" || true
    - tail -n 200 /tmp/start.log
  - Ensure port 6080 is forwarded in the Ports UI and marked Public (or click "Open in Browser").
  - The start script binds websockify to 0.0.0.0; if you still see problems paste the outputs above and I’ll help debug.

Security
- By default x11vnc runs without a password for convenience in private Codespaces. To require a password, set an environment variable `VNC_PASSWORD` in the Codespace settings or modify the start script.

If you'd like, I can also give:
- a variant using Chromium instead of Firefox
- an option that requires a VNC password by default
- a simplified version that only runs x11vnc and noVNC without a window manager
```
