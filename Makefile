.PHONY: build run stop logs clean test-mcp run-sse run-stdio

# Build the Docker image
build:
	docker-compose build

# Run the MCP server (default: stdio mode)
run:
	docker-compose up -d

# Run with SSE transport
run-sse:
	MCP_TRANSPORT=sse docker-compose up -d

# Run with stdio transport (default)
run-stdio:
	MCP_TRANSPORT=stdio docker-compose up -d

# Stop the MCP server
stop:
	docker-compose down

# View logs
logs:
	docker-compose logs -f

# View supervisor logs specifically
supervisor-logs:
	docker exec mcp-server supervisorctl tail -f mcp-server-stdio

# View SSE server logs
sse-logs:
	docker exec mcp-server supervisorctl tail -f mcp-server-sse

# Test MCP server with a simple tool call (stdio)
test-mcp:
	@echo "Testing MCP server with echo tool..."
	@echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}' | docker exec -i mcp-server python main.py

# Test SSE endpoint
test-sse:
	@echo "Testing SSE endpoint..."
	curl -f http://localhost:8000/health
	@echo "\nTesting SSE server info..."
	curl -f http://localhost:8000/

# Connect to MCP server interactively (for testing stdio)
connect:
	docker exec -it mcp-server python main.py

# Switch to SSE mode
switch-to-sse:
	docker exec mcp-server supervisorctl stop mcp-server-stdio
	docker exec mcp-server supervisorctl start mcp-server-sse

# Switch to stdio mode
switch-to-stdio:
	docker exec mcp-server supervisorctl stop mcp-server-sse
	docker exec mcp-server supervisorctl start mcp-server-stdio

# Restart the MCP server process (without rebuilding container)
restart-mcp:
	docker exec mcp-server supervisorctl restart mcp-server-stdio

# Restart SSE server
restart-sse:
	docker exec mcp-server supervisorctl restart mcp-server-sse

# Get supervisor status
status:
	docker exec mcp-server supervisorctl status

# Clean up
clean:
	docker-compose down -v
	docker image prune -f

# Full rebuild and run
rebuild: clean build run

# Development mode (with live logs)
dev: build
	docker-compose up

# Development mode with SSE
dev-sse: build
	MCP_TRANSPORT=sse docker-compose up

# Install dependencies locally with uv (for development)
install-deps:
	uv venv .venv
	uv pip install -r requirements.txt

# Run MCP server locally with uv (stdio mode)
run-local:
	uv run python main.py

# Run MCP server locally with SSE
run-local-sse:
	MCP_TRANSPORT=sse uv run python main.py

# Test local server with curl (SSE mode)
test-local-sse:
	@echo "Testing local SSE server..."
	curl -f http://localhost:8000/health
	curl -f http://localhost:8000/