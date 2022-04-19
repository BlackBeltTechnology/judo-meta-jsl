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
import hu.blackbelt.judo.meta.jsl.jsldsl.Expression
import hu.blackbelt.judo.meta.jsl.jsldsl.Self
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationExpression
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionedExpression
import hu.blackbelt.judo.meta.jsl.jsldsl.UnaryOperation
import hu.blackbelt.judo.meta.jsl.jsldsl.BinaryOperation
import hu.blackbelt.judo.meta.jsl.jsldsl.TernaryOperation
import hu.blackbelt.judo.meta.jsl.jsldsl.Declaration
import hu.blackbelt.judo.meta.jsl.jsldsl.DataTypeDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ErrorDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.PrimitiveDeclaration

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
			val members = e.members.filter[m | m !== exclude]
	
			names.addAll(members.filter[m | m instanceof EntityFieldDeclaration].map[m | m as EntityFieldDeclaration].map[m | m.name.toLowerCase].toList)
			names.addAll(members.filter[m | m instanceof EntityIdentifierDeclaration].map[m | m as EntityIdentifierDeclaration].map[m | m.name.toLowerCase].toList)
			names.addAll(members.filter[m | m instanceof EntityRelationDeclaration].map[m | m as EntityRelationDeclaration].map[m | m.name.toLowerCase].toList)
			names.addAll(members.filter[m | m instanceof EntityDerivedDeclaration].map[m | m as EntityDerivedDeclaration].map[m | m.name.toLowerCase].toList)		
		}
		new HashSet(names)
	}
	
	def Collection<String> getDeclarationNames(ModelDeclaration model, Declaration exclude) {
		var names = new ArrayList()
		names.addAll(model.declarations.filter[m | m !== exclude].filter[m | m instanceof PrimitiveDeclaration].map[m | m as PrimitiveDeclaration].map[m | m.name.toLowerCase].toList)
		names.addAll(model.declarations.filter[m | m !== exclude].filter[m | m instanceof ErrorDeclaration].map[m | m as ErrorDeclaration].map[m | m.name.toLowerCase].toList)
		names.addAll(model.declarations.filter[m | m !== exclude].filter[m | m instanceof EntityDeclaration].map[m | m as EntityDeclaration].map[m | m.name.toLowerCase].toList)
		new HashSet(names)
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

	def static isStaticExpression(Expression it) { isStaticExpressionDispatcher }
  
	static def dispatch Boolean isStaticExpressionDispatcher(TernaryOperation it) {
		it !== null 
			? it.condition.staticExpression  || it.thenExpression.staticExpression || it.elseExpression.staticExpression 
			: true
	}

	static def dispatch Boolean isStaticExpressionDispatcher(BinaryOperation it) {
		it !== null 
			? it.leftOperand.staticExpression || it.rightOperand.staticExpression 
			: true
	}

	static def dispatch Boolean isStaticExpressionDispatcher(UnaryOperation it) {
		it !== null 
			? it.operand.staticExpression 
			: true
	}

	static def dispatch Boolean isStaticExpressionDispatcher(FunctionedExpression it) {
		it !== null 
			? it.operand.staticExpression 
			: true
	}

	static def dispatch Boolean isStaticExpressionDispatcher(NavigationExpression it) {
		it !== null 
			? it.base !== null 
				? it.base.staticExpression
				: true
			: true
	}

	static dispatch def Boolean isStaticExpressionDispatcher(Self it) {
		it !== null 
			?  false 
			: true
	}	
	
}