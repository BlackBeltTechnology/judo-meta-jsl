package hu.blackbelt.judo.meta.jsl.util

import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.eclipse.emf.ecore.EObject
import com.google.inject.Singleton
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration
import java.util.Collection
import java.util.ArrayList
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration
import java.util.LinkedList
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityIdentifierDeclaration
import java.util.HashSet
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDerivedDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityMemberDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.Declaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ErrorDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.PrimitiveDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import org.eclipse.emf.ecore.EAttribute
import hu.blackbelt.judo.meta.jsl.jsldsl.ConstraintDeclaration

@Singleton
class JslDslModelExtension {
	
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

	def Collection<EntityMemberDeclaration> allEntityMemberDeclarations(ModelDeclaration model) {
		val res = new ArrayList<EntityMemberDeclaration>();

		model.declarations.filter[d | d instanceof EntityDeclaration].map[d | d as EntityDeclaration].forEach[e | {
			res.addAll(e.members.filter[m | !(m instanceof ConstraintDeclaration)])
		}]
		return res
	}
	
	def getAllOppositeRelations(EntityRelationDeclaration relation) {
		relation.getAllOppositeRelations(null)
	}

	def getValidOppositeRelations(EntityRelationDeclaration relation) {
		relation.getValidOppositeRelations(null)
	}

	def getValidOppositeRelations(EntityRelationDeclaration relation, Boolean single) {
		relation.referenceType.getAllRelations(single, new LinkedList).filter[r | relation.isSelectableForRelation(r)].toList
	}
	
	def getAllOppositeRelations(EntityRelationDeclaration relation, Boolean single) {
		relation.referenceType.getAllRelations(single, new LinkedList)
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

	def Collection<String> getMemberNames(EntityDeclaration entity) {
		entity.getMemberNames(null)
	}
		
	def Collection<String> getMemberNames(EntityDeclaration entity, EntityMemberDeclaration exclude) {
		var names = new ArrayList()
		val allEntitiesInInheritenceChain = new HashSet
		allEntitiesInInheritenceChain.add(entity)
		allEntitiesInInheritenceChain.addAll(entity.superEntityTypes)		
		for (e : allEntitiesInInheritenceChain) {
			names.addAll(e.members.filter[m | m !== exclude].map[m | m.nameForEntityMemberDeclaration].filter[n | n.trim != ""].toList)
		}
		new HashSet(names)
	}

	def String getNameForEntityMemberDeclaration(EntityMemberDeclaration member) {
		if (member instanceof EntityFieldDeclaration) {
			member.name
		} else if (member instanceof EntityIdentifierDeclaration) {
			member.name
		} else if (member instanceof EntityRelationDeclaration) {
			member.name
		} else if (member instanceof EntityDerivedDeclaration) {
			member.name
		} else {
			""
		}
	}

	def EAttribute getNameAttributeForEntityMemberDeclaration(EntityMemberDeclaration member) {
		if (member instanceof EntityFieldDeclaration) {
			JsldslPackage::eINSTANCE.entityFieldDeclaration_Name
		} else if (member instanceof EntityIdentifierDeclaration) {
			JsldslPackage::eINSTANCE.entityIdentifierDeclaration_Name
		} else if (member instanceof EntityRelationDeclaration) {
			JsldslPackage::eINSTANCE.entityRelationDeclaration_Name
		} else if (member instanceof EntityDerivedDeclaration) {
			JsldslPackage::eINSTANCE.entityDeclaration_Name
		} else {
			throw new IllegalArgumentException("Unknown EntityMemberDeclaration: " + member)
		}
	}

	def String getNameForDeclaration(Declaration declaration) {
		if (declaration instanceof PrimitiveDeclaration) {
			declaration.name
		} else if (declaration instanceof ErrorDeclaration) {
			declaration.name
		} else if (declaration instanceof EntityDeclaration) {
			declaration.name
		} else {
			""
		}
	}

	def EAttribute getNameAttributeForDeclaration(Declaration declaration) {
		if (declaration instanceof PrimitiveDeclaration) {
			JsldslPackage::eINSTANCE.primitiveDeclaration_Name
		} else if (declaration instanceof ErrorDeclaration) {
			JsldslPackage::eINSTANCE.errorDeclaration_Name
		} else if (declaration instanceof EntityDeclaration) {
			JsldslPackage::eINSTANCE.entityDeclaration_Name
		} else {
			throw new IllegalArgumentException("Unknown Declaration: " + declaration)
		}
	}

	
	def Collection<String> getDeclarationNames(ModelDeclaration model, Declaration exclude) {
		model.declarations.filter[m | m !== exclude].map[m | m.nameForDeclaration].filter[n | n.trim != ""].toSet
	}

	
	def Collection<EntityMemberDeclaration> getAllMembers(EntityDeclaration entity, Collection<EntityMemberDeclaration> visited) {		
		if (entity !== null) {
			visited.addAll(
				entity.members
					.map[m |m as EntityMemberDeclaration]
					.toList			
			)

			for (e : entity.extends) {
				e.getAllMembers(visited)	
			}
		}
		visited
	}

	def Collection<EntityDeclaration> getSuperEntityTypes(EntityDeclaration entity) {
		getSuperEntityTypes(entity, new LinkedList)
	}

	def Collection<EntityDeclaration> getSuperEntityTypes(EntityDeclaration entity, Collection<EntityDeclaration> visited) {
		for (superEntity : entity.extends) {
			if (!visited.contains(superEntity)) {
				visited.add(superEntity)
				visited.addAll(superEntity.getSuperEntityTypes(visited))
			}
		}
		visited
	}
	
}