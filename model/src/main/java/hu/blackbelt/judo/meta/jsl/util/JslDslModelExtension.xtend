package hu.blackbelt.judo.meta.jsl.util

import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.eclipse.emf.ecore.EObject
import com.google.inject.Singleton

@Singleton
class JslDslModelExtension {

	// @Inject extension IQualifiedNameProvider
	// @Inject extension IQualifiedNameConverter

	/*
	def Collection<QualifiedName> modelImportHierarchy(ModelDeclaration modelDeclaration, QualifiedName ignoredImport) {
		val visited = <QualifiedName>newArrayList()
		modelImportHierarchy(modelDeclaration, visited, ignoredImport)
		visited
	}


	def void modelImportHierarchy(QualifiedName modelDeclaration, List<QualifiedName> visited, QualifiedName ignoredImport) {
		var allImports = modelDeclaration.imports
		if (visited.contains(modelDeclaration.fullyQualifiedName)) {
			return;
		}
		for (modelImport : allImports) {
			//val String dd = modelImport.importedNamespace
			if ((ignoredImport === null 
				|| !ignoredImport.equals(modelImport.importedNamespace.toQualifiedName))
				&& !visited.contains(modelImport.importedNamespace.toQualifiedName)
			) {
				visited.add(modelImport.importedNamespace.toQualifiedName);
				if (modelImport !== modelDeclaration) {
					val model = modelImport.resolveModel;
					if (model.present) {
						modelImportHierarchy(model.get, visited, null)						
					}
				}
			}
		}
	} */
	
	def ModelDeclaration modelDeclaration(EObject obj) {
		var current = obj
		
		while (current.eContainer !== null) {
			current = current.eContainer
		}
		
		if (current instanceof ModelDeclaration) {
			current as ModelDeclaration
		} else {
			throw new IllegalAccessException("The root container is not ModelDeclaration: " + obj)
		}		
	}
}
