package hu.blackbelt.judo.meta.jsl.runtime;

import java.io.InputStream;

import org.eclipse.emf.common.util.URI;

public class JslStreamSource {
	final InputStream stream;
	final URI resourceUri;
	public JslStreamSource(InputStream stream, URI resourceUri) {
		this.stream = stream;
		this.resourceUri = resourceUri;
	}
	
	public InputStream getStream() {
		return stream;
	}
	public URI getResourceUri() {
		return resourceUri;
	}
}