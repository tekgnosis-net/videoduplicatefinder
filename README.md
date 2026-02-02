# Video Duplicate Finder
Video Duplicate Finder is a cross-platform software to find duplicated video (and image) files on hard disk based on similiarity. That means unlike other duplicate finders this one does also finds duplicates which have a different resolution, frame rate and even watermarked.

# Features
- Cross-platform
- Fast scanning speed
- Ultra fast rescan
- Optional calling ffmpeg functions natively for even more speed
- Finds duplicate videos / images based on similarity (new: optional scan against pHash at zero cost)
- Windows, Linux and MacOS GUI

# Binaries

[Latest Release](https://github.com/tekgnosis-net/videoduplicatefinder/releases/latest) (You need FFmpeg and FFprobe, see below! For the latest pre-built binaries, check the releases page.)


# Requirements

#### FFmpeg & FFprobe:

On first launch it automatically tries to download ffmpeg and ffprobe for you.
Native ffmpeg binding works only with a specific ffmpeg version. Never use master version. Currently it works with ffmpeg 8.x (might change)

#### Windows user:
Get latest package from https://ffmpeg.org/download.html I recommend the full (GPL) shared version. If you want to use native ffmpeg binding you **must** use the shared version.

Extract ffmpeg and ffprobe into the same directory of VDF.GUI.dll or into a sub folder called `bin`. Or make sure it can be found in `PATH` system environment variable

#### Linux user:
Installing ffmpeg:
```
sudo apt-get update
sudo apt-get install ffmpeg
```
Open terminal in VDF folder and execute `./VDF.GUI`
You may need to set execute permission first `sudo chmod 777 VDF.GUI`

#### MacOS user:
Install ffmpeg / ffprobe using homebrew

Open terminal in VDF folder and execute `./VDF.GUI` or if you have .NET installed `dotnet VDF.GUI.dll`

You may get a permission error. Open system settings of your Mac, go to `Privacy & Security` and then `Developer Tools`. Now add `Terminal` to the list.

If the process is immediately killed (something like `zsh: killed`), the binary likely needs to be signed. Run `codesign --force --sign - ./VDF.GUI` and try again.

# Docker Usage

Video Duplicate Finder is available as a Docker container with FFmpeg pre-installed for easy deployment across platforms.

## Quick Start with Docker Compose

1. **Clone the repository and set up environment:**
   ```bash
   git clone https://github.com/tekgnosis-net/videoduplicatefinder.git
   cd videoduplicatefinder
   cp .env.sample .env
   ```

2. **Edit the `.env` file** to customize your configuration (see Environment Variables table below)

3. **Create required directories:**
   ```bash
   mkdir -p data config videos backups
   ```

4. **Run with Docker Compose:**
   ```bash
   # Start the service
   docker-compose up -d
   
   # View logs
   docker-compose logs -f
   
   # Stop the service
   docker-compose down
   ```

## Docker Run Command

For manual Docker execution:

```bash
docker run -d \
  --name video-duplicate-finder \
  --restart unless-stopped \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/config:/app/config \
  -v $(pwd)/videos:/app/data/videos:ro \
  -p 8080:8080 \
  -e VDF_LANGUAGE=en \
  -e VDF_THRESHOLD=5 \
  -e VDF_PERCENT=96 \
  ghcr.io/tekgnosis-net/videoduplicatefinder:latest
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| **Application Configuration** | | |
| `VDF_LANGUAGE` | `en` | Interface language (en, de, es, fr, pt, zh-Hans) |
| `VDF_THRESHOLD` | `5` | Similarity threshold (0-100, lower = more strict) |
| `VDF_PERCENT` | `96` | Match percentage (0-100, higher = more strict) |
| `VDF_USE_NATIVE_FFMPEG` | `false` | Use native FFmpeg binding (faster but riskier) |
| `VDF_HARDWARE_ACCELERATION` | `none` | Hardware acceleration (none, vdpau, dxva2, vaapi, videotoolbox) |
| **Scan Configuration** | | |
| `VDF_INCLUDE_IMAGES` | `true` | Include image files in scan |
| `VDF_INCLUDE_SUBDIRS` | `true` | Include subdirectories in scan |
| `VDF_IGNORE_READONLY` | `true` | Ignore read-only folders |
| `VDF_SCAN_DIRS` | `/app/data/videos` | Primary scan directory (inside container) |
| **Storage Configuration** | | |
| `VDF_HOST_DATA_DIR` | `./data` | Host directory for application data |
| `VDF_HOST_CONFIG_DIR` | `./config` | Host directory for configuration files |
| `VDF_HOST_VIDEOS_DIR` | `./videos` | Host directory containing videos to scan |
| `VDF_DATABASE_PATH` | `/app/data/ScannedFiles.db` | Database file path (inside container) |
| **Network Configuration** | | |
| `VDF_WEB_PORT` | `8080` | Port for future web interface |
| **Resource Limits** | | |
| `VDF_CPU_LIMIT` | `2.0` | CPU limit (cores) |
| `VDF_MEMORY_LIMIT` | `2G` | Memory limit |
| `VDF_CPU_RESERVATION` | `0.5` | Minimum CPU guarantee |
| `VDF_MEMORY_RESERVATION` | `512M` | Minimum memory guarantee |
| **Logging** | | |
| `VDF_LOG_LEVEL` | `Information` | Log level (Debug, Information, Warning, Error, Critical) |
| **Backup** | | |
| `BACKUP_RETENTION_DAYS` | `30` | Days to keep backups |

## Directory Structure

```
videoduplicatefinder/
├── data/              # Application data and database
├── config/            # Configuration files
├── videos/            # Videos to scan (mount your video directories here)
├── backups/           # Database backups (when using backup profile)
├── docker-compose.yml # Docker Compose configuration
└── .env               # Environment variables (copy from .env.sample)
```

## Backup and Restore

### Create Backup
```bash
# Run backup service
docker-compose --profile backup run --rm vdf-backup

# Or manual backup
docker run --rm -v $(pwd)/data:/data:ro -v $(pwd)/backups:/backups alpine:latest \
  sh -c 'tar -czf /backups/vdf-backup-$(date +%Y%m%d_%H%M%S).tar.gz -C /data .'
```

### Restore Backup
```bash
# Stop service
docker-compose down

# Restore from backup
tar -xzf backups/vdf-backup-YYYYMMDD_HHMMSS.tar.gz -C data/

# Restart service
docker-compose up -d
```

## Building Docker Image Locally

```bash
# Build the image
docker build -t videoduplicatefinder .

# Run locally built image
docker run -d --name vdf-local \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/videos:/app/data/videos:ro \
  videoduplicatefinder
```

# Screenshots (outdated)
<img src="https://user-images.githubusercontent.com/46010672/129763067-8855a538-4a4f-4831-ac42-938eae9343bd.png" width="510">

# License
Video Duplicate Finder is licensed under AGPLv3

# Credits / Third Party
- [Avalonia](https://github.com/AvaloniaUI/Avalonia)
- [ActiPro Avalonia Controls (Free Edition)](https://github.com/Actipro/Avalonia-Controls)
- [FFmpeg.AutoGen](https://github.com/Ruslan-B/FFmpeg.AutoGen)
- [protobuf-net](https://github.com/protobuf-net/protobuf-net)
- [SixLabors.ImageSharp](https://github.com/SixLabors/ImageSharp)

# Building
- .NET 9.x
- Visual Studio 2026 is recommended

# Committing
- Create a pull request for each addition or fix - do NOT merge them into one PR
- Unless it refers to an existing issue, write into your pull request what it does
- For larger PRs I recommend you create an issue for discussion first
