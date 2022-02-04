package hu.blackbelt.judo.meta.jsl.runtime;

import hu.blackbelt.judo.meta.jsl.jsldsl.support.JslDslModelResourceSupport;
import org.eclipse.emf.common.util.URI;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static hu.blackbelt.judo.meta.jsl.jsldsl.support.JslDslModelResourceSupport.jslDslModelResourceSupportBuilder;

class JslDslExecutionContextTest {

    @Test
    @DisplayName("Create Jsl model with builder pattern")
    void testJslReflectiveCreated() throws Exception {

        String createdSourceModelName = "urn:jsl.judo-meta-jsl";

        JslDslModelResourceSupport jslModelSupport = jslDslModelResourceSupportBuilder()
                .uri(URI.createFileURI(createdSourceModelName))
                .build();

        // Build model here
    }
}