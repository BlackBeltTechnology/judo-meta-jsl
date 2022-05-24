package hu.blackbelt.judo.meta.jsl.runtime;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.matchesPattern;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.UnsupportedEncodingException;
import java.util.Arrays;
import java.util.Optional;

import org.eclipse.emf.common.util.URI;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel;

public class JslDslParserTest {

    Logger log = LoggerFactory.getLogger(JslDslParserTest.class);

    private static final String TEST_MODEL = "model SalesModel\n" +
            "\n" +
            "type numeric Integer precision 9 scale 0\n" +
            "type string String max-length 128\n";

    private static final String TEST_MODEL2 = "model SalesModel2\n" +
            "import SalesModel\n" +
            "entity Person {\n" +
            "field SalesModel::String name\n" +
            "}\n";



    @Test
    public void testLoadFile() {
    	XtextResourceSet resourceSet = JslParser.loadJslFromFile(Arrays.asList(new File( "src/test/resources/sample.jsl")));
    	assertTrue(resourceSet.getResources().size() == 1);
    	assertTrue(resourceSet.getResources().get(0).getContents().get(0) instanceof ModelDeclaration);
    	assertTrue(((ModelDeclaration) resourceSet.getResources().get(0).getContents().get(0)).getName().equals("SalesModel"));
    }

    @Test
    public void testLoadInvalidFile() {

    	JslParseException exception = assertThrows(JslParseException.class, () -> {
        	JslParser.loadJslFromFile(Arrays.asList(new File( "src/test/resources/sample-invalid.jsl")));
		});
    	
    	assertThat(exception.getMessage().replace("\t", "").replace("\n", ""), matchesPattern("^Error parsing JSL expression"
    			+ "Couldn't resolve reference to EntityFieldSingleType 'String2'. in "
    			+ "(.*)"
    			+ "#//@declarations.0/@members.0 at \\[4, 8\\]"));

    }

    @Test
    public void testLoadStream() throws UnsupportedEncodingException {
    	XtextResourceSet resourceSet = JslParser.loadJslFromStream(Arrays.asList(new JslStreamSource(new ByteArrayInputStream(TEST_MODEL.getBytes("UTF-8")), URI.createURI("urn:testLoadString"))));
    	assertTrue(resourceSet.getResources().size() == 1);
    	assertTrue(resourceSet.getResources().get(0).getContents().get(0) instanceof ModelDeclaration);
    	assertTrue(((ModelDeclaration) resourceSet.getResources().get(0).getContents().get(0)).getName().equals("SalesModel"));
    }

    @Test
    public void testLoadString() {
    	XtextResourceSet resourceSet = JslParser.loadJslFromString(Arrays.asList(TEST_MODEL));
    	assertTrue(resourceSet.getResources().size() == 1);
    	assertTrue(resourceSet.getResources().get(0).getContents().get(0) instanceof ModelDeclaration);
    	assertTrue(((ModelDeclaration) resourceSet.getResources().get(0).getContents().get(0)).getName().equals("SalesModel"));
    }

    @Test
    public void testGetModelDeclarationFromFiles() {
        Optional<ModelDeclaration> model = JslParser.getModelDeclarationFromFiles(
        		"SalesModel", 
        		Arrays.asList(new File("src/test/resources/sample.jsl")));
        assertTrue(model.isPresent());
        assertEquals("SalesModel", model.get().getName());
    }

    @Test
    public void testGetModelDeclarationFromStreamSources() throws UnsupportedEncodingException {
    	Optional<ModelDeclaration> model = JslParser.getModelDeclarationFromStreamSources(
    			"SalesModel", 
    			Arrays.asList(new JslStreamSource(new ByteArrayInputStream(TEST_MODEL.getBytes("UTF-8")), URI.createURI("urn:testLoadFromByteArrayInputStream"))));
        assertTrue(model.isPresent());
        assertEquals("SalesModel", model.get().getName());
    }

    @Test
    public void testGetModelDeclarationFromStrings() {
    	Optional<ModelDeclaration> model = JslParser.getModelDeclarationFromStrings(
    			"SalesModel2", 
    			Arrays.asList(TEST_MODEL, TEST_MODEL2));
        assertTrue(model.isPresent());
        assertEquals("SalesModel2", model.get().getName());
    }

    @Test
    public void testGetModelFromFiles() {
    	JslDslModel model = JslParser.getModelFromFiles(
        		"SalesModel2", 
        		Arrays.asList(
        				new File("src/test/resources/sample.jsl"),
        				new File("src/test/resources/sample2.jsl")        				
        				));
        assertEquals("SalesModel2", model.getName());
    }

    @Test
    public void testGetModelFromStreamSources() throws UnsupportedEncodingException {
    	JslDslModel model = JslParser.getModelFromStreamSources(
    			"SalesModel2", 
    			Arrays.asList(
    					new JslStreamSource(new ByteArrayInputStream(TEST_MODEL.getBytes("UTF-8")), 
    							URI.createURI("platform:/testLoadFromByteArrayInputStream.jsl")),
    					new JslStreamSource(new ByteArrayInputStream(TEST_MODEL2.getBytes("UTF-8")), 
    							URI.createURI("platform:/testLoadFromByteArrayInputStream2.jsl"))
    					));
        assertEquals("SalesModel2", model.getName());
    }

    @Test
    public void testGetModelFromStrings() {
    	JslDslModel model = JslParser.getModelFromStrings(
    			"SalesModel2", 
    			Arrays.asList(TEST_MODEL, TEST_MODEL2));
        assertEquals("SalesModel2", model.getName());
    }

    
}
