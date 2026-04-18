# --- Stage 1: Build ---
# Use the same Go version as your workflow (1.24 is the latest stable in 2026)
FROM golang:1.24-bullseye AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy dependency files first to leverage Docker layer caching
COPY go.mod ./
# COPY go.sum ./  # Uncomment this if your project has a go.sum file
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the application
# CGO_ENABLED=0 is REQUIREMENT for distroless/static
# GOOS=linux ensures the binary is built for the container's OS
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/backend .

# --- Stage 2: Final Image ---
# Distroless is the professional standard for security (no shell, no extra tools)
FROM gcr.io/distroless/static-debian12

# Set security context
USER nonroot:nonroot

# Copy the binary from the builder stage
# We name it 'backend' to match your ENTRYPOINT
COPY --from=builder --chown=nonroot:nonroot /app/backend /backend

# Documentation for the port your app listens on
EXPOSE 3000

# Run the binary
ENTRYPOINT ["/backend"]
