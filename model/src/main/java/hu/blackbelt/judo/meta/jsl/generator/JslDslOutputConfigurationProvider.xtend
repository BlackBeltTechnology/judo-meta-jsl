package hu.blackbelt.judo.meta.jsl.generator

import org.eclipse.xtext.generator.IOutputConfigurationProvider
import org.eclipse.xtext.generator.OutputConfiguration
import org.eclipse.xtext.generator.IFileSystemAccess

class JslDslOutputConfigurationProvider implements IOutputConfigurationProvider {

    override getOutputConfigurations() {

        val OutputConfiguration defaultOutput = new OutputConfiguration(IFileSystemAccess.DEFAULT_OUTPUT);
        defaultOutput.setDescription("Output Folder");
        defaultOutput.setOutputDirectory("./diagram");
        defaultOutput.setOverrideExistingResources(true);
        defaultOutput.setCreateOutputDirectory(true);
        defaultOutput.setCleanUpDerivedResources(true);
        defaultOutput.setSetDerivedProperty(true);
        return newHashSet(defaultOutput);
    }

}
