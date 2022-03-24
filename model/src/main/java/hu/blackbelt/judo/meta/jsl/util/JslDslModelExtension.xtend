package hu.blackbelt.judo.meta.jsl.util

import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import java.util.Collection
import java.util.List

class JslDslModelExtension {

	def static Collection<ModelDeclaration> modelImportHierarchy(ModelDeclaration modelDeclaration) {
		val visited = <ModelDeclaration>newArrayList()
		modelImportHierarchy(modelDeclaration, visited)
		visited
	}


	def static void modelImportHierarchy(ModelDeclaration modelDeclaration, List<ModelDeclaration> visited) {
		var allImports = modelDeclaration.imports
		if (visited.contains(modelDeclaration)) {
			return;
		}

		for (import : allImports) {
			if (!visited.contains(import.importedModel)) {
				visited.add(import.importedModel);
				if (import.importedModel !== modelDeclaration) {
					modelImportHierarchy(import.importedModel, visited)
				}
			}
		}		
	}

}
