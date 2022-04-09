package hu.blackbelt.judo.meta.jsl.runtime;

import hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.util.Iterator;

import static hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel.LoadArguments.jslDslLoadArgumentsBuilder;
import static hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel.loadJslDslModel;


public class JslDslModelLoaderTest {

    static Logger log = LoggerFactory.getLogger(JslDslModelLoaderTest.class);
	
    @Test
    @DisplayName("Load Jsl Model")
    void loadJslModel() throws IOException, JslDslModel.JslDslValidationException {
        JslDslModel jslModel = loadJslDslModel(jslDslLoadArgumentsBuilder()
                .uri(URI.createFileURI(new File("src/test/resources/test.jsl.xmi").getAbsolutePath()))
                .name("test"));

        for (Iterator<EObject> i = jslModel.getResourceSet().getResource(jslModel.getUri(), false).getAllContents(); i.hasNext(); ) {
            log.info(i.next().toString());
        }
    }
}