package hu.blackbelt.judo.meta.jsl.runtime;

import com.google.common.collect.ImmutableSet;

/*-
 * #%L
 * Judo :: Jsl :: Model
 * %%
 * Copyright (C) 2018 - 2022 BlackBelt Technology
 * %%
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 *
 * This Source Code may also be made available under the following Secondary
 * Licenses when the conditions for such availability set forth in the Eclipse
 * Public License, v. 2.0 are satisfied: GNU General Public License, version 2
 * with the GNU Classpath Exception which is
 * available at https://www.gnu.org/software/classpath/license.html.
 *
 * SPDX-License-Identifier: EPL-2.0 OR GPL-2.0 WITH Classpath-exception-2.0
 * #L%
 */

import com.google.inject.Injector;
import hu.blackbelt.judo.meta.jsl.JslDslStandaloneSetupGenerated;
import hu.blackbelt.judo.meta.jsl.generator.JsldslDefaultPlantUMLDiagramGenerator;
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelImportDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel;

import hu.blackbelt.judo.meta.jsl.scoping.JudoFunctionsProvider;
import hu.blackbelt.judo.meta.jsl.scoping.JudoTypesProvider;
import org.eclipse.emf.common.notify.Notifier;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
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

import static hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel.buildJslDslModel;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.stream.Collectors;

public class JslParser {

    private static final Logger log = LoggerFactory.getLogger(JslParser.class);

    public static Set<String> INTERNAL_IMPORTS = ImmutableSet.of("judo::types", "judo::functions");

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

    public static JsldslDefaultPlantUMLDiagramGenerator getDefaultPlantUMLDiagramGenerator() {
        return injector().getInstance(JsldslDefaultPlantUMLDiagramGenerator.class);
    }

    public static Collection<ModelDeclaration> getInternalModelDeclarations() {
        ArrayList<ModelDeclaration> modelDeclarations = new ArrayList<>();
        modelDeclarations.add((ModelDeclaration) injector().getInstance(JudoTypesProvider.class).getResource().getContents().get(0));
        modelDeclarations.add((ModelDeclaration) injector().getInstance(JudoFunctionsProvider.class).getResource().getContents().get(0));
        return modelDeclarations;
    }

