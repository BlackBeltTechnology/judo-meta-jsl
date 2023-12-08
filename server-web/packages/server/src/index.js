import 'dotenv/config';
import { resolve } from 'node:path';
import { URL } from 'node:url';
import { fileURLToPath } from 'node:url';
import { dirname } from 'node:path';
import { WebSocketServer } from 'ws';
import express from 'express';
import { WebSocketMessageReader, WebSocketMessageWriter } from 'vscode-ws-jsonrpc';
import { createConnection, createServerProcess, forward } from 'vscode-ws-jsonrpc/server';
import { Message, InitializeRequest } from 'vscode-languageserver';

const getLocalDirectory = (referenceUrl) => {
  const __filename = fileURLToPath(referenceUrl);
  return dirname(__filename);
};

export const launchLanguageServer = (serverName, socket, baseDir, relativeDir) => {
  const ls = resolve(baseDir, relativeDir);

  const reader = new WebSocketMessageReader(socket);
  const writer = new WebSocketMessageWriter(socket);

  const socketConnection = createConnection(reader, writer, () => socket.dispose());
  const serverConnection = createServerProcess(serverName, ls, []);

  if (serverConnection) {
    forward(socketConnection, serverConnection, (message) => {
      if (Message.isRequest(message)) {
        console.log(`${serverName} Server received:`);
        console.log(message);
        if (message.method === InitializeRequest.type.method) {
          const initializeParams = message.params;
          initializeParams.processId = process.pid;
        }
      }
      if (Message.isResponse(message)) {
        console.log(`${serverName} Server sent:`);
        console.log(message);
      }
      return message;
    });
  }
};

const upgradeWsServer = (config) => {
  config.server.on('upgrade', (request, socket, head) => {
    const baseURL = `http://${request.headers.host}/`;
    const pathName = request.url ? new URL(request.url, baseURL).pathname : undefined;
    if (pathName === config.pathName) {
      config.wss.handleUpgrade(request, socket, head, (webSocket) => {
        const socket = {
          send: (content) =>
            webSocket.send(content, (error) => {
              if (error) {
                throw error;
              }
            }),
          onMessage: (cb) =>
            webSocket.on('message', (data) => {
              console.log(data.toString());
              cb(data);
            }),
          onError: (cb) => webSocket.on('error', cb),
          onClose: (cb) => webSocket.on('close', cb),
          dispose: () => webSocket.close(),
        };
        // launch the server when the web socket is opened
        if (webSocket.readyState === webSocket.OPEN) {
          launchLanguageServer(config.serverName, socket, config.baseDir, config.relativeDir);
        } else {
          webSocket.on('open', () => {
            launchLanguageServer(config.serverName, socket, config.baseDir, config.relativeDir);
          });
        }
      });
    }
  });
};

const runJSLServer = (baseDir, relativeDir, port, serverName, pathName) => {
  process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception: ', err.toString());
    if (err.stack) {
      console.error(err.stack);
    }
  });

  // create the express application
  const app = express();
  // server the static content, i.e. index.html
  const dir = getLocalDirectory(import.meta.url);
  app.use(express.static(dir));
  // start the server
  const server = app.listen(process.env.PORT);
  // create the web socket
  const wss = new WebSocketServer({
    noServer: true,
    perMessageDeflate: false,
    clientTracking: true,
    verifyClient: (clientInfo, callback) => {
      const parsedURL = new URL(`${clientInfo.origin}${clientInfo.req?.url ?? ''}`);
      const authToken = parsedURL.searchParams.get('authorization');
      if (authToken === 'UserAuth') {
        // eslint-disable-next-line n/no-callback-literal
        callback(true);
      } else {
        // eslint-disable-next-line n/no-callback-literal
        callback(false);
      }
    },
  });
  upgradeWsServer({
    serverName: 'JSL',
    pathName: '/jsl',
    server,
    wss,
    baseDir,
    relativeDir,
  });
};

const baseDir = resolve(getLocalDirectory(import.meta.url));

runJSLServer(baseDir, process.env.RELATIVE_DIR, process.env.PORT, process.env.SERVER_NAME, process.env.PATH_NAME);
