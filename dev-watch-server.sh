#!/bin/bash
# Advanced file watcher for webserver development
# This script watches for Python file changes and automatically restarts the webserver

WATCH_DIR="/app"
WEBSERVER_PORT=8080
LOG_FILE="/tmp/webserver-dev.log"
PID_FILE="/tmp/webserver-dev.pid"

echo "Starting AnkerMake Development Server with File Watcher..."
echo "Watching: $WATCH_DIR"
echo "Port: $WEBSERVER_PORT"
echo "Log: $LOG_FILE"
echo ""

# Function to start the webserver
start_webserver() {
    echo "[$(date)] Starting webserver..."
    cd "$WATCH_DIR" && python ankerctl.py webserver run --host 0.0.0.0 --port $WEBSERVER_PORT > "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
    echo "[$(date)] Webserver started with PID $(cat $PID_FILE)"
}

# Function to stop the webserver
stop_webserver() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            echo "[$(date)] Stopping webserver (PID: $PID)..."
            kill "$PID"
            sleep 2
            # Force kill if still running
            if kill -0 "$PID" 2>/dev/null; then
                kill -9 "$PID"
            fi
        fi
        rm -f "$PID_FILE"
    fi
    # Also kill any remaining ankerctl webserver processes
    pkill -f "ankerctl.py webserver" 2>/dev/null || true
}

# Function to restart the webserver
restart_webserver() {
    echo "[$(date)] File change detected - restarting webserver..."
    stop_webserver
    sleep 1
    start_webserver
    echo "[$(date)] Webserver restarted. Access at http://localhost:$WEBSERVER_PORT"
    echo ""
}

# Cleanup function
cleanup() {
    echo ""
    echo "[$(date)] Shutting down file watcher..."
    stop_webserver
    exit 0
}

# Set up signal handling
trap cleanup SIGINT SIGTERM

# Initial start
start_webserver
echo "File watcher started. Press Ctrl+C to stop."
echo "Changes to .py files in $WATCH_DIR will automatically restart the server."
echo ""

# Watch for file changes
inotifywait -m -r -e modify,create,delete,move --format '%w%f %e' "$WATCH_DIR" | while read file event; do
    # Only react to Python files
    if [[ "$file" == *.py ]]; then
        echo "[$(date)] Detected change: $file ($event)"
        restart_webserver
        
        # Add a small delay to avoid multiple rapid restarts
        sleep 2
    fi
done
