package hu.blackbelt.judo.meta.jsl.util

import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.eclipse.emf.ecore.EObject
import com.google.inject.Singleton
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration
import java.util.Collection
import java.util.ArrayList
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration
import java.util.LinkedList
import java.util.Set
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityIdentifierDeclaration
import java.util.HashSet
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDerivedDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityMemberDeclaration

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
	
	def getAllOppositeRelations(EntityRelationDeclaration relation) {
		relation.getAllOppositeRelations(null)
	}

	def getValidOppositeRelations(EntityRelationDeclaration relation) {
		relation.getValidOppositeRelations(null)
	}

	def getValidOppositeRelations(EntityRelationDeclaration relation, Boolean single) {
		relation.type.getAllRelations(single, new LinkedList).filter[r | relation.isSelectableForRelation(r)].toList
	}
	
	def getAllOppositeRelations(EntityRelationDeclaration relation, Boolean single) {
		relation.type.getAllRelations(single, new LinkedList)
	}

	def Collection<EntityRelationDeclaration> getAllRelations(EntityDeclaration entity) {		
		entity.getAllRelations(null, new LinkedList)				
	}

	def Collection<EntityRelationDeclaration> getAllRelations(EntityDeclaration entity, Boolean single) {		
		entity.getAllRelations(single, new LinkedList)		
	}

	def Collection<EntityRelationDeclaration> getAllRelations(EntityDeclaration entity, Boolean single, Collection<EntityRelationDeclaration> visited) {		
		if (entity !== null) {
			visited.addAll(
				entity.members
					.filter[m | m instanceof EntityRelationDeclaration]
					.map[m |m as EntityRelationDeclaration]
					.filter[r | single === null || (single && !r.isMany) || (!single && r.isMany)]
					.toList			
			)

			for (e : entity.extends) {
				e.getAllRelations(single, visited)	
			}
		}
		visited
	}

	def isSelectableForRelation(EntityRelationDeclaration currentRelation, EntityRelationDeclaration selectableRelation) {
		if (currentRelation.opposite === null) {
			return false
		}
		val opposite = currentRelation.opposite
		val oppositeEntity = selectableRelation.eContainer as EntityDeclaration
		
		if (opposite.oppositeType === null) {
			val oppositeEntityAllRelations = oppositeEntity.getAllRelations().toList

			// System.out.println(" --- " + EObjectOrProxy + " --- Rel:  " + opposite.eContainer + " Sib: " + siblings.map[r | r + "=" + r.opposite?.oppositeType].join(", "))
			if (oppositeEntityAllRelations.exists[r | r.opposite?.oppositeType === currentRelation]) {
				if (selectableRelation.opposite?.oppositeType === currentRelation) {
					return true
				} else {
					return false
				}
			} else if (selectableRelation.opposite === null) {
				return true
			}
			return false
		}
		true		
	}
	
	def Set<String> getMemberNames(EntityDeclaration entity, EntityMemberDeclaration exclude) {
		val members = entity.members.filter[m | m !== exclude]

		var names = new ArrayList()
		names.addAll(members.filter[m | m instanceof EntityFieldDeclaration].map[m | m as EntityFieldDeclaration].map[m | m.name].toList)
		names.addAll(members.filter[m | m instanceof EntityIdentifierDeclaration].map[m | m as EntityIdentifierDeclaration].map[m | m.name].toList)
		names.addAll(members.filter[m | m instanceof EntityRelationDeclaration].map[m | m as EntityRelationDeclaration].map[m | m.name].toList)
		names.addAll(members.filter[m | m instanceof EntityDerivedDeclaration].map[m | m as EntityDerivedDeclaration].map[m | m.name].toList)
		
		new HashSet(names)
	}
}