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

import hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel;
import hu.blackbelt.judo.requirement.report.annotation.Requirement;

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
    @Requirement(reqs = {
    		
    })
    void loadJslModel() throws IOException, JslDslModel.JslDslValidationException {
        JslDslModel jslModel = loadJslDslModel(jslDslLoadArgumentsBuilder()
                .uri(URI.createFileURI(new File("src/test/resources/test.jsl.xmi").getAbsolutePath()))
                .name("test"));

        for (Iterator<EObject> i = jslModel.getResourceSet().getResource(jslModel.getUri(), false).getAllContents(); i.hasNext(); ) {
            log.info(i.next().toString());
        }
    }
}
