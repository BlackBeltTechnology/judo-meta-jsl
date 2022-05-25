package hu.blackbelt.judo.meta.jsl.runtime;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel;
import hu.blackbelt.judo.meta.jsl.jsldsl.support.JslDslModelResourceSupport;

public class JslDslDefaultPlantumlDiagramTest {

    Logger log = LoggerFactory.getLogger(JslDslDefaultPlantumlDiagramTest.class);

    @Test
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
