package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.xtext.naming.QualifiedName

class JslDslImportNormalizer extends ImportNormalizer {
	
	final ImportNormalizer aliasNormalizer;
	
	new(String alias, QualifiedName importedNamespace, boolean wildCard, boolean ignoreCase) {
		super(importedNamespace, wildCard, ignoreCase)
		if (alias !== null) {
			aliasNormalizer = new ImportNormalizer(QualifiedName.create(alias), true, false)
		} else {
			aliasNormalizer = null;
		}
	}
	
	override deresolve(QualifiedName fullyQualifiedName) {
		if (aliasNormalizer !== null) {
			if (fullyQualifiedName.equals(aliasNormalizer.importedNamespacePrefix)) {
				return fullyQualifiedName
			}

			if (fullyQualifiedName.startsWith(importedNamespacePrefix)) {
				return aliasNormalizer.importedNamespacePrefix.append(fullyQualifiedName.skipFirst(importedNamespacePrefix.segmentCount));
			}
			
			if (fullyQualifiedName.startsWith(aliasNormalizer.importedNamespacePrefix)) {
				return fullyQualifiedName.skipFirst(aliasNormalizer.importedNamespacePrefix.segmentCount);
			}
			
			return null
		}

		return super.deresolve(fullyQualifiedName)
	}

	override QualifiedName resolve(QualifiedName relativeName) {
		if (relativeName.empty)
			return null;

		if (aliasNormalizer !== null) {
			if (relativeName.equals(aliasNormalizer.importedNamespacePrefix)) {
				return relativeName
			}
			
			if (relativeName.startsWith(aliasNormalizer.importedNamespacePrefix)) {
				return importedNamespacePrefix.append(relativeName.skipFirst(aliasNormalizer.importedNamespacePrefix.segmentCount))
			}
			
			return null
		}
				
		return super.resolve(relativeName)
	}
}