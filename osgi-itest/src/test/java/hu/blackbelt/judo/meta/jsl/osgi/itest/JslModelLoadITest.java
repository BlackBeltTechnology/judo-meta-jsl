package hu.blackbelt.judo.meta.jsl.osgi.itest;

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

import hu.blackbelt.osgi.utils.osgi.api.BundleTrackerManager;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.ops4j.pax.exam.Configuration;
import org.ops4j.pax.exam.Option;
import org.ops4j.pax.exam.junit.PaxExam;
import org.ops4j.pax.exam.spi.reactors.ExamReactorStrategy;
import org.ops4j.pax.exam.spi.reactors.PerClass;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;
import org.osgi.service.log.LogService;

import javax.inject.Inject;
import java.io.*;
import java.net.MalformedURLException;

import static hu.blackbelt.judo.meta.jsl.osgi.itest.KarafFeatureProvider.*;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.ops4j.pax.exam.CoreOptions.*;
import static org.ops4j.pax.exam.OptionUtils.combine;
import static org.ops4j.pax.swissbox.core.BundleUtils.getBundle;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class JslModelLoadITest {


    public static final String HU_BLACKBELT_JUDO_META_JSL_OSGI = "hu.blackbelt.judo.meta.jsl.osgi";

    @Inject
    LogService log;

    @Inject
    protected BundleTrackerManager bundleTrackerManager;

    @Inject
    BundleContext bundleContext;

    @Configuration
    public Option[] config() throws FileNotFoundException, MalformedURLException {

        return combine(karafConfig(this.getClass()),
                mavenBundle(maven()
                        .groupId("hu.blackbelt.judo.meta")
                        .artifactId("hu.blackbelt.judo.meta.jsl.osgi")
                        .versionAsInProject())) ;
    }


    @Test
    public void testBundleActive() {
        assertNotNull(getBundle(bundleContext, HU_BLACKBELT_JUDO_META_JSL_OSGI));
        assertEquals(Bundle.ACTIVE, getBundle(bundleContext, HU_BLACKBELT_JUDO_META_JSL_OSGI)
                .getState());
    }
}
