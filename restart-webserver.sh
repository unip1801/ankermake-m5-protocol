#!/bin/bash
# Restart webserver manually - useful for development

echo "Restarting AnkerMake webserver..."

# Kill existing instances
pkill -f "ankerctl.py webserver"
echo "Stopped existing webserver processes"

# Wait for processes to fully stop
sleep 2

# Start in development mode with auto-reload
echo "Starting development webserver with auto-reload..."
cd /app && python ankerctl.py webserver run --host 0.0.0.0 --port 8080 > /tmp/webserver-8080.log 2>&1 &

echo "Webserver restarted on port 8080"
echo "Access at: http://localhost:8080"
echo "Auto-reload is enabled - changes to Python files will trigger automatic restart"
