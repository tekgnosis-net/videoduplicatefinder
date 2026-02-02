# Use .NET 9 runtime as base
FROM mcr.microsoft.com/dotnet/runtime:9.0-jammy AS base

# Install FFmpeg and required dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libgdiplus \
    libfontconfig1 \
    libfreetype6 \
    libx11-6 \
    libxcb1 \
    libxext6 \
    libxrender1 \
    libc6-dev \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for FFmpeg
ENV FFMPEG_PATH=/usr/bin/ffmpeg
ENV FFPROBE_PATH=/usr/bin/ffprobe

# Create app directory
WORKDIR /app

# Create user for security
RUN groupadd -r vdfuser && useradd -r -g vdfuser vdfuser
RUN chown -R vdfuser:vdfuser /app

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0-jammy AS build
WORKDIR /src

# Copy project files
COPY ["VDF.GUI/VDF.GUI.csproj", "VDF.GUI/"]
COPY ["VDF.Core/VDF.Core.csproj", "VDF.Core/"]
COPY ["Directory.Build.props", "./"]

# Add nuget sources
RUN dotnet nuget add source https://www.myget.org/F/sixlabors/api/v3/index.json

# Restore dependencies
RUN dotnet restore "VDF.GUI/VDF.GUI.csproj"

# Copy source code
COPY . .

# Build and publish
WORKDIR "/src/VDF.GUI"
RUN dotnet publish "VDF.GUI.csproj" -c Release -o /app/publish --no-restore \
    --runtime linux-x64 --self-contained false

# Final stage
FROM base AS final
WORKDIR /app

# Copy published application
COPY --from=build /app/publish .

# Create directories for data persistence
RUN mkdir -p /app/data /app/config && \
    chown -R vdfuser:vdfuser /app/data /app/config

# Set up volumes for persistence
VOLUME ["/app/data", "/app/config"]

# Environment variables
ENV VDF_DATA_DIR=/app/data
ENV VDF_CONFIG_DIR=/app/config
ENV VDF_SCAN_DIRS=/app/data/videos
ENV VDF_DATABASE_PATH=/app/data/ScannedFiles.db
ENV VDF_LANGUAGE=en
ENV VDF_THRESHOLD=5
ENV VDF_PERCENT=96
ENV VDF_USE_NATIVE_FFMPEG=false
ENV VDF_HARDWARE_ACCELERATION=none
ENV VDF_INCLUDE_IMAGES=true
ENV VDF_INCLUDE_SUBDIRS=true
ENV VDF_IGNORE_READONLY=true
ENV VDF_LOG_LEVEL=Information

# Switch to non-root user
USER vdfuser

# Expose port if needed (for future web interface)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD test -f /app/VDF.GUI.dll || exit 1

# Entry point
ENTRYPOINT ["dotnet", "VDF.GUI.dll"]