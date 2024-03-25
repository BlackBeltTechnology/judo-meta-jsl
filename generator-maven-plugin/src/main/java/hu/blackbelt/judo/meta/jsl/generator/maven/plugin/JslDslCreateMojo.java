package hu.blackbelt.judo.meta.jsl.generator.maven.plugin;

/*-
 * #%L
 * Judo :: JSL :: Model :: Generator :: Maven :: Plugin
 * %%
 * Copyright (C) 2018 - 2023 BlackBelt Technology
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

import com.google.common.base.Charsets;
import com.google.common.collect.Maps;
import hu.blackbelt.judo.generator.commons.ModelGenerator;
import hu.blackbelt.judo.generator.commons.TemplateHelperFinder;
import hu.blackbelt.judo.meta.jsl.generator.engine.JslDslGenerator;
import hu.blackbelt.judo.meta.jsl.generator.engine.JslDslGeneratorParameter;
import hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel;
import hu.blackbelt.judo.meta.jsl.jsldsl.support.JslDslModelResourceSupport;
import hu.blackbelt.judo.meta.jsl.runtime.JslParser;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.Parameter;
import org.apache.maven.plugins.annotations.ResolutionScope;
import org.apache.commons.text.StringSubstitutor;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.net.URI;
import java.nio.file.Files;
import java.util.*;
import java.util.concurrent.atomic.AtomicReference;
import java.util.stream.Collectors;

import static hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel.LoadArguments.jslDslLoadArgumentsBuilder;

@Mojo(name = "create",
        requiresProject = false,
        requiresDependencyResolution = ResolutionScope.NONE)
public class JslDslCreateMojo extends AbstractJslDslProjectMojo {

    @Parameter(name = "modelName", property = "modelName", required = true)
    private String modelName;

    @Parameter(name = "groupId", property = "projectGroupId", required = true)
    private String groupId;

    @Parameter(name = "version", property = "projectVersion", defaultValue = "1.0.0-SNAPSHOT")
    private String version;

    @Parameter(name = "type", property = "projectType", defaultValue = "fullstack-project")
    private String type;

    @Parameter(name = "uris", property = "projectUris", defaultValue = "mvn:hu.blackbelt.judo.template:judo-jsl-fullstack-project-template-common:${judo-jsl-fullstack-project-template-version}," +
            "mvn:hu.blackbelt.judo.template:judo-jsl-fullstack-project-template-root:${judo-jsl-fullstack-project-template-version}")
    private List<String> uris = new ArrayList<>();

    @Parameter(name = "helpers", property = "projectHelpers")
    private List<String> helpers = new ArrayList<>();

    @Parameter(name = "versionProperties", property = "versionProperties", defaultValue = "./judo-version.properties")
    protected File versionProperties;

    @Parameter(name = "contextAccessor", property = "contextAccessor")
    private String contextAccessor;

    @Parameter(name = "scanDependencies", property = "scanDependencies", defaultValue = "true")
    private Boolean scanDependencies;

    @Parameter(name = "validateChecksum", property = "validateChecksum", defaultValue = "true")
    private Boolean validateChecksum;

    @Parameter(name = "scanPackages", property="scanPackages")
    private List<String> scanPackages;

    @Parameter(name = "modelDirectory", property = "modelDirectory", defaultValue = "./model")
    protected File modelDirectory;

    @Parameter(name = "destination", property = "projectDestination", defaultValue = "./")
    protected File destination;

    LinkedHashMap<String, URI> uriMap = new LinkedHashMap<>();

    Map<String, Object> judoVersionProperties = new LinkedHashMap<>();

    @Override
    public File getDestination() {
        return destination;
    }

    @Override
    public void execute() throws MojoExecutionException, MojoFailureException {
        String defaultModel = """
            model %s;
			import judo::types;
			entity User {
			    identifier String userName required;
			    field Boolean isActive;
			}
			
			transfer UserTransfer(User u) {
			    field String userName <= u.userName set: true;
			}
			
			actor Actor human
			    realm: "COMPANY"
			    claim: "userName"
			    identity: UserTransfer::userName
			    guard: User.all().filter(u | u.userName == String.getVariable(category = "PRINCIPAL", key = "preferred_username")).any().isActive
			{}
            """.formatted(modelName);


        modelDirectory.mkdirs();
        sources.clear();
        sources.add(modelDirectory.getAbsolutePath());

        File modelFile = new File(modelDirectory, modelName + ".jsl");
        try {
            Files.writeString(modelFile.toPath(), defaultModel);
        } catch (IOException e) {
            throw new MojoExecutionException("Could not save model: ", e);
        }

        if (versionProperties.exists()) {
            Properties prop = new Properties();
            try {
                prop.load(new FileReader(versionProperties, Charsets.UTF_8));
            } catch (IOException e) {
                throw new MojoExecutionException("Could not load properties file: " + versionProperties.getAbsolutePath(), e);
            }
            List<String> newUris = new ArrayList<>();
            for (String uri : uris) {
                newUris.add(StringSubstitutor.replace(uri, prop));
            }
            uris.clear();
            uris.addAll(newUris);
            for (String uri : newUris) {
                getLog().info("URI: " + uri);
            }
            judoVersionProperties.putAll(generalizeTemplateVariableNames(Maps.fromProperties(prop)));
        }
        judoVersionProperties.put("createdModelName", modelName);
        judoVersionProperties.put("groupId", groupId);
        judoVersionProperties.put("version", version);

        // judoVersionProperties.forEach((k, v) -> getLog().info(k + ": " + v));
        super.execute();
    }

    @Override
    public Map<String, URI> provideUriMap(ArtifactResolver artifactResolver) throws MojoExecutionException {
        if (uris != null) {
            for (String uri : uris) {
                if (uri != null && !uri.trim().equals("")) {
                    uriMap.put(uri, artifactResolver.getResolvedTemplateDirectory(uri).toURI());
                }
            }
        }
        return uriMap;
    }

    @Override
    public void performExecutionOnJslDslParameters(JslDslGeneratorParameter.JslDslGeneratorParameterBuilder jslGeneratorParameterBuilder) throws Exception {

        Collection<Class> resolvedHelpers = new HashSet<>();
        for (String helperClass : helpers) {
            try {
                Class clazz = Thread.currentThread().getContextClassLoader().loadClass(helperClass);
                resolvedHelpers.add(clazz);
            } catch (Exception e) {
                getLog().error("Could not load helper class: " + helperClass);
            }
        }

        AtomicReference<Class> contextAccessorClass = new AtomicReference<>();

        if (scanDependencies) {
            getLog().debug("Scanning classpath for helpers...");
            try {
                Collection<Class> scannedHelpers = TemplateHelperFinder.collectHelpersAsClass(scanPackages, Thread.currentThread().getContextClassLoader());
                for (Class helper : scannedHelpers) {
                    getLog().debug("Helper found: " + helper.getName());
                }
                if (scannedHelpers.size() == 0) {
                    getLog().warn("No class with @TemplateHelper found");
                }
                resolvedHelpers.addAll(scannedHelpers);
            } catch (IOException e) {
                throw new MojoExecutionException("Could not scan dependencies", e);
            }

            if (contextAccessor == null || contextAccessor.isBlank()) {
                TemplateHelperFinder.findContextAccessorAsClass(scanPackages, Thread.currentThread().getContextClassLoader()).ifPresent(c -> {
                    getLog().debug("ContextAccessor class found: " + c.getName());
                    contextAccessorClass.set(c);
                });
            }
        }

        if (contextAccessor != null && !"".equals(contextAccessor.trim())) {
            try {
                contextAccessorClass.set(Thread.currentThread().getContextClassLoader().loadClass(contextAccessor));
            } catch (Exception e) {
                throw new IllegalArgumentException("Could not load contextAccessor class: " + contextAccessor, e);
            }
        }


        if (uriMap != null && uriMap.size() > 0) {
            jslGeneratorParameterBuilder.generatorContext(ModelGenerator.createGeneratorContext(
                            ModelGenerator.CreateGeneratorContextArgument.builder()
                                    .descriptorName(type)
                                    .uris(uriMap)
                                    .helpers(resolvedHelpers)
                                    .contextAccessor(contextAccessorClass.get())
                                    .build()))
                    .validateChecksum(validateChecksum)
                    .extraContextVariables(() -> judoVersionProperties);

            JslDslGenerator.generateToDirectory(jslGeneratorParameterBuilder);
        }
    }


    private Map<String, String> generalizeTemplateVariableNames(Map<String, String> parametrers) {
        return parametrers.entrySet().stream().collect(
                Collectors.toMap(
                        e -> JslDslGenerator.generalizeName(String.valueOf(e.getKey())),
                        e -> e.getValue(),
                        (prev, next) -> next, HashMap::new
                ));
    }


}
