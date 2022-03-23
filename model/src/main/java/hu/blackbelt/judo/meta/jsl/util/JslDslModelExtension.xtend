package hu.blackbelt.judo.meta.jsl.util

import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import java.util.Collection

class JslDslModelExtension {

	def static Collection<ModelDeclaration> modelImportHierarchy(ModelDeclaration modelDeclaration) {
		val visited = <ModelDeclaration>newArrayList()
		var allImports = modelDeclaration.imports

		// visited.add(modelDeclaration)
		for (import : allImports) {
			if (!visited.contains(import.importedModel)) {
				visited.add(import.importedModel);
				if (import.importedModel !== modelDeclaration) {
					for (i : modelImportHierarchy(import.importedModel)) {
						if (!visited.contains(i)) {
							visited.add(i)
						}
					}					
				}
			}
		}		
		visited
	}

}
