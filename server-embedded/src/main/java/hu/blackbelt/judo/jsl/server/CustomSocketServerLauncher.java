package hu.blackbelt.judo.jsl.server;

import com.google.inject.Guice;

import java.io.*;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.nio.channels.AsynchronousServerSocketChannel;
import java.nio.channels.AsynchronousSocketChannel;
import java.nio.channels.Channels;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.function.Function;

import com.google.inject.Injector;
import com.google.inject.util.Modules;
import org.eclipse.lsp4j.jsonrpc.Launcher;
import org.eclipse.lsp4j.jsonrpc.MessageConsumer;
import org.eclipse.lsp4j.services.LanguageClient;
import org.eclipse.xtext.ide.server.LanguageServerImpl;
import org.eclipse.xtext.ide.server.ServerModule;

public class CustomSocketServerLauncher {
	
	// Check: 
	// org.eclipse.xtext.ide.server.ServerLauncher
	// org.eclipse.xtext.ide.server.SocketServerLauncher
	
    public static void main(String[] args) throws InterruptedException, IOException {
        Injector injector = Guice.createInjector(Modules.override(new ServerModule()).with(new CustomServerModule()));
        LanguageServerImpl languageServer = injector.getInstance(LanguageServerImpl.class);
        Function<MessageConsumer, MessageConsumer> wrapper = consumer -> {
            MessageConsumer result = consumer;
            System.out.println(result);
            return result;
        };
        Launcher<LanguageClient> launcher = createSocketLauncher(languageServer, LanguageClient.class,
                new InetSocketAddress("localhost", 5007), Executors.newCachedThreadPool(), wrapper);
        languageServer.connect(launcher.getRemoteProxy());
        Future<?> future = launcher.startListening();
        while (!future.isDone()) {
            Thread.sleep(10_000l);
        }
    }

    static <T> Launcher<T> createSocketLauncher(Object localService, Class<T> remoteInterface,
                                                SocketAddress socketAddress, ExecutorService executorService,
                                                Function<MessageConsumer, MessageConsumer> wrapper) throws IOException {
        AsynchronousServerSocketChannel serverSocket = AsynchronousServerSocketChannel.open().bind(socketAddress);
        AsynchronousSocketChannel socketChannel;
        try {
            socketChannel = serverSocket.accept().get();
            //return Launcher.createLauncher(localService, LanguageClient.class, Channels.newInputStream(socketChannel), Channels.newOutputStream(socketChannel), true, new PrintWriter(new OutputStreamWriter(System.out, StandardCharsets.UTF_8)), true);
            Launcher.createLauncher(localService, LanguageClient.class, Channels.newInputStream(socketChannel), Channels.newOutputStream(socketChannel), true, new PrintWriter(new OutputStreamWriter(System.out, StandardCharsets.UTF_8),true));
            return Launcher.createIoLauncher(localService, remoteInterface, Channels.newInputStream(socketChannel),
                    Channels.newOutputStream(socketChannel), executorService, wrapper);
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
        }
        return null;
    }
}