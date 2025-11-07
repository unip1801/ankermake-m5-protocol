#!/bin/bash
# Network diagnostic script for AnkerMake printer discovery

echo "=== AnkerMake Network Diagnostics ==="
echo ""

echo "1. Container Network Configuration:"
echo "   Network Interfaces:"
ip addr show | grep -E "^[0-9]+:|inet " | head -10

echo ""
echo "   Routing Table:"
ip route | head -5

echo ""
echo "2. Testing Broadcast Capability:"
# Test if we can create a broadcast socket
python3 -c "
import socket
try:
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    sock.bind(('', 0))
    print('   ✓ Broadcast socket creation: SUCCESS')
    sock.close()
except Exception as e:
    print(f'   ✗ Broadcast socket creation: FAILED - {e}')
"

echo ""
echo "3. Testing Printer Discovery:"
cd /app
timeout 5 python3 -c "
import cli.pppp
import sys
print('   Scanning for printers (5 second timeout)...')
try:
    printers = list(cli.pppp.pppp_find_printer_ip_addresses())
    if printers:
        print(f'   ✓ Found {len(printers)} printer(s):')
        for duid, ip in printers:
            print(f'     - DUID: {duid}, IP: {ip}')
    else:
        print('   ⚠ No printers found')
except Exception as e:
    print(f'   ✗ Printer discovery failed: {e}')
" 2>/dev/null

echo ""
echo "4. Network Connectivity Tests:"
echo "   Testing connectivity to common networks:"

# Test connectivity to common printer IP ranges
for subnet in "192.168.1" "192.168.0" "10.0.0" "172.16.0"; do
    if ping -c 1 -W 1 ${subnet}.1 >/dev/null 2>&1; then
        echo "   ✓ Can reach ${subnet}.x network"
        break
    fi
done

echo ""
echo "5. Docker Network Mode:"
if [ -f /.dockerenv ]; then
    if ip route | grep -q "172.17."; then
        echo "   ⚠ Using Docker bridge networking (may block printer discovery)"
        echo "   💡 Consider using --network=host for printer discovery"
    elif ip route | grep -q "default via.*docker"; then
        echo "   ⚠ Custom Docker network detected"
    else
        echo "   ✓ Using host networking or direct access"
    fi
else
    echo "   ✓ Not running in Docker container"
fi

echo ""
echo "=== Recommendations ==="
echo "If no printers were found:"
echo "1. Ensure the printer is powered on and connected to WiFi"
echo "2. Verify you're on the same network as the printer"
echo "3. Try rebuilding the devcontainer with host networking"
echo "4. Use 'docker run --network=host' if needed"
