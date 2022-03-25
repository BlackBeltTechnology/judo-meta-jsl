package hu.blackbelt.judo.meta.jsl.util

import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import java.util.Collection
import java.util.List
import org.eclipse.emf.ecore.EObject
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelImport
import java.util.Optional
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.naming.IQualifiedNameConverter
import com.google.inject.Inject
import com.google.inject.Singleton
import org.eclipse.xtext.naming.QualifiedName

@Singleton
class JslDslModelExtension {

	@Inject extension IQualifiedNameProvider
	@Inject extension IQualifiedNameConverter

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

	
	def Optional<ModelDeclaration> resolveModel(ModelImport modelImport) {
		if (modelImport.importedNamespace === null || modelImport.importedNamespace.trim === "") {
			return Optional.empty
		}
		val importQualifiedName = modelImport.importedNamespace.toQualifiedName
		var ModelDeclaration ret = null;
    	for (r : modelImport.eContainer.eResource.resourceSet.resources) {
    		val root = r.getContents().get(0)

			System.out.println("- Scan resource: " + root)
    		if (root.fullyQualifiedName.equals(importQualifiedName) 
    			&& root instanceof ModelDeclaration
    		) { 
    			ret = root as ModelDeclaration
    			System.out.println("Model found: " + root.fullyQualifiedName.toString("::"))
			}
		}
		return Optional.ofNullable(ret)		
	}

}
