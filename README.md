# HW1 - Bash Scripting, Git and GitHub

## Team

| Member | GitHub username | Role |
| --- | --- | --- |
| רז מצליח | `razmazlih` | Team leader |
| בן פישר | Pending | Team member |
| עומרי בוגוסלבסקי | Pending | Team member |

Repository: https://github.com/Afeka-DevTools/26b-10142-bash-sikumfeka

## Project Structure

```text
.
├── README.md
└── scripts/
    ├── backup_directory.sh
    ├── check_internet.sh
    ├── cleanup_project_temp.sh
    ├── port_scan.sh
    └── weather_city.sh
```

## How to Clone and Run

```bash
git clone https://github.com/Afeka-DevTools/26b-10142-bash-sikumfeka.git
cd 26b-10142-bash-sikumfeka
chmod +x scripts/*.sh
```

Run a script with:

```bash
./scripts/script_name.sh [arguments]
```

All scripts were written for Bash and tested on macOS. They use common command line tools that are normally installed on macOS. When a required tool is missing, the script prints a clear error message.

## Script Ownership

### רז מצליח

| Script | Assignment topic | How to run |
| --- | --- | --- |
| `scripts/backup_directory.sh` | Backup directory content to a `.tar.gz` file | `./scripts/backup_directory.sh ./scripts ./backups` |
| `scripts/check_internet.sh` | Check internet connectivity and print a log | `./scripts/check_internet.sh` or `./scripts/check_internet.sh google.com` |
| `scripts/weather_city.sh` | Fetch current weather for a city | `./scripts/weather_city.sh Tel Aviv` |
| `scripts/port_scan.sh` | Scan open ports on an IP address or hostname | `./scripts/port_scan.sh 127.0.0.1 1 100` |
| `scripts/cleanup_project_temp.sh` | Clean temporary project files such as `.pyc`, `.class`, `node_modules` | `./scripts/cleanup_project_temp.sh .` for dry-run, then `./scripts/cleanup_project_temp.sh . --apply` |

### בן פישר - Planned Scripts

| Planned script | Assignment topic |
| --- | --- |
| `scripts/add_prefix_to_txt.sh` | Add a prefix to all `.txt` files in a selected directory |
| `scripts/file_statistics.sh` | Count lines, words and characters in every file in a directory |
| `scripts/delete_old_files.sh` | Delete files older than X days from a selected directory |
| `scripts/disk_usage_by_directory.sh` | Show disk usage for each directory |
| `scripts/random_password.sh` | Generate a random 10-character password with uppercase, lowercase, digit and symbol |

### עומרי בוגוסלבסקי - Planned Scripts

| Planned script | Assignment topic |
| --- | --- |
| `scripts/countdown_timer.sh` | Countdown timer using `HH:MM:SS` input |
| `scripts/system_uptime.sh` | Show system uptime |
| `scripts/directory_summary.sh` | Count files, directories and links in a selected directory |
| `scripts/git_status_subdirs.sh` | Show git status for every subdirectory in a selected directory |
| `scripts/compare_files.sh` | Compare two files |

## Notes for Submission

- Every script starts with `#! /bin/bash`.
- Every script should be executable with `chmod +x scripts/script_name.sh`.
- Each team member should commit only the scripts they wrote.
- Ben and Omri should update this README after adding their scripts and GitHub usernames.
