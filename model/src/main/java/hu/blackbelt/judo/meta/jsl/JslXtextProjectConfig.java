package hu.blackbelt.judo.meta.jsl;

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
