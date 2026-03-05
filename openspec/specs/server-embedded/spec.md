# server-embedded Specification

## Purpose

Provides a standalone Language Server Protocol (LSP) server for JSL, packaged as an executable fat JAR. Enables editor-agnostic IDE support for any LSP-compatible editor (VS Code, Neovim, Sublime Text, etc.).

## Architecture

The module uses Maven Shade to create a fat JAR containing all dependencies. Key classes:

- `CustomSocketServerLauncher` — Entry point (`main` method) that creates a TCP socket-based LSP server listening on `localhost:5007`. Uses XText's `LanguageServerImpl` with JSL-specific configuration.
- `CustomServerModule` — Guice module that binds `IMultiRootWorkspaceConfigFactory` for multi-root workspace support in the language server.

The server communicates using the standard LSP JSON-RPC protocol over TCP sockets.

## Requirements

### Requirement: Socket-based LSP server

The server SHALL listen on a TCP socket and serve Language Server Protocol requests for JSL.

#### Scenario: Start LSP server
- **WHEN** `CustomSocketServerLauncher.main(args)` is called
- **THEN** a TCP socket server starts on `localhost:5007`
- **AND** it accepts LSP client connections using JSON-RPC protocol

#### Scenario: Handle LSP client connection
- **GIVEN** the server is listening on its socket
- **WHEN** an LSP client connects
- **THEN** a `Launcher<LanguageClient>` is created binding the XText language server to the client
- **AND** bidirectional LSP communication begins

### Requirement: Multi-root workspace support

The server SHALL support multi-root workspace configurations via `CustomServerModule`.

#### Scenario: Configure workspace
- **GIVEN** the Guice module is loaded
- **WHEN** the language server initializes
- **THEN** `IMultiRootWorkspaceConfigFactory` is available for resolving workspace roots

### Requirement: Fat JAR packaging

The server SHALL be packaged as a self-contained executable JAR with all dependencies.

#### Scenario: Run standalone
- **GIVEN** the built fat JAR in `target/`
- **WHEN** `java -jar hu.blackbelt.judo.meta.jsl.server.embedded-<VERSION>.jar` is executed
- **THEN** the LSP server starts without requiring external classpath configuration
