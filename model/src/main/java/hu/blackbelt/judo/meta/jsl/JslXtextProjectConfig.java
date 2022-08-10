package hu.blackbelt.judo.meta.jsl;

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

import com.google.common.base.Objects;
import org.eclipse.xtext.xtext.generator.model.project.StandardProjectConfig;
import org.eclipse.xtext.xtext.generator.model.project.SubProjectConfig;

/**
 * MWE2 workflow generator configuration to fit JCL project structure
 */
public class JslXtextProjectConfig extends StandardProjectConfig {

	@Override
	protected String computeSrcGen(SubProjectConfig project) {
		if (Objects.equal(project, getGenericIde())) {
			if (super.isMavenLayout()) {
				return project.getRootPath() + "/../ide-common/" + "src/"+ computeSourceSet(project) + "/xtext-gen";
			} else {
				super.computeSrcGen(project);
			}
        } else if (Objects.equal(project, getEclipsePlugin())) {
			return project.getRootPath() + "/../ui/" + "src/"+ computeSourceSet(project) + "/xtext-gen";
        }
        return super.computeSrcGen(project);
	}	

	@Override
    protected String computeName(SubProjectConfig project) {
        if (Objects.equal(project, getGenericIde())) {
        	return "ide/ide-common";
        } else if (Objects.equal(project, getEclipsePlugin())) {
        	return "ide/ui";
        }
        return super.computeName(project);
    }

}
