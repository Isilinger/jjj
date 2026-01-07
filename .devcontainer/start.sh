#!/usr/bin/env bash
set -euo pipefail

XVFB_DISPLAY=":0"
SCREEN_RES="1280x800x24"
RFB_PORT=5900
WS_PORT=6080
NOVNC_DIR="/opt/noVNC"
LOG_DIR="/tmp"
START_LOG="${LOG_DIR}/start.log"
X11VNC_LOG="${LOG_DIR}/x11vnc.log"
WEBSOCK_LOG="${LOG_DIR}/websockify.log"
FIREFOX_LOG="${LOG_DIR}/firefox.log"
FLUXBOX_LOG="${LOG_DIR}/fluxbox.log"

log(){ echo "[$(date --iso-8601=seconds)] $*" | tee -a "${START_LOG}"; }

mkdir -p "${LOG_DIR}"

log "Starting container services..."

log "Starting Xvfb on display ${XVFB_DISPLAY} (screen ${SCREEN_RES})..."
Xvfb "${XVFB_DISPLAY}" -screen 0 "${SCREEN_RES}" >/dev/null 2>&1 &
sleep 1

log "Starting fluxbox window manager..."
export DISPLAY=${XVFB_DISPLAY}
fluxbox >"${FLUXBOX_LOG}" 2>&1 || log "fluxbox exit code: $?"

sleep 1

if [ -n "${VNC_PASSWORD:-}" ]; then
  log "Starting x11vnc with password..."
  x11vnc -display "${XVFB_DISPLAY}" -passwd "${VNC_PASSWORD}" -forever -shared -rfbport ${RFB_PORT} >"${X11VNC_LOG}" 2>&1 &
else
  log "Starting x11vnc without password (CONVENIENCE MODE)..."
  x11vnc -display "${XVFB_DISPLAY}" -nopw -forever -shared -rfbport ${RFB_PORT} >"${X11VNC_LOG}" 2>&1 &
fi

sleep 1

log "Starting Firefox..."
export MOZ_DISABLE_AUTO_SAFE_MODE=1
DISPLAY=${XVFB_DISPLAY} firefox --no-remote >"${FIREFOX_LOG}" 2>&1 || log "firefox exit code: $?"

sleep 2

log "Starting websockify to bridge ${WS_PORT} -> ${RFB_PORT} and serve noVNC from ${NOVNC_DIR}..."
# Bind to 0.0.0.0 so Codespaces proxy can reach it
python3 -m websockify 0.0.0.0:${WS_PORT} localhost:${RFB_PORT} --web "${NOVNC_DIR}" >"${WEBSOCK_LOG}" 2>&1 &

sleep 1

log "Status (ps):"
ps aux | egrep "Xvfb|x11vnc|fluxbox|firefox|websockify" || true

log "Listening ports:"
sudo ss -tulpen | egrep "${RFB_PORT}|${WS_PORT}" || true

log "Tail of websockify log (last 80 lines):"
tail -n 80 "${WEBSOCK_LOG}" || true

log "Tail of x11vnc log (last 80 lines):"
tail -n 80 "${X11VNC_LOG}" || true

log "All services started (if no errors). noVNC should be available on port ${WS_PORT}."
wait -n
