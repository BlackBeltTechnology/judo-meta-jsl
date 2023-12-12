package hu.blackbelt.judo.meta.jsl.web;

import com.google.inject.Guice;
import com.google.inject.Injector;
import org.eclipse.lsp4j.jsonrpc.Launcher;
import org.eclipse.lsp4j.services.LanguageClient;
import org.eclipse.lsp4j.services.LanguageClientAware;
import org.eclipse.lsp4j.services.LanguageServer;
import org.eclipse.lsp4j.websocket.WebSocketLauncherBuilder;
import org.eclipse.xtext.ide.server.ServerModule;

import javax.websocket.Endpoint;
import javax.websocket.EndpointConfig;
import javax.websocket.Session;
import java.util.Collection;
import java.util.Collections;

public class JslLanguageServerEndpoint extends Endpoint {

    final static Injector injector = Guice.createInjector(new ServerModule());

    public void onOpen(Session session, EndpointConfig config) {
        WebSocketLauncherBuilder<LanguageClient> builder = new WebSocketLauncherBuilder();
        builder.setSession(session);
        this.configure(builder);
        Launcher<LanguageClient> launcher = builder.create();
        this.connect(builder.getLocalServices(), launcher.getRemoteProxy());
    }

    protected void configure(Launcher.Builder<LanguageClient> builder) {
        builder
                .setLocalServices(Collections.singleton(injector.getInstance(LanguageServer.class)))
                .setRemoteInterface(LanguageClient.class);
    }

    protected void connect(Collection<Object> localServices, LanguageClient remoteProxy) {
        localServices.stream()
                .filter(c -> c instanceof LanguageClientAware)
                .map(c -> (LanguageClientAware) c)
                .forEach(c -> c.connect(remoteProxy));
    }

}
