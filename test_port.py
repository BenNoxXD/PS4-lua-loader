#*
#* Copyright (c) 2025 BenNox_XD
#*
#* This file is part of PS4-lua-loader and is licensed under the MIT License.
#* See the LICENSE file in the root of the project for full license information.
#*

import sys
import socket
import time

def check_port(ip, port, timeout, expected_status):
    timeout = float(timeout)
    while True:
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.settimeout(timeout)  # Set timeout for connection attempt
                result = s.connect_ex((ip, int(port)))
                is_open = result == 0
                
                if (expected_status == "open" and is_open) or (expected_status == "close" and not is_open):
                    print(f"Port {port} on {ip} is {expected_status}.")
                    break
                else:
                    print(f"Waiting for port {port} on {ip} to be {expected_status}...")
                    time.sleep(timeout)  # Use timeout as sleep interval
        except Exception as e:
            print(f"Error: {e}")
            break

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python3 script.py <IP> <PORT> <TIMEOUT> <open/close>")
        sys.exit(1)
    
    ip = sys.argv[1]
    port = sys.argv[2]
    timeout = sys.argv[3]
    expected_status = sys.argv[4]
    
    if expected_status not in ["open", "close"]:
        print("Error: The fourth argument must be 'open' or 'close'")
        sys.exit(1)
    
    check_port(ip, port, timeout, expected_status)