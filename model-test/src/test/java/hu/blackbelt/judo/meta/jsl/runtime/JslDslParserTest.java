package hu.blackbelt.judo.meta.jsl.runtime;

import com.google.common.collect.ImmutableMap;
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.ecore.xmi.XMIResource;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceImpl;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.util.CancelIndicator;
import org.eclipse.xtext.validation.CheckMode;
import org.eclipse.xtext.validation.IResourceValidator;
import org.eclipse.xtext.validation.Issue;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

public class JslDslParserTest {

    Logger log = LoggerFactory.getLogger(JslDslParserTest.class);
    private JslParser parser;

    private static final String TEST_MODEL = "model SalesModel\n" +
            "\n" +
            "type numeric Integer precision 9 scale 0\n" +
            "type string String max-length 128\n\n" +
            "// end";



    @BeforeEach
    public void setUp() {
        parser = new JslParser();
    }

    @AfterEach
    public void tearDown() {
        parser = null;
    }

    private void validateResource(final XtextResource loaded) {
        final IResourceValidator validator = loaded.getResourceServiceProvider().getResourceValidator();
        final List<Issue> issues = validator.validate(loaded, CheckMode.ALL, CancelIndicator.NullImpl);

        Assertions.assertTrue(issues.isEmpty());

        Resource resource = new XMIResourceImpl(URI.createFileURI("target/classes/sample-jsl-" + UUID.randomUUID() + ".model"));
        resource.getContents().addAll(EcoreUtil.copyAll(loaded.getContents()));
        try {
            resource.save(ImmutableMap.of(XMIResource.OPTION_ENCODING, "UTF-8"));
        } catch (IOException ex) {
            log.error("Unable to save JSL model", ex);
        }
    }

    private void validateModelDeclaration(final ModelDeclaration modelDeclaration) {
        Assertions.assertTrue(modelDeclaration instanceof ModelDeclaration);
    }

    @Test
    public void testLoadFile() {
        final XtextResource sample = parser.loadJslFromFile(new File( "src/test/model/sample.jsl"));
        validateResource(sample);
    }

    @Test
    public void testLoadStream() {
        final XtextResource sample = parser.loadJslFromStream(new ByteArrayInputStream(TEST_MODEL.getBytes()), URI.createURI("urn:testLoadString"));
        validateResource(sample);
    }

    @Test
    public void testLoadString() {
        final XtextResource sample = parser.loadJslFromString(TEST_MODEL, URI.createURI("urn:testLoadStream"));
        validateResource(sample);
    }

    @Test
    public void testParseFile() {
        final ModelDeclaration modelDeclaration = parser.parseFile(new File("src/test/model/sample.jsl"));
        validateModelDeclaration(modelDeclaration);
    }

    @Test
    public void testParseStream() {
        final ModelDeclaration modelDeclaration = parser.parseStream(new ByteArrayInputStream(TEST_MODEL.getBytes()));
        validateModelDeclaration(modelDeclaration);
    }

    @Test
    public void testParseString() {
        final ModelDeclaration modelDeclaration = parser.parseString(TEST_MODEL);
        validateModelDeclaration(modelDeclaration);
    }

}
