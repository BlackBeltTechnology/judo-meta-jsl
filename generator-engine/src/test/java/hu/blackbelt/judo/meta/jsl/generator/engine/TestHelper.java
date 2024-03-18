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

import com.github.jknack.handlebars.ValueResolver;
import com.github.jknack.handlebars.internal.lang3.StringUtils;
import hu.blackbelt.judo.generator.commons.StaticMethodValueResolver;
import hu.blackbelt.judo.generator.commons.annotations.TemplateHelper;
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferDeclaration;
import lombok.SneakyThrows;
import lombok.extern.java.Log;
import org.springframework.expression.spel.support.StandardEvaluationContext;

import java.util.List;
import java.util.stream.Collectors;

import static java.util.Arrays.stream;

@Log
@TemplateHelper
public class TestHelper extends StaticMethodValueResolver {

    public static String plainName(String input) {
        return input
//                .replaceAll("[^\\\\u(\\p{XDigit}{4})]", "_")
                .replaceAll("[^\\.A-Za-z0-9_]", "_").toLowerCase();
    }

    public static String pathName(String fqName) {
        return fqName
                .replaceAll("\\.", "__")
                .replaceAll("::", "__")
                .replaceAll("#", "__")
                .replaceAll("/", "__")
                .replaceAll("([a-z])([A-Z]+)", "$1_$2")
                .toLowerCase();
    }

    public static String path(String fqName) {
        String fq = pathName(fqName);
        if (fq.lastIndexOf("__") > -1) {
            return fq.substring(fq.lastIndexOf("__") + 2);
        } else {
            return fq;
        }
    }

    public static String packageName(String packageName) {
        List<String> nameTokens = stream(packageName
                .split("::"))
                .collect(Collectors.toList());
        if (nameTokens.size() > 2) {
            nameTokens.remove(0);
            nameTokens.remove(nameTokens.size() - 1);
            return nameTokens.stream()
                    .map(s -> StringUtils.capitalize(
                            stream(s.replaceAll("#", "::")
                                    .replaceAll("\\.", "::")
                                    .replaceAll("/", "::")
                                    .replaceAll("_", "::")
                                    .split("::"))
                                    .map(t -> StringUtils.capitalize(t))
                                    .collect(Collectors.joining())
                    ))
                    .collect(Collectors.joining());
        }
        return null;
    }

    public static String fQName(TransferDeclaration transferDeclaration) {
        return ((ModelDeclaration) transferDeclaration.eContainer()).getName() + "::" + transferDeclaration.getName();
    }

    public static String modelName(String fqName) {
        String[] splitted = fqName.split("::");
        return fqClass(stream(splitted)
                .map(s -> StringUtils.capitalize(s))
                .findFirst().get());
    }

    @Deprecated
    public static String fqClass(String fqName) {
        return stream(fqName.replaceAll("#", "::")
                .replaceAll("\\.", "::")
                .replaceAll("/", "::")
                .replaceAll("_", "::")
                .split("::"))
                .map(s -> StringUtils.capitalize(s))
                .collect(Collectors.joining());
    }

    public static String fqClassWithoutModel(String fqName) {
        return stream(fqName.replaceAll("#", "::")
                .replaceAll("\\.", "::")
                .replaceAll("/", "::")
                .split("::"))
                .skip(1)
                .map(s -> StringUtils.capitalize(s))
                .collect(Collectors.joining());
    }

}
