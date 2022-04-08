package hu.blackbelt.judo.meta.jsl.util

import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.eclipse.emf.ecore.EObject
import com.google.inject.Singleton
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration
import java.util.Collection
import java.util.ArrayList
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration
import java.util.LinkedList

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
	


	def getReferableOppositeTypes(EntityRelationDeclaration relation) {
		relation.getReferableOppositeTypes(null)
	}
	
	def getReferableOppositeTypes(EntityRelationDeclaration relation, Boolean single) {
		val selectableRelatations = relation.type.getReferableOppositeTypes(single, new LinkedList, relation)
//		if (relation.opposite !== null && relation.opposite.oppositeType !== null) {
//			// val ret = selectableRelatations.filter[r | r.name === relation.opposite.oppositeType.name ].toList			
//			System.out.println("------- SCOPE FOUND ----------- -> ")			
////			return ret
//		}
		/*
		val currentRelationReferencedRelations = selectableRelatations.filter[r | r.opposite !== null && 
			r.opposite.oppositeType !== null && 
			r.opposite.oppositeType.name === relation.name
		].toList
		if (!currentRelationReferencedRelations.empty) {
			currentRelationReferencedRelations
		} else {
			selectableRelatations
		} */
		selectableRelatations
	}


	def Collection<EntityRelationDeclaration> getReferableOppositeTypes(EntityDeclaration entity, Boolean single, Collection<EntityRelationDeclaration> visited, EntityRelationDeclaration original) {		
		if (entity !== null) {
			visited.addAll(
				entity.members
					.filter[m | m instanceof EntityRelationDeclaration]
					.map[m |m as EntityRelationDeclaration]
//					.filter[r | r.opposite === null || (original !== null && r.opposite.oppositeType !== null && r.opposite.oppositeType.name === original.name)]
					.filter[r | single === null || (single && !r.isMany) || (!single && r.isMany)]
					.toList			
			)

			for (e : entity.extends) {
				e.getReferableOppositeTypes(single, visited, original)	
			}
		}
		visited
	}
}