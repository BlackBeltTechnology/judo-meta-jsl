package hu.blackbelt.judo.meta.jsl.generator.maven.plugin;

/*-
 * #%L
 * Judo :: PSM :: Model :: Generator :: Maven :: Plugin
 * %%
 * Copyright (C) 2018 - 2023 BlackBelt Technology
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

import hu.blackbelt.judo.meta.jsl.generator.engine.JslDslGenerator;
import hu.blackbelt.judo.meta.jsl.generator.engine.JslDslGeneratorParameter;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugins.annotations.LifecyclePhase;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.Parameter;
import org.apache.maven.plugins.annotations.ResolutionScope;

import java.io.File;
import java.net.URI;
import java.util.Map;

@Mojo(name = "checksum",
        defaultPhase = LifecyclePhase.GENERATE_RESOURCES,
        requiresDependencyResolution = ResolutionScope.COMPILE)
public class JslDslProjectCalculateChecksumMojo extends AbstractJslDslProjectMojo {

    @Parameter(name = "destination", property = "projectDestination", defaultValue = "${project.basedir}")
    protected File destination;

    @Override
    public void performExecutionOnJslDslParameters(JslDslGeneratorParameter.JslDslGeneratorParameterBuilder jslDslGeneratorParameterBuilder) throws Exception {
        JslDslGenerator.recalculateChecksumForDirectory(jslDslGeneratorParameterBuilder);
    }

    @Override
    public Map<String, URI> provideUriMap(ArtifactResolver artifactResolver) throws MojoExecutionException {
        return null;
    }

    @Override
    public File getDestination() {
        return destination;
    }
}