    public static XtextResourceSet loadJslFromStream(Collection<JslStreamSource> streams) {
        final long startTs = System.currentTimeMillis();
        try {
            final XtextResourceSet xtextResourceSet =  injector().getInstance(XtextResourceSet.class);
            final List<Issue> errors = new ArrayList<>();

            for (JslStreamSource stream : streams) {
                final XtextResource jslResource = (XtextResource) xtextResourceSet
                        .createResource(stream.getResourceUri(), JSLSCRIPT_CONTENT_TYPE);
                jslResource.load(stream.getStream(), xtextResourceSet.getLoadOptions());
            }

            for (Resource resource : xtextResourceSet.getResources()) {
                XtextResource jslResource = (XtextResource) resource;
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

    public static XtextResourceSet loadJslFromString(Collection<String> jslExpressions) {
        Collection<JslStreamSource> streams = jslExpressions.stream().map(s ->
                new JslStreamSource(new ByteArrayInputStream(s.getBytes(StandardCharsets.UTF_8)),
                        URI.createURI("platform:/" + s.hashCode() + ".jsl"))).collect(Collectors.toList());
        return loadJslFromStream(streams);
    }

    public static XtextResourceSet loadJslFromFile(final Collection<File> jslFiles) {
        Collection<JslStreamSource> streams = jslFiles.stream().map(f -> {
            try {
                return new JslStreamSource(new FileInputStream(f), URI.createURI(f.getAbsolutePath()));
            } catch (FileNotFoundException e) {
                throw new RuntimeException("File not found: " + f.getAbsolutePath());
            }
        }).collect(Collectors.toList());
        return loadJslFromStream(streams);
    }

    public static Optional<ModelDeclaration> getModelDeclarationFromStreamSources(String modelName, final Collection<JslStreamSource> jslStreams) {
        return getModelDeclarationFromXtextResourceSet(modelName, loadJslFromStream(jslStreams));
    }

    public static Optional<ModelDeclaration> getModelDeclarationFromFiles(String modelName, final Collection<File> jslFiles) {
        return getModelDeclarationFromXtextResourceSet(modelName, loadJslFromFile(jslFiles));
    }

    public static Optional<ModelDeclaration> getModelDeclarationFromStrings(String modelName, final Collection<String> jslStrings) {
        return getModelDeclarationFromXtextResourceSet(modelName, loadJslFromString(jslStrings));
    }

    public static Optional<ModelDeclaration> getModelDeclarationFromXtextResourceSet(String modelName, XtextResourceSet resourceSet) {
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

    public static Collection<ModelDeclaration> getAllModelDeclarationFromXtextResourceSet(XtextResourceSet resourceSet) {
        Collection<ModelDeclaration> modelDeclarations = new ArrayList<>();
        Iterator<Notifier> iter = resourceSet.getAllContents();
        while (iter.hasNext()) {
            Notifier o = iter.next();
            if (o instanceof ModelDeclaration) {
                modelDeclarations.add((ModelDeclaration) o);
            }
        }
        return modelDeclarations;
    }

    public static JslDslModel getModelFromStreamSources(String modelName, final Collection<JslStreamSource> jslStreams) {
        return getModelFromXtextResourceSet(modelName, loadJslFromStream(jslStreams));
    }

    public static JslDslModel getModelFromFiles(String modelName, final Collection<File> jslFiles) {
        return getModelFromXtextResourceSet(modelName, loadJslFromFile(jslFiles));
    }

    public static JslDslModel getModelFromStrings(String modelName, final Collection<String> jslStrings) {
        return getModelFromXtextResourceSet(modelName, loadJslFromString(jslStrings));
    }

    public static JslDslModel getModelFromXtextResourceSet(String modelName, XtextResourceSet resourceSet) {
        ModelDeclaration defaultModel = getModelDeclarationFromXtextResourceSet(modelName, resourceSet)
                .orElseThrow(() -> new IllegalArgumentException("Model with name '" + modelName + "' not found"));

        JslDslModel model = createModel(defaultModel.getName().replaceAll("::", "_"));
        for (Resource res : resourceSet.getResources()) {
            ModelDeclaration modelDecl = (ModelDeclaration) res.getContents().get(0);
            model.addContent(modelDecl);
        }
        return model;
    }


    private static JslDslModel createModel(String name) {
        return buildJslDslModel().uri(URI.createURI("urn:" + name + ".jsl")).name(name).build();
    }

    public static Collection<ModelDeclaration> collectReferencedModelDeclarations(ModelDeclaration modelDeclaration, Collection<ModelDeclaration> allModelDeclcarations) {
        Collection<ModelDeclaration> referenced = new ArrayList<>();
        referenced.add(modelDeclaration);
        collectImportedModelDeclaration(modelDeclaration, allModelDeclcarations, referenced);
        return  referenced;
    }

    private static void collectImportedModelDeclaration(ModelDeclaration modelDeclaration,  Collection<ModelDeclaration> all, Collection<ModelDeclaration> collected) {
        for (ModelImportDeclaration modelImport : modelDeclaration.getImports()) {
            if (!INTERNAL_IMPORTS.contains(modelImport.getModel().getName())) {
                if (!collected.stream().anyMatch(d -> d.getName().equals(modelImport.getModel().getName()))) {
                    ModelDeclaration imported = all.stream().filter(d -> d.getName().equals(modelImport.getModel().getName())).findFirst().orElseThrow(() -> new IllegalStateException("Model not found: " + modelImport.getModel().getName()));
                    collected.add(imported);
                    collectImportedModelDeclaration(imported, all, collected);
                }
            }
        }
    }

    public static Set<ModelDeclaration> getRootModelDeclarations(Collection<ModelDeclaration> modelDeclarations) {
        Set<String> imprtedModels = new HashSet<>();
        modelDeclarations.stream().forEach(m -> collectImortedModels(m, imprtedModels));
        return modelDeclarations.stream().filter(m -> !imprtedModels.contains(m.getName())).collect(Collectors.toSet());
    }


    private static void collectImortedModels(ModelDeclaration modelDeclaration, Set<String> referenced) {
        modelDeclaration.getImports().stream().forEach(m -> {
            if (!referenced.contains(m.getModel().getName())) {
                referenced.add(m.getModel().getName());
                collectImortedModels(m.getModel(), referenced);
            }
        });
    }
}
