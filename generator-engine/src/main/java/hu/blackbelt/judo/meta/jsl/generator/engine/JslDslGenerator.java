package hu.blackbelt.judo.meta.jsl.generator.engine;

/*-
 * #%L
 * Judo :: JSL :: Model :: Generator :: Engine
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

import com.github.jknack.handlebars.Context;
import com.github.jknack.handlebars.ValueResolver;
import com.google.common.collect.ImmutableMap;
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel;
import hu.blackbelt.judo.meta.jsl.jsldsl.support.JslDslModelResourceSupport;
import org.slf4j.Logger;
import hu.blackbelt.judo.generator.commons.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.expression.spel.support.StandardEvaluationContext;

import java.io.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.function.*;
import java.util.stream.Collectors;

import static hu.blackbelt.judo.generator.commons.ModelGenerator.*;

/**
 * This class loads descriptor yaml file and processing it.
 * The yaml file contains an entries describes the generation itself. On entry can
 * be used to generate several entries of files. @see {@link hu.blackbelt.judo.generator.commons.GeneratorTemplate}
 */
@Slf4j
public class JslDslGenerator {

    public static final String NAME = "name";
    public static final Boolean TEMPLATE_DEBUG = System.getProperty("templateDebug") != null;
    public static final String ADD_DEBUG_TO_TEMPLATE = "addDebugToTemplate";
    public static final String TEMPLATE = "template";

    public static final String SELF = "self";
    public static final String ACTOR_TYPES = "actorTypes";
    public static final String ACTOR_TYPE = "actorType";
    public static final String MODEL = "model";


    public static GeneratorParameter<ActorDeclaration> mapJslDslParameters(JslDslGeneratorParameter parameter) {
        return GeneratorParameter.<ActorDeclaration>generatorParameter()
                .generatorContext(parameter.generatorContext)
                .discriminatorPredicate(parameter.actorTypePredicate)
                .extraContextVariables(parameter.extraContextVariables)
                .targetDirectoryResolver(parameter.targetDirectoryResolver)
                .discriminatorTargetDirectoryResolver(parameter.actorTypeTargetDirectoryResolver)
                .discriminatorTargetNameResolver(a -> a.getName().replaceAll("[^\\.A-Za-z0-9_]", "_").toLowerCase())
                .log(parameter.log)
                .performExecutor(p -> execute(parameter))
                .validateChecksum(parameter.validateChecksum)
                .build();
    }

    public static GeneratorResult<ActorDeclaration> execute(JslDslGeneratorParameter.JslDslGeneratorParameterBuilder builder) throws RuntimeException {
        return execute(builder.build());
    }
    public static GeneratorResult<ActorDeclaration> execute(JslDslGeneratorParameter parameter) throws RuntimeException {
        final AtomicBoolean loggerToBeClosed = new AtomicBoolean(false);
        Logger log = Objects.requireNonNullElseGet(parameter.log,
                () -> {
                    loggerToBeClosed.set(true);
                    return new BufferedSlf4jLogger(JslDslGenerator.log);
                });
        try {
            return execute(parameter.jslDslModel, mapJslDslParameters(parameter), log);
        } catch (ExecutionException | InterruptedException e) {
            throw new RuntimeException(e);
        } finally {
            if (loggerToBeClosed.get()) {
                try {
                    if (log instanceof Closeable) {
                        ((Closeable) log).close();
                    }
                } catch (Exception e) {
                    //noinspection ThrowFromFinallyBlock
                    throw new RuntimeException(e);
                }
            }
        }
    }

