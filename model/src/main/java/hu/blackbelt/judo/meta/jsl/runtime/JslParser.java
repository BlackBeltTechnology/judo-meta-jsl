package hu.blackbelt.judo.meta.jsl.runtime;

import com.google.inject.Injector;
import hu.blackbelt.judo.meta.jsl.JslDslStandaloneSetupGenerated;
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration;

import org.eclipse.emf.common.notify.Notifier;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.Resource.Diagnostic;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.xtext.diagnostics.Severity;
import org.eclipse.xtext.resource.IResourceFactory;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.xtext.util.CancelIndicator;
import org.eclipse.xtext.validation.CheckMode;
import org.eclipse.xtext.validation.IResourceValidator;
import org.eclipse.xtext.validation.Issue;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

public class JslParser {

    private static final Logger log = LoggerFactory.getLogger(JslParser.class);

    public static final String JSLSCRIPT_CONTENT_TYPE = "jsl";
    private static Injector injectorInstance;

    private static synchronized Injector injector() {
        if (injectorInstance == null) {
            final long startTs = System.currentTimeMillis();
            injectorInstance = new JslDslStandaloneSetupGenerated().createInjectorAndDoEMFRegistration();
            Resource.Factory.Registry.INSTANCE.getContentTypeToFactoryMap().put(JSLSCRIPT_CONTENT_TYPE,
                    injectorInstance.getInstance(IResourceFactory.class));
            log.trace("Initialized XText for JSL in {} ms", (System.currentTimeMillis() - startTs));
        }
        return injectorInstance;
    }
        
    public XtextResourceSet loadJslFromStream(Collection<JslStreamSource> streams) {
        final long startTs = System.currentTimeMillis();
        try {
            final XtextResourceSet xtextResourceSet =  injector().getInstance(XtextResourceSet.class);
            final List<Issue> errors = new ArrayList<>();

            for (JslStreamSource stream : streams) {
                final XtextResource jslResource = (XtextResource) xtextResourceSet
                        .createResource(stream.getResourceUri(), JSLSCRIPT_CONTENT_TYPE);
                jslResource.load(stream.getStream(), injector().getInstance(XtextResourceSet.class).getLoadOptions());

                final IResourceValidator validator = jslResource.getResourceServiceProvider().getResourceValidator();
                errors.addAll(validator.validate(jslResource, CheckMode.ALL, CancelIndicator.NullImpl)
                		.stream().filter(i -> i.getSeverity() == Severity.ERROR).collect(Collectors.toList()));

            }
            if (errors.size() > 0) {
            	throw new JslParseException(errors);
            }
            return xtextResourceSet;
        } catch (IOException ex) {
            throw new IllegalStateException("Unable to parse JslExpression", ex);
        } finally {
            log.trace("Loaded JSL in {} ms", (System.currentTimeMillis() - startTs));
        }
    }

    public XtextResourceSet loadJslFromString(Collection<String> jslExpressions) {
    	Collection<JslStreamSource> streams = jslExpressions.stream().map(s -> {
    		try {
    			return new JslStreamSource(new ByteArrayInputStream(s.getBytes("UTF-8")), URI.createURI("string:" + s.hashCode()));
    		} catch (UnsupportedEncodingException e) {
				throw new RuntimeException("Unsupported encoding: " + s);
    		}
    	}).collect(Collectors.toList());
    	return loadJslFromStream(streams);
    }

    public XtextResourceSet loadJslFromFile(final Collection<File> jslFiles) {
    	Collection<JslStreamSource> streams = jslFiles.stream().map(f -> {
			try {
				return new JslStreamSource(new FileInputStream(f), URI.createURI(f.getAbsolutePath()));
			} catch (FileNotFoundException e) {
				throw new RuntimeException("File not found: " + f.getAbsolutePath());
			}
		}).collect(Collectors.toList());
    	return loadJslFromStream(streams);
    }

    public Optional<ModelDeclaration> getModelFromStreamSources(String modelName, final Collection<JslStreamSource> jslStreams) {
    	return getModelFromXtextResourceSet(modelName, loadJslFromStream(jslStreams));
    }

    public Optional<ModelDeclaration> getModelFromFiles(String modelName, final Collection<File> jslFiles) {
    	return getModelFromXtextResourceSet(modelName, loadJslFromFile(jslFiles));
    }

    public Optional<ModelDeclaration> getModelFromStrings(String modelName, final Collection<String> jslStrings) {
    	return getModelFromXtextResourceSet(modelName, loadJslFromString(jslStrings));
    }

    public Optional<ModelDeclaration> getModelFromXtextResourceSet(String modelName, XtextResourceSet resourceSet) {
    	Iterator<Notifier> iter = resourceSet.getAllContents();
    	ModelDeclaration found = null;
    	while (found == null && iter.hasNext()) {
    		Notifier o = iter.next();
    		if (o instanceof ModelDeclaration) {
    			ModelDeclaration m = (ModelDeclaration) o;
    			if (m.getName().equals(modelName)) {
    				found = m;
    			}
    		}
    	}
    	return Optional.ofNullable(found);
    }

}
