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

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;

import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel;
import hu.blackbelt.judo.meta.jsl.jsldsl.support.JslDslModelResourceSupport;
import hu.blackbelt.judo.requirement.report.annotation.Requirement;

public class JslDslDefaultPlantumlDiagramTest {

    Logger log = LoggerFactory.getLogger(JslDslDefaultPlantumlDiagramTest.class);

    @Test
    @Requirement(reqs = {
    		"REQ-MDL-001",
    		"REQ-MDL-003",
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
    		"REQ-ENT-005",
    		"REQ-ENT-006",
    		"REQ-ENT-008",
    		"REQ-ENT-009",
    		"REQ-ENT-010",
    		"REQ-ENT-011",
    		"REQ-EXPR-001",
    		"REQ-EXPR-002",
    		"REQ-EXPR-003",
    		"REQ-EXPR-004",
    		"REQ-EXPR-005",
    		"REQ-EXPR-006",
    		"REQ-EXPR-007",
    		"REQ-EXPR-008",
    		"REQ-EXPR-022"
    		//TODO: JNG-4398
    })
    public void testGetModelFromFiles() throws IOException {
    	JslDslModel model = JslParser.getModelFromFiles(
        		"SalesModel", 
        		Arrays.asList(
        				new File("src/test/resources/salesModel1.jsl"),
        				new File("src/test/resources/salesModel2.jsl")        				
        				));
        assertEquals("SalesModel", model.getName());
        
        JslDslModelResourceSupport jslModelWrapper = JslDslModelResourceSupport.jslDslModelResourceSupportBuilder().resourceSet(model.getResourceSet()).build();
        ModelDeclaration salesModel = jslModelWrapper.getStreamOfJsldslModelDeclaration().filter(m -> m.getName().equals("SalesModel")).findFirst().get();
        ModelDeclaration salesModelContract = jslModelWrapper.getStreamOfJsldslModelDeclaration().filter(m -> m.getName().equals("SalesModelContract")).findFirst().get();

        
        Files.writeString(Path.of("target", "test-classes", "salesModel.plantuml"), JslParser.getDefaultPlantUMLDiagramGenerator().generate(salesModel, (String) null));
        Files.writeString(Path.of("target", "test-classes", "salesModelContract.plantuml"), JslParser.getDefaultPlantUMLDiagramGenerator().generate(salesModelContract, (String) null));

    }    
}
