package hu.blackbelt.judo.meta.jsl.runtime;

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
import hu.blackbelt.judo.requirement.report.annotation.Requirement;

public class JslDslParserTest {

    Logger log = LoggerFactory.getLogger(JslDslParserTest.class);

    private static final String TEST_MODEL = "model SampleModel;\n" +
            "\n" +
            "type numeric Integer(precision = 9,  scale = 0);\n" +
            "type string String(min-size = 0, max-size = 128);\n";

    private static final String TEST_MODEL2 = "model SampleModel2;\n" +
            "import SampleModel;\n" +
            "entity Person {\n" +
            "field SampleModel::String name;\n" +
            "}\n";



    @Test
    @Requirement(reqs = {
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
    		"REQ-MDL-001",
    		"REQ-TYPE-001",
    		"REQ-TYPE-002",
    		"REQ-TYPE-004",
    		"REQ-TYPE-005",
    		"REQ-TYPE-006",
    		"REQ-TYPE-007",
    		"REQ-TYPE-009",
    		"REQ-TYPE-010",
    		"REQ-ENT-001",
    		"REQ-ENT-012",
    		"REQ-ENT-002",
    		"REQ-ENT-003",
    		"REQ-ENT-004",
    		"REQ-ENT-006",
    		"REQ-ENT-008",
    		"REQ-ENT-009",
    		"REQ-ENT-010",
    		"REQ-EXPR-001",
    		"REQ-EXPR-002",
    		"REQ-EXPR-003",
    		"REQ-EXPR-004",
    		"REQ-EXPR-005",
    		"REQ-EXPR-006",
    		"REQ-EXPR-008",
    		"REQ-EXPR-022"
    		//TODO: JNG-4398
    })
    public void testLoadFile() {
    	XtextResourceSet resourceSet = JslParser.loadJslFromFile(Arrays.asList(new File( "src/test/resources/sample.jsl")));
    	assertTrue(resourceSet.getResources().size() == 1);
    	assertTrue(resourceSet.getResources().get(0).getContents().get(0) instanceof ModelDeclaration);
    	assertTrue(((ModelDeclaration) resourceSet.getResources().get(0).getContents().get(0)).getName().equals("SampleModel"));
    }

    @Test
    @Requirement(reqs = {
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
    		"REQ-MDL-001",
    		"REQ-ENT-001",
    		"REQ-ENT-012",
    		"REQ-ENT-002"
    })
    public void testLoadInvalidFile() {

    	JslParseException exception = assertThrows(JslParseException.class, () -> {
        	JslParser.loadJslFromFile(Arrays.asList(new File( "src/test/resources/sample-invalid.jsl")));
		});
    	
    	assertThat(exception.getMessage().replace("\t", "").replace("\n", ""), matchesPattern("^Error parsing JSL expression"
    			+ "Couldn't resolve reference to SingleType 'String2'. in "
    			+ "(.*)"
    			+ "#//@declarations.0/@members.0 at \\[4, 8\\]"));

    }

    @Test
    @Requirement(reqs = {
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
    		"REQ-MDL-001",
    		"REQ-TYPE-001",
    		"REQ-TYPE-004",
    		"REQ-TYPE-005"
    })
    public void testLoadStream() throws UnsupportedEncodingException {
    	XtextResourceSet resourceSet = JslParser.loadJslFromStream(Arrays.asList(new JslStreamSource(new ByteArrayInputStream(TEST_MODEL.getBytes("UTF-8")), URI.createURI("urn:testLoadString"))));
    	assertTrue(resourceSet.getResources().size() == 1);
    	assertTrue(resourceSet.getResources().get(0).getContents().get(0) instanceof ModelDeclaration);
    	assertTrue(((ModelDeclaration) resourceSet.getResources().get(0).getContents().get(0)).getName().equals("SampleModel"));
    }

    @Test
    @Requirement(reqs = {
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
    		"REQ-MDL-001",
    		"REQ-TYPE-001",
    		"REQ-TYPE-004",
    		"REQ-TYPE-005"
    })
    public void testLoadString() {
    	XtextResourceSet resourceSet = JslParser.loadJslFromString(Arrays.asList(TEST_MODEL));
    	assertTrue(resourceSet.getResources().size() == 1);
    	assertTrue(resourceSet.getResources().get(0).getContents().get(0) instanceof ModelDeclaration);
    	assertTrue(((ModelDeclaration) resourceSet.getResources().get(0).getContents().get(0)).getName().equals("SampleModel"));
    }

