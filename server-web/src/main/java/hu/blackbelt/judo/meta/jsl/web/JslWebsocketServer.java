package hu.blackbelt.judo.meta.jsl.web;

import com.google.common.base.Objects;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.ServerConnector;
import org.eclipse.jetty.server.handler.DefaultHandler;
import org.eclipse.jetty.server.handler.HandlerList;
import org.eclipse.jetty.servlet.DefaultServlet;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;
import org.eclipse.jetty.util.resource.Resource;
import org.eclipse.jetty.util.resource.ResourceCollection;
import org.eclipse.jetty.websocket.javax.server.config.JavaxWebSocketServletContainerInitializer;
import org.eclipse.xtext.ide.server.ServerModule;
import org.eclipse.xtext.xbase.lib.ArrayExtensions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.websocket.server.ServerEndpointConfig;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URL;
import java.util.Collections;
import java.util.List;

public class JslWebsocketServer {
    static Logger log = LoggerFactory.getLogger(JslWebsocketServer.class);

    public static final String HOST = "-host";

    public static final String PORT = "-port";

    public static final String TRACE = "-trace";

    public static final String CONTEXT_PATH = "-contextPath";

    public static final String WEBSOCKET_PATH = "-websocketPath";

    public static final String NO_VALIDATE = "-noValidate";

    public static final int DEFAULT_PORT = 5051;

    public static final String DEFAULT_HOST = "0.0.0.0";

    public static final String DEFAULT_CONTEXT_PATH = "/";

    public static final String DEFAULT_WEBSOCKET_PATH = "/jsl";

    public static void main(String[] args) {
        new JslWebsocketServer().launch(args);
    }

    public void launch(String[] args) {
        try {
            var server = new Server();
            var connector = new ServerConnector(server);

            var host = getHost(args);
            var port = getPort(args);
            var contextPath = getContextPath(args);
            var websocketPath = getWebsocketPath(args);

            connector.setHost(host);
            connector.setPort(port);
            server.addConnector(connector);

            var context = new ServletContextHandler(ServletContextHandler.SESSIONS);
            context.setContextPath(contextPath);

            HandlerList handlers = new HandlerList();

            Resource manifestResources = findManifestResources(JslWebsocketServer.class.getClassLoader());
            context.setBaseResource(manifestResources);

            // Add something to serve the static files
            // It's named "default" to conform to servlet spec
            ServletHolder staticHolder = new ServletHolder("default", DefaultServlet.class);
            context.addServlet(staticHolder, "/");
            handlers.addHandler(context);

            JavaxWebSocketServletContainerInitializer.configure(context, (servletContext, wsContainer) -> {
                // This lambda will be called at the appropriate place in the
                // ServletContext initialization phase where you can initialize
                // and configure your websocket container.

                // Configure defaults for container
                wsContainer.setDefaultMaxTextMessageBufferSize(65535);

                // Add WebSocket endpoint to jakarta.websocket layer
                // TODO: Pass parameters related to the xtext launch
                wsContainer.addEndpoint(ServerEndpointConfig.Builder.create(JslLanguageServerEndpoint.class, websocketPath)
                        .build());
            });

            handlers.addHandler(new DefaultHandler()); // always last handler
            server.setHandler(handlers);

            Runtime.getRuntime().addShutdownHook(new Thread(() -> {
                log.info("Stopping LSP WebSocket Server...");
                try {
                    server.stop();
                } catch (Exception e) {
                    throw new RuntimeException(e);
                }
            }, "LSP-websocket-server-shutdown-hook"));

            log.info("LSP WebSocket Server started at {}:{}", host, port);
            server.start();
            server.join();
        } catch (Exception e) {
            log.error("Server error", e);
            System.exit(1);
        }
    }

    protected com.google.inject.Module getServerModule() {
        return new ServerModule();
    }

    protected PrintWriter getTrace(String... args) {
        if (ArrayExtensions.contains(args, TRACE)) {
            return new PrintWriter(System.out);
        }
        return null;
    }

    protected boolean shouldValidate(String... args) {
        return !ArrayExtensions.contains(args, NO_VALIDATE);
    }

    protected String getHost(String... args) {
        String host = getValue(args, HOST);
        if (host != null) {
            return host;
        } else {
            return DEFAULT_HOST;
        }
    }

    protected String getContextPath(String... args) {
        String contextPath = getValue(args, CONTEXT_PATH);
        if (contextPath != null) {
            return contextPath;
        } else {
            return DEFAULT_CONTEXT_PATH;
        }
    }

    protected String getWebsocketPath(String... args) {
        String websocketPath = getValue(args, WEBSOCKET_PATH);
        if (websocketPath != null) {
            return websocketPath;
        } else {
            return DEFAULT_WEBSOCKET_PATH;
        }
    }

    protected int getPort(String... args) {
        String value = getValue(args, PORT);
        if (value != null) {
            try {
                return Integer.parseInt(value);
            } catch (NumberFormatException e) {
                return DEFAULT_PORT;
            }
        }
        return DEFAULT_PORT;
    }

    protected String getValue(String[] args, String argName) {
        for (int i = 0; (i < (args.length - 1)); i++) {
            if (Objects.equal(args[i], argName)) {
                return args[i + 1];
            }
        }
        return null;
    }

    private Resource findManifestResources(ClassLoader classLoader) throws IOException
    {
        List<URL> hits = Collections.list(classLoader.getResources("META-INF/resources"));
        int size = hits.size();
        Resource[] resources = new Resource[hits.size()];
        for (int i = 0; i < size; i++)
        {
            resources[i] = Resource.newResource(hits.get(i));
        }
        return new ResourceCollection(resources);
    }
}
