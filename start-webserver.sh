#!/bin/bash
# Start AnkerMake M5 Protocol Web Server

echo "Starting AnkerMake M5 Protocol Web Server..."

# Kill any existing instances
pkill -f "ankerctl.py webserver"

# Wait a moment
sleep 2

# Start development server with auto-reload (debug mode)
echo "Starting development webserver on port 8080 with auto-reload..."
cd /app && python ankerctl.py webserver run --host 0.0.0.0 --port 8080 > /tmp/webserver-8080.log 2>&1 &

# Start production server on default port
#echo "Starting webserver on default port 4470..."
#cd /app && python ankerctl.py webserver run --host 0.0.0.0 --port 4470 > /tmp/webserver-4470.log 2>&1 &

echo "Web servers started!"
echo "Access the interface at:"
echo "  - http://0.0.0.0:4470 (default port)"  
echo "  - http://0.0.0.0:8080 (development port)"
echo ""
echo "Log files:"
echo "  - /tmp/webserver-4470.log"
echo "  - /tmp/webserver-8080.log"
echo ""
echo "To stop servers: pkill -f 'ankerctl.py webserver'"
