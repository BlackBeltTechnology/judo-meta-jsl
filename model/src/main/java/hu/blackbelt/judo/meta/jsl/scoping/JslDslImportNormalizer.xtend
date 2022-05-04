package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.xtext.naming.QualifiedName
import org.slf4j.Logger
import org.slf4j.LoggerFactory

class JslDslImportNormalizer extends ImportNormalizer {

	Logger log = LoggerFactory.getLogger(JslDslImportNormalizer);
		
	final ImportNormalizer aliasNormalizer;
	
	new(String alias, QualifiedName importedNamespace, boolean wildCard, boolean ignoreCase) {
		super(importedNamespace, wildCard, ignoreCase)
		if (alias !== null) {
			aliasNormalizer = new ImportNormalizer(QualifiedName.create(alias), true, false)
		} else {
			aliasNormalizer = null;
		}
	}
	
	override resolve(QualifiedName relativeName) {
		var name = relativeName;
		if (aliasNormalizer !== null) {
			name = aliasNormalizer.deresolve(relativeName)
		}
		if (name === null) {
			name = relativeName
		}
		val resolved = super.resolve(name)		
		
		log.debug("JslDslImportNormalizer.resolve: " + relativeName.toString("::") + " -> " + resolved.toString("::"));
		resolved
	}
	
	override deresolve(QualifiedName fullyQualifiedName) {
		val name = super.deresolve(fullyQualifiedName);
		var deresolved = name
		if (aliasNormalizer !== null && name !== null) {
			deresolved = aliasNormalizer.resolve(name)
		}
		if (deresolved === null) {
			deresolved = fullyQualifiedName
		}
		log.debug("JslDslImportNormalizer.deresolve: " + fullyQualifiedName.toString("::") + " -> " + deresolved.toString("::"));
		deresolved
	}
	
}