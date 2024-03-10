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
import hu.blackbelt.judo.generator.commons.ModelGenerator;
import hu.blackbelt.judo.generator.commons.TemplateHelperFinder;
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel;
import hu.blackbelt.judo.meta.jsl.runtime.JslParser;
import lombok.extern.slf4j.Slf4j;
import org.eclipse.emf.ecore.EObject;
import org.junit.jupiter.api.*;

import java.io.File;
import java.util.*;
import java.util.stream.Stream;
import java.util.stream.StreamSupport;

import static hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel.SaveArguments.jslDslSaveArgumentsBuilder;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.linesOf;
import static org.junit.jupiter.api.Assertions.assertTrue;

@Slf4j
public class TestModel2TemplateTest {

    public static final String NORTHWIND_TEST = "test";

    public static final String BASE = "base";
    public static final String OVERRIDE = "override";

    private final String TEST_SOURCE_MODEL_NAME = "urn:test.judo-meta-jsl";
    private final String TEST = "Test";
    private final String TARGET_TEST_CLASSES = "target/test-classes";

    JslDslModel jslDslModel;

    String testName;
    Map<EObject, List<EObject>> resolvedTrace;

    @AfterEach
    void tearDown() throws Exception {
        jslDslModel.saveJslDslModel(jslDslSaveArgumentsBuilder().file(new File(TARGET_TEST_CLASSES, testName + "-jsl.model")));
    }

    @Test
    void testCreateApplication() throws Exception {

        testName = "northwind";
        jslDslModel = JslParser.getModelFromStrings("northwind", List.of("""
            model northwind;
            
            import judo::types;
            
            entity User {
                identifier required String userName;
            }
            
            view UserListView {
                table UserRow[] users <= User.all();
            }
            
            row UserRow(User user) {
                column String userName <= user.userName;
            }
            
            entity Product {
                identifier required String name;
                field required Integer price;
            }
            
            view ProductListView {
                table ProductRow[] products <= Product.all();
            }
            
            row ProductRow(Product product) {
                column String name <= product.name;
                column String price <= product.price.asString() + " HUF";
            }
            
            actor human Admin(User user) {
                group first label:"Group1" {
                    group second label:"Group2" {
                        menu ProductListView products label:"Products" icon:"close";
                    }
                    menu ProductListView products2 label:"Products2";
                }
                menu UserListView users label:"Users" icon:"account-multiple";
            }
        """));

        File testOutput =  new File(TARGET_TEST_CLASSES, NORTHWIND_TEST);

        LinkedHashMap uris = new LinkedHashMap();
        uris.put(new File(TARGET_TEST_CLASSES, BASE).toString(), new File(TARGET_TEST_CLASSES, BASE).toURI());
        uris.put(new File(TARGET_TEST_CLASSES, OVERRIDE).toString(), new File(TARGET_TEST_CLASSES, OVERRIDE).toURI());

        try (BufferedSlf4jLogger bufferedLog = new BufferedSlf4jLogger(log)) {
            JslDslGenerator.generateToDirectory(JslDslGeneratorParameter.jslDslGeneratorParameter()
                    .jslDslModel(jslDslModel)
                    .generatorContext(ModelGenerator.createGeneratorContext(
                            ModelGenerator.CreateGeneratorContextArgument.builder()
                                    .descriptorName("test-project")
                                    .uris(uris)
                                    .helpers(TemplateHelperFinder.collectHelpersAsClass(this.getClass().getClassLoader()))
                                    .build()))
                    .log(bufferedLog)
                    .targetDirectoryResolver(() -> testOutput)
                    .actorTypeTargetDirectoryResolver( a -> testOutput)
                    .extraContextVariables(() -> ImmutableMap.of("extra", "extra"))
            );
        }

        final Optional<ActorDeclaration> application = allModelDeclaration(ActorDeclaration.class)
                .findAny();
        assertTrue(application.isPresent());

        assertTrue(new File(testOutput, "Admin").isDirectory());

        assertThat(linesOf(new File(testOutput, "Admin/actorToOverride"))).containsExactly(
                "DECORATED Name: Admin",
                "Extra: extra",
                "FQName: northwind::Admin",
                "PlainName: admin",
                "Plain FQ: northwind__admin",
                "Path FQ: northwind__admin",
                "ModelName FQ: Northwind",
                "Package Name FQ: ",
                ""
        );

        assertThat(linesOf(new File(testOutput, "Admin/actorReplaced"))).containsExactly(
                "REPLACED",
                "Name: Admin",
                "FQName: northwind::Admin",
                "PlainName: admin",
                "Plain FQ: northwind__admin",
                "Path FQ: northwind__admin",
                "ModelName FQ: Northwind",
                "Package Name FQ: ",
                ""
        );

        assertThat(!new File(testOutput, "Admin/actorToReplace").exists());

        assertThat(!new File(testOutput, "Admin/actorToDelete").exists());

        assertThat(!new File(testOutput, "Admin/actorToNotGenerated").exists());

    }

    static <T> Stream<T> asStream(Iterator<T> sourceIterator, boolean parallel) {
        Iterable<T> iterable = () -> sourceIterator;
        return StreamSupport.stream(iterable.spliterator(), parallel);
    }

    <T> Stream<T> allModelDeclaration() {
        return asStream((Iterator<T>) jslDslModel.getResourceSet().getAllContents(), false);
    }

    private <T> Stream<T> allModelDeclaration(final Class<T> clazz) {
        return allModelDeclaration().filter(e -> clazz.isAssignableFrom(e.getClass())).map(e -> (T) e);
    }

}
