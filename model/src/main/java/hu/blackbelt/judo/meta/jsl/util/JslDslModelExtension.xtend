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
import org.eclipse.xtext.naming.IQualifiedNameProvider
import com.google.inject.Inject;
import hu.blackbelt.judo.meta.jsl.jsldsl.ConstraintDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityFieldSingleType
import java.util.List
import hu.blackbelt.judo.meta.jsl.jsldsl.DataTypeDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumDeclaration
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import hu.blackbelt.judo.meta.jsl.jsldsl.Expression
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDerivedSingleType

@Singleton
class JslDslModelExtension {
	
	@Inject extension IQualifiedNameProvider

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

		model.entityDeclarations.forEach[e | {
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
		relation.referenceType.getAllRelations(single).filter[r | relation.isSelectableForRelation(r)].toList
	}
	
	def getAllOppositeRelations(EntityRelationDeclaration relation, Boolean single) {
		relation.referenceType.getAllRelations(single)
	}

	def Collection<EntityRelationDeclaration> getAllRelations(EntityDeclaration entity) {		
		entity.getAllRelations(null)				
	}

	def Collection<EntityRelationDeclaration> getAllRelations(EntityDeclaration entity, Boolean single) {		
		entity.getAllRelations(single, new LinkedList, new LinkedList)		
	}

	private def Collection<EntityRelationDeclaration> getAllRelations(EntityDeclaration entity, Boolean single, Collection<EntityRelationDeclaration> collected, Collection<EntityDeclaration> visited) {		
		if (entity !== null) {
			visited.add(entity)
			collected.addAll(
				entity.relations
					.filter[r | single === null || (single && !r.isMany) || (!single && r.isMany)]
					.toList			
			)

			for (e : entity.extends) {
				e.getAllRelations(single, collected, visited)	
			}
		}
		collected
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

	def boolean isManyAttributeForEntityMemberDeclaration(EntityMemberDeclaration member) {
		if (member instanceof EntityFieldDeclaration) {
			(member as EntityFieldDeclaration).isIsMany
		} else if (member instanceof EntityIdentifierDeclaration) {
			false
		} else if (member instanceof EntityRelationDeclaration) {
			(member as EntityRelationDeclaration).isIsMany
		} else if (member instanceof EntityDerivedDeclaration) {
			(member as EntityDerivedDeclaration).isIsMany
		} else {
			false
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
			JsldslPackage::eINSTANCE.entityDerivedDeclaration_Name
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


	def String getNameForEntityFieldSingleType(EntityFieldSingleType type) {
		if (type instanceof EntityDeclaration) {
			type.name
		} else if (type instanceof PrimitiveDeclaration) {
			type.name
		} else {
			""
		}
	}

	def String getNameForEntityDerivedSingleType(EntityDerivedSingleType type) {
		if (type instanceof EntityDeclaration) {
			type.name
		} else if (type instanceof PrimitiveDeclaration) {
			type.name
		} else {
			""
		}
	}


	def Collection<String> getDeclarationNames(ModelDeclaration model, Declaration exclude) {
		model.declarations.filter[m | m !== exclude].map[m | m.nameForDeclaration].filter[n | n.trim != ""].toSet
	}


	private def Collection<EntityMemberDeclaration> getAllMembers(EntityDeclaration entity, Collection<EntityMemberDeclaration> collected, Collection<EntityDeclaration> visited) {		
		if (entity !== null && !visited.contains(entity)) {
			visited.add(entity)
			collected.addAll(
				entity.members
					.map[m |m as EntityMemberDeclaration]
					.toList			
			)

			for (e : entity.extends) {
				if (!collected.contains(e)) {
					e.getAllMembers(collected, visited)					
				}
			}
		}
		collected
	}

	def Collection<EntityDeclaration> getSuperEntityTypes(EntityDeclaration entity) {
		getSuperEntityTypes(entity, new LinkedList)
	}

	def Collection<EntityDeclaration> getSuperEntityTypes(EntityDeclaration entity, Collection<EntityDeclaration> collected) {
		for (superEntity : entity.extends) {
			if (!collected.contains(superEntity)) {
				collected.add(superEntity)
				collected.addAll(superEntity.getSuperEntityTypes(collected))
			}
		}
		collected
	}
	
	def String getMemberFullyQualifiedName(EntityMemberDeclaration member) {
		(member.eContainer as EntityDeclaration).fullyQualifiedName.toString("::") + "." + member.nameForEntityMemberDeclaration
	}

	def Collection<EntityMemberDeclaration> getAllMembers(EntityDeclaration entity) {
		entity.getAllMembers(new LinkedList, new LinkedList)
	}

	def EntityDerivedDeclaration getDerivedDeclaration(EObject from) {
		var EntityDerivedDeclaration found = null;
		var EObject current = from;
		while (found === null && current !== null) {
			if (current instanceof EntityDerivedDeclaration) {
				found = current as EntityDerivedDeclaration;
			}
			if (from.eContainer() !== null) {
				current = current.eContainer();
			} else {
				current = null;
			}
		}
		return found;
	}
	
	def Collection<EntityRelationDeclaration> getRelations(EntityDeclaration it) {
		members.filter[m | m instanceof EntityRelationDeclaration].map[d | d as EntityRelationDeclaration].toList
	}
	
	def Collection<EntityDeclaration> entityDeclarations(ModelDeclaration it) {
		declarations.filter[d | d instanceof EntityDeclaration].map[d | d as EntityDeclaration].toList
	}

	def Collection<DataTypeDeclaration> dataTypeDeclarations(ModelDeclaration it) {
		declarations.filter[d | d instanceof DataTypeDeclaration].map[d | d as DataTypeDeclaration].toList
	}

	def Collection<EnumDeclaration> enumDeclarations(ModelDeclaration it) {
		declarations.filter[d | d instanceof EnumDeclaration].map[d | d as EnumDeclaration].toList
	}

	def Collection<ErrorDeclaration> errorDeclarations(ModelDeclaration it) {
		declarations.filter[d | d instanceof ErrorDeclaration].map[d | d as ErrorDeclaration].toList
	}

	def Collection<EntityFieldDeclaration> fields(EntityDeclaration it) {
		members.filter[d | d instanceof EntityFieldDeclaration].map[d | d as EntityFieldDeclaration].toList
	}

	def Collection<EntityDerivedDeclaration> derivedes(EntityDeclaration it) {
		members.filter[d | d instanceof EntityDerivedDeclaration].map[d | d as EntityDerivedDeclaration].toList
	}

	def Collection<ConstraintDeclaration> constraints(EntityDeclaration it) {
		members.filter[d | d instanceof ConstraintDeclaration].map[d | d as ConstraintDeclaration].toList
	}

	def Collection<EntityIdentifierDeclaration> identifiers(EntityDeclaration it) {
		members.filter[d | d instanceof EntityIdentifierDeclaration].map[d | d as EntityIdentifierDeclaration].toList
	}
	
	def String sourceCode(Expression it) {
		return NodeModelUtils.findActualNodeFor(it)?.getText()
	}
  	
	def Collection<EntityRelationDeclaration> getAllRelations(ModelDeclaration it, boolean singleInstanceOfBidirectional) {
		val List<EntityRelationDeclaration> relations = new ArrayList()
		
		for (entity : entityDeclarations) {
			for (relation : entity.relations) {
				if (singleInstanceOfBidirectional && relation.opposite?.oppositeType !== null && !relations.contains(relation.opposite.oppositeType) ||
					relation.opposite?.oppositeType === null
				) {
					relations.add(relation)
				}
			}
		}		
		return relations
	}
	
	def boolean hasOpposite(EntityRelationDeclaration it) {
		opposite?.oppositeType !== null || opposite?.oppositeName !== null
	}
	
	def boolean isRelationExternal(EntityRelationDeclaration it) {
		eContainer.modelDeclaration !== referenceType.modelDeclaration
	}

	
}