# server-web Specification

## Purpose

Provides a self-hosted web application combining a WebSocket-based JSL language server with a Monaco editor frontend, packaged as a single executable JAR for browser-based JSL editing and sandboxing.

## Architecture

Key classes:

- `JslWebsocketServer` — Entry point with Jetty-based HTTP server. Serves static web content (Monaco editor) and exposes a WebSocket endpoint for LSP communication. Configurable via command-line arguments for host, port, context path, WebSocket path, trace logging, and validation.
- `JslLanguageServerEndpoint` — Extends `javax.websocket.Endpoint`. Handles WebSocket connections by creating an XText `LanguageServerImpl`, binding it to the WebSocket session via `WebSocketMessageHandler`, and establishing bidirectional LSP communication.

The `client/` directory contains the Monaco-based frontend (Node.js build).

## Requirements

### Requirement: WebSocket LSP server

The server SHALL expose a JSL language server over WebSocket protocol.

#### Scenario: Start web server
- **WHEN** `JslWebsocketServer.main(args)` is called with default arguments
- **THEN** a Jetty server starts on `0.0.0.0:5051`
- **AND** static content is served at context path `/`
- **AND** a WebSocket LSP endpoint is available at `/jsl`

#### Scenario: Custom configuration
- **GIVEN** command-line arguments `-host 127.0.0.1 -port 8080 -contextPath /editor -websocketPath /lsp`
- **WHEN** the server starts
- **THEN** it listens on `127.0.0.1:8080` with static content at `/editor` and WebSocket at `/lsp`

### Requirement: WebSocket LSP communication

`JslLanguageServerEndpoint` SHALL handle WebSocket connections and provide full LSP functionality.

#### Scenario: Client connects via WebSocket
- **GIVEN** the server is running
- **WHEN** a WebSocket client connects to the LSP endpoint
- **THEN** `onOpen` creates a `LanguageServerImpl` with JSL configuration
- **AND** bidirectional JSON-RPC LSP communication is established over the WebSocket

### Requirement: Trace logging

The server SHALL support trace logging for debugging LSP communication.

#### Scenario: Enable tracing
- **GIVEN** the `-trace` command-line flag is provided
- **WHEN** LSP messages are exchanged
- **THEN** message contents are logged for debugging purposes

### Requirement: Validation control

The server SHALL support disabling request validation.

#### Scenario: Disable validation
- **GIVEN** the `-noValidate` command-line flag is provided
- **WHEN** JSL content is edited in the Monaco editor
- **THEN** server-side validation is skipped

### Requirement: Static content serving

The server SHALL serve the Monaco editor frontend as static web content.

#### Scenario: Serve editor UI
- **GIVEN** the server is running
- **WHEN** a browser navigates to the context path
- **THEN** the Monaco-based JSL editor is served from bundled static resources
