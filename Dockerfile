# ============================================================================
# MeshCentral Production Dockerfile
# Multi-stage build for minimal attack surface + optimized image size
# ============================================================================

# Stage 1: Build dependencies
FROM node:20-alpine AS builder

WORKDIR /opt/meshcentral

# Install build dependencies for native modules
RUN apk add --no-cache python3 make g++ 

# Install MeshCentral and production dependencies
RUN npm install meshcentral && \
    # Clean up npm cache to reduce image size
    npm cache clean --force

# Stage 2: Production runtime
FROM node:20-alpine AS production

LABEL maintainer="Opersis Assist Team"
LABEL description="Opersis Assist - MeshCentral-based RMM Platform"
LABEL version="1.0.0"

# Install runtime dependencies only
RUN apk add --no-cache \
    curl \
    openssl \
    tini \
    && addgroup -g 1001 meshcentral \
    && adduser -u 1001 -G meshcentral -s /bin/sh -D meshcentral

WORKDIR /opt/meshcentral

# Copy node_modules from builder
COPY --from=builder /opt/meshcentral/node_modules ./node_modules

# Create data directories with correct permissions
RUN mkdir -p meshcentral-data meshcentral-files meshcentral-backups meshcentral-web \
    && chown -R meshcentral:meshcentral /opt/meshcentral

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose ports
# 443  - HTTPS (main web interface)
# 4433 - Intel AMT MPS (optional)
EXPOSE 443 4433

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f -k https://localhost:443/health || exit 1

# Volume mount points for persistent data
VOLUME ["/opt/meshcentral/meshcentral-data", "/opt/meshcentral/meshcentral-files", "/opt/meshcentral/meshcentral-backups"]

# Use tini as init system for proper signal handling
ENTRYPOINT ["tini", "--"]

# Run as non-root user
USER meshcentral

CMD ["docker-entrypoint.sh"]
