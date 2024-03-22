package hu.blackbelt.judo.meta.jsl.generator.engine;

/*-
 * #%L
 * Judo :: JSL :: Model :: Genetator :: Engine
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

import com.google.common.collect.ImmutableMap;
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorDeclaration;
import org.slf4j.Logger;
import hu.blackbelt.judo.generator.commons.ModelGeneratorContext;
import hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel;

import lombok.Builder;
import lombok.NonNull;

import java.io.File;
import java.util.Map;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.function.Supplier;

@Builder(builderMethodName = "jslDslGeneratorParameter")
public final class JslDslGeneratorParameter {
    @NonNull
    JslDslModel jslDslModel;

    @Builder.Default
    ModelGeneratorContext generatorContext = null;

    @Builder.Default
    Predicate<ActorDeclaration> actorTypePredicate = a -> true;

    @NonNull
    Function<ActorDeclaration, File> actorTypeTargetDirectoryResolver;

    @NonNull
    Supplier<File> targetDirectoryResolver;

    Logger log;

    @Builder.Default
    Supplier<Map<String, ?>> extraContextVariables = () -> ImmutableMap.of();

    @Builder.Default
    boolean validateChecksum = true;
}
