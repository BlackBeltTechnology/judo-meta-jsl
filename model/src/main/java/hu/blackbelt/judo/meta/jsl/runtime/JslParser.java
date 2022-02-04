package hu.blackbelt.judo.meta.jsl.runtime;

import com.google.inject.Injector;
import hu.blackbelt.judo.meta.jsl.JslDslStandaloneSetupGenerated;
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.Resource.Diagnostic;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.xtext.resource.IResourceFactory;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.UUID;

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

    public XtextResource loadJslFromFile(final File jslFile) {
        final long startTs = System.currentTimeMillis();
        try {
            final XtextResourceSet xtextResourceSet =  injector().getInstance(XtextResourceSet.class);
            final XtextResource jslResource = (XtextResource) xtextResourceSet
                    .createResource(URI.createFileURI(jslFile.getAbsolutePath()), JSLSCRIPT_CONTENT_TYPE);
            jslResource.load(new FileInputStream(jslFile),
                    injector().getInstance(XtextResourceSet.class).getLoadOptions());

            return jslResource;
        } catch (IOException ex) {
            throw new IllegalStateException("Unable to parse JslExpression", ex);
        } finally {
            log.trace("Loaded JSL from file in {} ms", (System.currentTimeMillis() - startTs));
        }
    }

    public XtextResource loadJslFromStream(final InputStream stream, final URI resourceUri) {
        final long startTs = System.currentTimeMillis();
        try {
            final XtextResourceSet xtextResourceSet =  injector().getInstance(XtextResourceSet.class);
            final XtextResource jslResource = (XtextResource) xtextResourceSet
                    .createResource(resourceUri, JSLSCRIPT_CONTENT_TYPE);
            jslResource.load(stream, injector().getInstance(XtextResourceSet.class).getLoadOptions());

            return jslResource;
        } catch (IOException ex) {
            throw new IllegalStateException("Unable to parse JslExpression", ex);
        } finally {
            log.trace("Loaded JSL stream in {} ms", (System.currentTimeMillis() - startTs));
        }
    }

    public XtextResource loadJslFromString(final String jslExpression, final URI resourceUri) {
        final long startTs = System.currentTimeMillis();
        if (jslExpression == null) {
            return null;
        }

        if (log.isDebugEnabled()) {
            log.trace("Parsing JslExpression: {}", jslExpression);
        }

        try {
            final XtextResourceSet xtextResourceSet =  injector().getInstance(XtextResourceSet.class);
            final XtextResource jslResource = (XtextResource) xtextResourceSet
                    .createResource(resourceUri, JSLSCRIPT_CONTENT_TYPE);
            final InputStream in = new ByteArrayInputStream(jslExpression.getBytes("UTF-8"));
            Map<Object, Object> defaultLoadOptions = injector().getInstance(XtextResourceSet.class).getLoadOptions();
            HashMap<Object, Object> loadOptions = new HashMap<>(defaultLoadOptions);
            loadOptions.put(XtextResource.OPTION_ENCODING,  "UTF-8");
            jslResource.load(in, loadOptions);

            return jslResource;
        } catch (IOException ex) {
            throw new IllegalStateException("Unable to parse JslExpression", ex);
        } finally {
            log.trace("Loaded JSL string in {} ms", (System.currentTimeMillis() - startTs));
        }
    }

    public ModelDeclaration parseFile(final File jslFile) {
        // get first entry of jslResource (root JslExpression)
        final Iterator<EObject> iterator = loadJslFromFile(jslFile).getContents().iterator();
        if (iterator.hasNext()) {
            return (ModelDeclaration) EcoreUtil.copy(iterator.next());
        } else {
            return null;
        }
    }

    public ModelDeclaration parseStream(final InputStream stream) {
        return parseStream(stream, URI.createURI("urn:" + UUID.randomUUID()));
    }

    public ModelDeclaration parseStream(final InputStream stream, final URI resourceUri) {
        // get first entry of jslResource (root JslExpression)
        final Iterator<EObject> iterator = loadJslFromStream(stream, resourceUri).getContents().iterator();
        if (iterator.hasNext()) {
            return (ModelDeclaration) EcoreUtil.copy(iterator.next());
        } else {
            return null;
        }
    }

    public ModelDeclaration parseString(final String jslExpression) {
        return parseString(jslExpression, URI.createURI("urn:" + UUID.randomUUID()));
    }

    public ModelDeclaration parseString(final String jslExpression, final URI resourceUri) {
        XtextResource resource = loadJslFromString(jslExpression, resourceUri);
        EList<Diagnostic> errors = resource.getErrors();
        if (!errors.isEmpty()) {
            throw new JslParseException(jslExpression, errors);
        }
        Iterator<EObject> iterator = resource.getContents().iterator();
        if (iterator.hasNext()) {
            return (ModelDeclaration) EcoreUtil.copy(iterator.next());
        } else {
            return null;
        }
    }
}
