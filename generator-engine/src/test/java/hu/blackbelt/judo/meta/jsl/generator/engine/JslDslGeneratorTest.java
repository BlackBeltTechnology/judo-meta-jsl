package hu.blackbelt.judo.meta.jsl.generator.engine;

import com.google.common.collect.ImmutableSet;
import org.junit.jupiter.api.Test;

import java.util.Collection;

import static hu.blackbelt.judo.meta.jsl.generator.engine.JslDslGenerator.getIgnoredFileMatcher;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertFalse;

public class JslDslGeneratorTest {

    @Test
    void testFileIgnore() throws Exception {
        Collection<String> ignoredFiles = ImmutableSet.<String>builder()
                .add("pom.xml")
                .add("**/pom.xml")
                .build();

        assertTrue(getIgnoredFileMatcher(ignoredFiles).apply("pom.xml"));
        assertFalse(getIgnoredFileMatcher(ignoredFiles).apply("readme.txt"));
        assertTrue(getIgnoredFileMatcher(ignoredFiles).apply("rest/pom.xml"));
        assertTrue(getIgnoredFileMatcher(ignoredFiles).apply("rest/other/pom.xml"));

    }
}