    private static GeneratorResult<ActorDeclaration> execute(JslDslModel jslDslModel, GeneratorParameter<ActorDeclaration> parameter, Logger log) throws InterruptedException, ExecutionException {
        GeneratorResult<ActorDeclaration> result = GeneratorResult.<ActorDeclaration>generatorResult().build();

        JslDslModelResourceSupport modelResourceSupport = JslDslModelResourceSupport.jslDslModelResourceSupportBuilder()
                .resourceSet(jslDslModel.getResourceSet())
                .build();

        modelResourceSupport.getStreamOfJsldslActorDeclaration().forEach(
                app -> result.getGeneratedByDiscriminator().put(app, ConcurrentHashMap.newKeySet()));

        Set<ActorDeclaration> actorTypes = modelResourceSupport.getStreamOfJsldslActorDeclaration()
                .filter(parameter.getDiscriminatorPredicate()).collect(Collectors.toSet());

        ModelDeclaration model = modelResourceSupport.getStreamOfJsldslModelDeclaration().findFirst()
                .orElseThrow(() -> new RuntimeException("Could not find the model entry"));

        List<CompletableFuture<GeneratedFile>> tasks = new ArrayList<>();

        // Handlebars context builder
        for (GeneratorTemplate generatorTemplate : parameter.getGeneratorContext().getGeneratorModel().getTemplates()) {
            // It creates parameters accessible within templates.
            // It returns the function, the context creation itself is called when template is processed.
            Function<Object, Context.Builder> defaultHandlebarsContextBuilder = o -> {
                ImmutableMap.Builder<String, Object> params = ImmutableMap.<String, Object>builder()
                        .put(ADD_DEBUG_TO_TEMPLATE, TEMPLATE_DEBUG)
                        .put(ACTOR_TYPES, actorTypes)
                        .put(TEMPLATE, generatorTemplate)
                        .put(SELF, o)
                        .put(MODEL, model);

                Map<String, ?> extraVariables = parameter.getExtraContextVariables().get();
                extraVariables.forEach((k, v) -> {
                    if (k != null && v != null) {
                        params.put(k, v);
                    }
                });

                Context.Builder contextBuilder = Context.newBuilder(params.build());
                if (parameter.getGeneratorContext().getValueResolvers().size() > 0) {
                    contextBuilder.push(parameter.getGeneratorContext().getValueResolvers().toArray(ValueResolver[]::new));
                }
                return contextBuilder;
            };

            // SpringEL Context builder
            Function<Object, StandardEvaluationContext> defaultSpringELContextProvider = o -> {
                StandardEvaluationContext templateContext = parameter.getGeneratorContext().createSpringEvaluationContext();
                templateContext.setVariable(ADD_DEBUG_TO_TEMPLATE, TEMPLATE_DEBUG);
                templateContext.setVariable(ACTOR_TYPES, actorTypes);
                templateContext.setVariable(TEMPLATE, generatorTemplate);
                templateContext.setVariable(SELF, o);
                templateContext.setVariable(MODEL, model);

                Map<String, ?> extraVariables = parameter.getExtraContextVariables().get();
                extraVariables.forEach(templateContext::setVariable);
                return templateContext;
            };

            StandardEvaluationContext evaulationContext = defaultSpringELContextProvider.apply(model);
            final TemplateEvaulator templateEvaulator;
            try {
                templateEvaulator = generatorTemplate.getTemplateEvalulator(
                        parameter.getGeneratorContext(), evaulationContext);
            } catch (IOException e) {
                throw new RuntimeException("Could not evaluate template", e);
            }

            if (generatorTemplate.isActorTypeBased()) {
                actorTypes.forEach(actorType -> {
                    evaulationContext.setVariable(ACTOR_TYPE, actorType);

                    Collection<?> processingList = new HashSet<>(Collections.singletonList(actorType));
                    if (templateEvaulator.getFactoryExpression() != null) {
                        processingList = templateEvaulator.getFactoryExpressionResultOrValue(generatorTemplate, actorType, Collection.class);
                    }
                    for (Object element : templateEvaulator.getFactoryExpressionResultOrValue(generatorTemplate, processingList, Collection.class)) {
                        tasks.add(CompletableFuture.supplyAsync(() -> {
                            StandardEvaluationContext templateContext = defaultSpringELContextProvider.apply(element);
                            templateContext.setVariable(ACTOR_TYPE, actorType);

                            Context.Builder contextBuilder = defaultHandlebarsContextBuilder.apply(element)
                                    .combine(ACTOR_TYPE, actorType);

                            callBindContextForTypeIfCan(parameter.getGeneratorContext(), StandardEvaluationContext.class, templateContext);
                            callBindContextForTypeIfCan(parameter.getGeneratorContext(), Map.class, parameter.getExtraContextVariables().get());

                            generatorTemplate.evalToContextBuilder(templateEvaulator, contextBuilder, templateContext);
                            GeneratedFile generatedFile = generateFile(parameter.getGeneratorContext(), templateContext, templateEvaulator, generatorTemplate, contextBuilder, log);
                            result.getGeneratedByDiscriminator().get(actorType).add(generatedFile);
                            return generatedFile;
                        }));
                    }
                });
            } else {
                evaulationContext.setVariable(TEMPLATE, generatorTemplate);
                Set<?> iterableCollection = new HashSet<>(List.of(generatorTemplate));

                if (templateEvaulator.getTemplate() != null) {
                    iterableCollection = new HashSet<>(Collections.singletonList(model));
                }

                for (Object element : templateEvaulator.getFactoryExpressionResultOrValue(generatorTemplate, iterableCollection, Collection.class)) {
                    tasks.add(CompletableFuture.supplyAsync(() -> {

                        StandardEvaluationContext templateContext = defaultSpringELContextProvider.apply(element);
                        Context.Builder contextBuilder = defaultHandlebarsContextBuilder.apply(element);

                        callBindContextForTypeIfCan(parameter.getGeneratorContext(), StandardEvaluationContext.class, templateContext);
                        callBindContextForTypeIfCan(parameter.getGeneratorContext(), Map.class, parameter.getExtraContextVariables().get());

                        generatorTemplate.evalToContextBuilder(templateEvaulator, contextBuilder, evaulationContext);
                        GeneratedFile generatedFile = generateFile(parameter.getGeneratorContext(), templateContext, templateEvaulator, generatorTemplate, contextBuilder, log);
                        result.getGenerated().add(generatedFile);
                        return generatedFile;
                    }));
                }
            }
        }

        StreamHelper.performFutures(tasks);
        return result;
    }

