# HW1 - Bash Scripting, Git and GitHub

## Team

| Member | GitHub username | Role |
| --- | --- | --- |
| רז מצליח | `razmazlih` | Team leader |
| בן פישר | `Benjamin-1Fisher` | Team member |
| עומרי בוגוסלבסקי | `obiedaslayer` | Team member |

Repository: https://github.com/Afeka-DevTools/26b-10142-bash-sikumfeka

## Project Structure

```text
.
├── README.md
└── scripts/
    ├── add_prefix_to_txt.sh
    ├── backup_directory.sh
    ├── check_internet.sh
    ├── cleanup_project_temp.sh
    ├── compare_files.sh
    ├── countdown_timer.sh
    ├── delete_old_files.sh
    ├── directory_summary.sh
    ├── disk_usage_by_directory.sh
    ├── file_statistics.sh
    ├── git_status_subdirs.sh
    ├── port_scan.sh
    ├── random_password.sh
    ├── system_uptime.sh
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
| `scripts/weather_city.sh` | Fetch current weather for a city | `./scripts/weather_city.sh "Tel Aviv"` |
| `scripts/port_scan.sh` | Scan open ports on an IP address or hostname | `./scripts/port_scan.sh 127.0.0.1 1 100` |
| `scripts/cleanup_project_temp.sh` | Clean temporary project files such as `.pyc`, `.class`, `node_modules` | `./scripts/cleanup_project_temp.sh .` for dry-run, then `./scripts/cleanup_project_temp.sh . --apply` |

### בן פישר

GitHub username: `Benjamin-1Fisher`

| Script | Assignment topic | How to run |
| --- | --- | --- |
| `scripts/add_prefix_to_txt.sh` | Add a prefix to all `.txt` file names in a selected directory | `./scripts/add_prefix_to_txt.sh ./notes old_` |
| `scripts/file_statistics.sh` | Count lines, words and characters in every regular file in a directory | `./scripts/file_statistics.sh ./scripts` |
| `scripts/delete_old_files.sh` | Find or delete files older than X days from a selected directory | Dry-run: `./scripts/delete_old_files.sh ./logs 30`; delete: `./scripts/delete_old_files.sh ./logs 30 --apply` |
| `scripts/disk_usage_by_directory.sh` | Show disk usage for a directory and each direct subdirectory | `./scripts/disk_usage_by_directory.sh .` |
| `scripts/random_password.sh` | Generate a random password with uppercase, lowercase, digit and symbol | Default 10 characters: `./scripts/random_password.sh`; custom length: `./scripts/random_password.sh 16` |

### עומרי בוגוסלבסקי

GitHub username: `obiedaslayer`

| Script | Assignment topic | How to run |
| --- | --- | --- |
| `scripts/countdown_timer.sh` | Countdown timer using `HH:MM:SS` input | `./scripts/countdown_timer.sh 00:00:10` |
| `scripts/system_uptime.sh` | Show system uptime | `./scripts/system_uptime.sh` |
| `scripts/directory_summary.sh` | Count direct files, directories, symbolic links and other entries in a selected directory | `./scripts/directory_summary.sh ./scripts` |
| `scripts/git_status_subdirs.sh` | Show git status for git repositories in direct subdirectories | `./scripts/git_status_subdirs.sh .` |
| `scripts/compare_files.sh` | Compare two files and print a unified diff when they differ | `./scripts/compare_files.sh ./old.txt ./new.txt` |

## Notes for Submission

- Every script starts with `#! /bin/bash`.
- Every script should be executable with `chmod +x scripts/script_name.sh`.
- Each team member should commit only the scripts they wrote.
- Team members should keep this README updated with their GitHub usernames and script run instructions.
- Backup output directories should be outside the source directory.
- Port scans accept ports from `1` to `65535`.
- Cleanup scripts run in dry-run mode unless `--apply` is provided.
