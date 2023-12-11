# judo-jsl-web-editor

This is a monorepo.

## client

The web editor module, see it's own README.md for details

## jsl

It is a copy of the `jsl` folder from the https://github.com/BlackBeltTechnology/judo-jsl-vscode repo's build.

The `server` module uses it.

## server

WebSocket wrapper for the client. Uses the `jsl` module's language server.