    public static void generateToDirectory(JslDslGeneratorParameter.JslDslGeneratorParameterBuilder builder) throws Exception {
        generateToDirectory(builder.build());
    }

    public static void generateToDirectory(JslDslGeneratorParameter parameter) throws Exception {
        ModelGenerator.generateToDirectory(mapJslDslParameters(parameter));
    }


    public static void recalculateChecksumForDirectory(JslDslGeneratorParameter.JslDslGeneratorParameterBuilder builder) throws Exception {
        recalculateChecksumForDirectory(builder.build());
    }

    public static void recalculateChecksumForDirectory(JslDslGeneratorParameter parameter) throws Exception {

        GeneratorParameter<ActorDeclaration> genericParams = mapJslDslParameters(parameter);

        JslDslModelResourceSupport modelResourceSupport = JslDslModelResourceSupport.jslDslModelResourceSupportBuilder()
                .resourceSet(parameter.jslDslModel.getResourceSet())
                .build();

        Set<ActorDeclaration> applications = modelResourceSupport
                .getStreamOfJsldslActorDeclaration()
                .filter(genericParams.getDiscriminatorPredicate())
                .collect(Collectors.toSet());

        ModelGenerator.recalculateChecksumToDirectory(genericParams, applications);
    }


    public static String generalizeName(String str) {
        if (str == null || str.length() == 0) {
            return str;
        }
        boolean isUpperSnakeCae = !str.matches(negateRegex("([A-Z_0-9]*)"));
        if (isUpperSnakeCae) {
            return toCamelCase(Arrays.stream(str.split("_")).map(s -> capitalize(s)).collect(Collectors.joining()));
        } else if (str.matches(".*[.#@_,;:-].*")) {
            return toCamelCase(Arrays.stream(str.split("[.#@_,;:-]")).map(s -> firstToUpper(s)).collect(Collectors.joining()));
        }
        return toCamelCase(str);
    }

    public static  String negateRegex(String regex) {
        return "(?!(?:" + regex + ")$).*";
    }

    public static String toCamelCase(String str) {
        String[] words = str.split("(?=[A-Z])");
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < words.length; i++) {
            String word = words[i];
            if (i == 0) {
                word = word.isEmpty() ? word : word.toLowerCase();
            } else {
                word = word.isEmpty() ? word : capitalize(word);
            }
            builder.append(word);
        }
        return builder.toString();
    }

    public static String firstToUpper(String str) {
        if (str != null && str.length() > 1) {
            return str.substring(0, 1).toUpperCase() + str.substring(1);
        }
        return str;
    }

    private static String capitalize(String str) {
        if (str != null && str.length() > 1) {
            return str.substring(0,1).toUpperCase() + str.substring(1).toLowerCase();
        }
        return str;
    }


}
