#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${YELLOW}[*] $1${NC}"
}

print_success() {
    echo -e "${GREEN}[+] $1${NC}"
}

print_error() {
    echo -e "${RED}[-] $1${NC}"
}

# Check if Cursor AppImage exists
CURSOR_APPIMAGE="/home/kernellabs/Dev/Aplicativos/Cursor-1.0.0-x86_64.AppImage"
if [ ! -f "$CURSOR_APPIMAGE" ]; then
    print_error "Cursor AppImage not found at $CURSOR_APPIMAGE"
    exit 1
fi

# Make AppImage executable if it isn't
if [ ! -x "$CURSOR_APPIMAGE" ]; then
    print_status "Making Cursor AppImage executable..."
    chmod +x "$CURSOR_APPIMAGE"
fi

# Create test directory
TEST_DIR="$HOME/.config/nvim/test_results"
mkdir -p "$TEST_DIR"

# Function to run test
run_test() {
    local test_name=$1
    local test_command=$2
    
    print_status "Running test: $test_name"
    
    # Run Cursor with test command
    "$CURSOR_APPIMAGE" --headless \
        -c "lua require('core.debug.stress_test').start()" \
        -c "lua require('core.debug.stress_test').run_scenario('$test_command')" \
        -c "lua require('core.debug.stress_test').stop()" \
        -c "quit" 2>&1 | tee "$TEST_DIR/${test_name}_$(date +%Y%m%d_%H%M%S).log"
    
    if [ $? -eq 0 ]; then
        print_success "Test completed: $test_name"
    else
        print_error "Test failed: $test_name"
    fi
}

# Main test sequence
print_status "Starting Cursor debug tests..."

# Test 1: Basic configuration
run_test "config_test" "config_debug"

# Test 2: Buffer operations
run_test "buffer_test" "buffer_ops"

# Test 3: LSP operations
run_test "lsp_test" "lsp_ops"

# Test 4: Plugin operations
run_test "plugin_test" "plugin_ops"

# Generate summary
print_status "Generating test summary..."
echo "=== Test Summary ===" > "$TEST_DIR/summary_$(date +%Y%m%d_%H%M%S).txt"
echo "Date: $(date)" >> "$TEST_DIR/summary_$(date +%Y%m%d_%H%M%S).txt"
echo "Cursor Version: $("$CURSOR_APPIMAGE" --version)" >> "$TEST_DIR/summary_$(date +%Y%m%d_%H%M%S).txt"
echo "" >> "$TEST_DIR/summary_$(date +%Y%m%d_%H%M%S).txt"

# Check test results
for log_file in "$TEST_DIR"/*.log; do
    if [ -f "$log_file" ]; then
        echo "Test: $(basename "$log_file")" >> "$TEST_DIR/summary_$(date +%Y%m%d_%H%M%S).txt"
        if grep -q "error" "$log_file"; then
            echo "Status: Failed" >> "$TEST_DIR/summary_$(date +%Y%m%d_%H%M%S).txt"
            print_error "Test failed: $(basename "$log_file")"
        else
            echo "Status: Passed" >> "$TEST_DIR/summary_$(date +%Y%m%d_%H%M%S).txt"
            print_success "Test passed: $(basename "$log_file")"
        fi
        echo "" >> "$TEST_DIR/summary_$(date +%Y%m%d_%H%M%S).txt"
    fi
done

print_status "Tests completed. Results saved in $TEST_DIR"
print_status "Summary file: $TEST_DIR/summary_$(date +%Y%m%d_%H%M%S).txt" 