    @Test
    @Requirement(reqs = {
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
    		"REQ-MDL-001",
    		"REQ-TYPE-001",
    		"REQ-TYPE-002",
    		"REQ-TYPE-004",
    		"REQ-TYPE-005",
    		"REQ-TYPE-006",
    		"REQ-TYPE-007",
    		"REQ-TYPE-009",
    		"REQ-TYPE-010",
    		"REQ-ENT-001",
    		"REQ-ENT-012",
    		"REQ-ENT-002",
    		"REQ-ENT-003",
    		"REQ-ENT-004",
    		"REQ-ENT-006",
    		"REQ-ENT-008",
    		"REQ-ENT-009",
    		"REQ-ENT-010",
    		"REQ-EXPR-001",
    		"REQ-EXPR-002",
    		"REQ-EXPR-003",
    		"REQ-EXPR-004",
    		"REQ-EXPR-005",
    		"REQ-EXPR-006",
    		"REQ-EXPR-008",
    		"REQ-EXPR-022"
    		//TODO: JNG-4398
    })
    public void testGetModelDeclarationFromFiles() {
        Optional<ModelDeclaration> model = JslParser.getModelDeclarationFromFiles(
        		"SampleModel", 
        		Arrays.asList(new File("src/test/resources/sample.jsl")));
        assertTrue(model.isPresent());
        assertEquals("SampleModel", model.get().getName());
    }

    @Test
    @Requirement(reqs = {
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
    		"REQ-MDL-001",
    		"REQ-TYPE-001",
    		"REQ-TYPE-004",
    		"REQ-TYPE-005"
    })
    public void testGetModelDeclarationFromStreamSources() throws UnsupportedEncodingException {
    	Optional<ModelDeclaration> model = JslParser.getModelDeclarationFromStreamSources(
    			"SampleModel", 
    			Arrays.asList(new JslStreamSource(new ByteArrayInputStream(TEST_MODEL.getBytes("UTF-8")), URI.createURI("urn:testLoadFromByteArrayInputStream"))));
        assertTrue(model.isPresent());
        assertEquals("SampleModel", model.get().getName());
    }

    @Test
    @Requirement(reqs = {
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
    		"REQ-MDL-001",
    		"REQ-MDL-003",
    		"REQ-TYPE-001",
    		"REQ-TYPE-004",
    		"REQ-TYPE-005",
    		"REQ-ENT-001",
    		"REQ-ENT-002"
    })
    public void testGetModelDeclarationFromStrings() {
    	Optional<ModelDeclaration> model = JslParser.getModelDeclarationFromStrings(
    			"SampleModel2", 
    			Arrays.asList(TEST_MODEL, TEST_MODEL2));
        assertTrue(model.isPresent());
        assertEquals("SampleModel2", model.get().getName());
    }

    @Test
    @Requirement(reqs = {
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
    		"REQ-MDL-001",
    		"REQ-TYPE-001",
    		"REQ-TYPE-002",
    		"REQ-TYPE-004",
    		"REQ-TYPE-005",
    		"REQ-TYPE-006",
    		"REQ-TYPE-007",
    		"REQ-TYPE-009",
    		"REQ-TYPE-010",
    		"REQ-ENT-001",
    		"REQ-ENT-012",
    		"REQ-ENT-002",
    		"REQ-ENT-003",
    		"REQ-ENT-004",
    		"REQ-ENT-006",
    		"REQ-ENT-008",
    		"REQ-ENT-009",
    		"REQ-ENT-010",
    		"REQ-EXPR-001",
    		"REQ-EXPR-002",
    		"REQ-EXPR-003",
    		"REQ-EXPR-004",
    		"REQ-EXPR-005",
    		"REQ-EXPR-006",
    		"REQ-EXPR-008",
    		"REQ-EXPR-022"
    		//TODO: JNG-4398
    		//TODO: JNG-4394 The sample2.jsl needs to be change if the tickedt is done.
    })
    public void testGetModelFromFiles() {
    	JslDslModel model = JslParser.getModelFromFiles(
        		"SampleModel2", 
        		Arrays.asList(
        				new File("src/test/resources/sample.jsl"),
        				new File("src/test/resources/sample2.jsl")        				
        				));
        assertEquals("SampleModel2", model.getName());
    }

    @Test
    @Requirement(reqs = {
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
    		"REQ-MDL-001",
    		"REQ-MDL-003",
    		"REQ-TYPE-001",
    		"REQ-TYPE-004",
    		"REQ-TYPE-005",
    		"REQ-ENT-001",
    		"REQ-ENT-002"
    })
    public void testGetModelFromStreamSources() throws UnsupportedEncodingException {
    	JslDslModel model = JslParser.getModelFromStreamSources(
    			"SampleModel2", 
    			Arrays.asList(
    					new JslStreamSource(new ByteArrayInputStream(TEST_MODEL.getBytes("UTF-8")), 
    							URI.createURI("platform:/testLoadFromByteArrayInputStream.jsl")),
    					new JslStreamSource(new ByteArrayInputStream(TEST_MODEL2.getBytes("UTF-8")), 
    							URI.createURI("platform:/testLoadFromByteArrayInputStream2.jsl"))
    					));
        assertEquals("SampleModel2", model.getName());
    }

    @Test
    @Requirement(reqs = {
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
    		"REQ-MDL-001",
    		"REQ-MDL-003",
    		"REQ-TYPE-001",
    		"REQ-TYPE-004",
    		"REQ-TYPE-005",
    		"REQ-ENT-001",
    		"REQ-ENT-002"
    })
    public void testGetModelFromStrings() {
    	JslDslModel model = JslParser.getModelFromStrings(
    			"SampleModel2", 
    			Arrays.asList(TEST_MODEL, TEST_MODEL2));
        assertEquals("SampleModel2", model.getName());
    }

    
}
