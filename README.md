# Router Monitor

A Bash script that periodically pings a list of routers and displays their status in a color-coded table.

## Features

- **Status Indicators:**
  - **ONLINE** (green, with extra space for alignment): All 3 pings succeed.
  - **OFFLINE** (red): No pings succeed.
  - **PARTIAL** (yellow): Some, but not all, pings succeed.
  - **INVALID** (red): Ping command failed (e.g., name or service not known).
- **Customizable:** Specify a router list file and a refresh interval (defaults: `routers.txt` and `120` seconds).
- **Manual Refresh:** Type `r` (or `R`) followed by Enter to refresh immediately.
- **Run Counter:** Displays a refresh counter with the timestamp.
- **Graceful Exit:** Press Ctrl-C to exit safely.
- **Optional Router Management:** Use the provided helper script to add or remove routers without manually editing the file.

## Important Note

This is an internal helper tool developed for CDT (Department of Technology). It is generic and can be used anywhere. It is does not contain sensitive information, and it is designed primarily for internal use.

## Usage

1. **Clone the repository:**

   ```bash
   git clone https://github.com/yourusername/router-monitor.git
   cd router-monitor
   ```

2. **Prepare Your Router List:**

   - Edit `routers.txt` to list one router per line.
   - *Optional:* Use `./manage_routers.sh` to add or remove router names:
     - **Add a router:**
       ```bash
       ./manage_routers.sh add <router_name>
       ```
     - **Remove a router:**
       ```bash
       ./manage_routers.sh remove <router_name>
       ```

3. **Run the Monitor Script:**

   ```bash
   ./monitor.sh [router_file] [interval]
   ```

   - Example (using defaults):
     ```bash
     ./monitor.sh
     ```
   - Example (custom file and interval):
     ```bash
     ./monitor.sh myrouters.txt 180
     ```

4. **Manual Refresh:**

   - After each refresh, type `r` (or `R`) and press Enter to immediately refresh the status.

## Requirements

- Bash (tested on recent versions)
- ANSI color support (e.g., via PuTTY)
- NetMan access
