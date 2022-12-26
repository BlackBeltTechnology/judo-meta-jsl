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
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.xtext.naming.IQualifiedNameProvider
import com.google.inject.Inject;
import hu.blackbelt.judo.meta.jsl.jsldsl.ConstraintDeclaration
import java.util.List
import hu.blackbelt.judo.meta.jsl.jsldsl.DataTypeDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumDeclaration
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import hu.blackbelt.judo.meta.jsl.jsldsl.Expression
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityQueryDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.Named
import hu.blackbelt.judo.meta.jsl.jsldsl.Cardinality
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeReferenced
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOpposite
import hu.blackbelt.judo.meta.jsl.jsldsl.RawStringLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.EscapedStringLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.ModifierMaxFileSize
import java.math.BigInteger
import hu.blackbelt.judo.meta.jsl.jsldsl.support.JslDslModelResourceSupport
import java.util.stream.Collectors
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaDeclaration
import org.eclipse.emf.ecore.util.EcoreUtil
import hu.blackbelt.judo.meta.jsl.jsldsl.StringLiteral

@Singleton
class JslDslModelExtension {
	
	@Inject extension IQualifiedNameProvider	

	def isEqual(EObject it, EObject other) {
		if (it.equals(other))
			return true;
		if (EcoreUtil.getURI(it).equals(EcoreUtil.getURI(other)))
			return true;

		return false;
	}

	def isResolvedReference(EObject it, int featureID) {
		val EObject featureObject = it.eGet(it.eClass().getEStructuralFeature(featureID), false) as EObject;
		return !featureObject.eIsProxy();
	}

	/*
	def ModelDeclaration modelDeclaration(EObject obj) {
		var current = obj
		
		while (current.eContainer !== null) {
			current = current.eContainer
		}
		
		if (current instanceof ModelDeclaration) {
			current as ModelDeclaration
		} else {
			throw new IllegalAccessException("The root container is not ModelDeclaration: " + obj + "\n Root: " + current)
		}		
	} */

	def Collection<EntityMemberDeclaration> allNamedEntityMemberDeclarations(ModelDeclaration model) {
		val res = new ArrayList<EntityMemberDeclaration>();

		model.entityDeclarations.forEach[e | {
			res.addAll(e.members.filter[m | m instanceof Named])
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

    def asEntityRelationOppositeReferenced(EntityRelationOpposite it) {
    	if (it instanceof EntityRelationOppositeReferenced) {
    		return it as EntityRelationOppositeReferenced
    	}
    	return null as EntityRelationOppositeReferenced
    }

    def oppositeType(EntityRelationOpposite it) {
    	return asEntityRelationOppositeReferenced?.oppositeType
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
			names.addAll(e.members.filter[m | m !== exclude].filter[m | m instanceof Named].map[m | m.name].filter[n | n.trim != ""].toList)
		}
		new HashSet(names)
	}

 	def boolean isMany(EObject object) {
 		if (object === null) {
 			return false;
 		}
		if (object instanceof Cardinality) {
			object.isIsMany
		} else {
			throw new IllegalArgumentException("Object is not Cardinality: " + object)
		}
	}

	def String getName(EObject object) {
		if (object === null) {
			return null
		}
		if (object instanceof Named) {
			return object.name
		} else {
			""
			//throw new IllegalArgumentException("Object is not Named: " + object)
		}
	}

	def EAttribute getNameAttribute(EObject object) {
		if (object instanceof Named) {
			JsldslPackage::eINSTANCE.named_Name
		} else {
			throw new IllegalArgumentException("Object is not Named: " + object)
		}
	}

	def Collection<String> getDeclarationNames(ModelDeclaration model, Declaration exclude) {
		model.declarations.filter[m | m !== exclude && !(m instanceof FunctionDeclaration) && !(m instanceof LambdaDeclaration)].map[m | m.name].filter[n | n.trim != ""].toSet
	}


	private def Collection<EntityMemberDeclaration> getAllMembers(EntityDeclaration entity, Collection<EntityMemberDeclaration> collected, Collection<EntityDeclaration> visited) {		
		if (entity !== null && !visited.contains(entity)) {
			visited.add(entity)
			collected.addAll(
				entity.members
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
		(member.eContainer as EntityDeclaration).fullyQualifiedName.toString("::") + "." + member.name
	}

	def Collection<EntityMemberDeclaration> getAllMembers(EntityDeclaration entity) {
		entity.getAllMembers(new LinkedList, new LinkedList)
	}


    def <T> T parentContainer(EObject from, Class<T> type) {
        var T found = null;
        var EObject current = from;
        while (found === null && current !== null) {
            if (type.isAssignableFrom(current.getClass())) {
                found = current as T;
            }
            if (current.eContainer !== null) {
                current = (current as EObject).eContainer;
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

	def Collection<QueryDeclaration> queryDeclarations(ModelDeclaration it) {
		declarations.filter[d | d instanceof QueryDeclaration].map[d | d as QueryDeclaration].toList
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

	def Collection<EntityQueryDeclaration> queries(EntityDeclaration it) {
		members.filter[d | d instanceof EntityQueryDeclaration].map[d | d as EntityQueryDeclaration].toList
	}

	def Collection<ConstraintDeclaration> constraints(EntityDeclaration it) {
		members.filter[d | d instanceof ConstraintDeclaration].map[d | d as ConstraintDeclaration].toList
	}

	def Collection<EntityIdentifierDeclaration> identifiers(EntityDeclaration it) {
		members.filter[d | d instanceof EntityIdentifierDeclaration].map[d | d as EntityIdentifierDeclaration].toList
	}

	def Collection<EntityFieldDeclaration> allFields(EntityDeclaration it) {
		allMembers.filter[d | d instanceof EntityFieldDeclaration].map[d | d as EntityFieldDeclaration].toList
	}

	def Collection<EntityDerivedDeclaration> allDerivedes(EntityDeclaration it) {
		allMembers.filter[d | d instanceof EntityDerivedDeclaration].map[d | d as EntityDerivedDeclaration].toList
	}

	def Collection<EntityQueryDeclaration> allQueries(EntityDeclaration it) {
		allMembers.filter[d | d instanceof EntityQueryDeclaration].map[d | d as EntityQueryDeclaration].toList
	}

	def Collection<ConstraintDeclaration> allConstraints(EntityDeclaration it) {
		allMembers.filter[d | d instanceof ConstraintDeclaration].map[d | d as ConstraintDeclaration].toList
	}

	def Collection<EntityIdentifierDeclaration> allIdentifiers(EntityDeclaration it) {
		allMembers.filter[d | d instanceof EntityIdentifierDeclaration].map[d | d as EntityIdentifierDeclaration].toList
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
	
    def Collection<EnumDeclaration> allEnumDeclarations(ModelDeclaration model) {
		model.declarations.filter[d | d instanceof EnumDeclaration].map[e | e as EnumDeclaration].toList
	}

    def Collection<EnumDeclaration> allQueryDeclarations(ModelDeclaration model) {
		model.declarations.filter[d | d instanceof QueryDeclaration].map[e | e as EnumDeclaration].toList
	}
	
	def String getStringLiteralValue(StringLiteral it) {
		switch it {
			RawStringLiteral: return it.value
			EscapedStringLiteral: return it.value
		}
	}

	def BigInteger getMaxFileSizeValue(ModifierMaxFileSize it) {
		switch it.unit.literal {
			case "kB": return it.numeric.multiply(BigInteger.valueOf(1000))
			case "MB": return it.numeric.multiply(BigInteger.valueOf(1000 * 1000))
			case "GB": return it.numeric.multiply(BigInteger.valueOf(1000 * 1000 * 1000))

			case "KiB": return it.numeric.multiply(BigInteger.valueOf(1024))
			case "MiB": return it.numeric.multiply(BigInteger.valueOf(1024 * 1024))
			case "GiB": return it.numeric.multiply(BigInteger.valueOf(1024 * 1024 * 1024))
		}
		return it.numeric
	}


	def JslDslModelResourceSupport fromModel(ModelDeclaration model) {
		val JslDslModelResourceSupport jslDslModelResourceSupport = JslDslModelResourceSupport.jslDslModelResourceSupportBuilder().resourceSet(model.eResource.getResourceSet()).build();
		EcoreUtil.resolveAll(jslDslModelResourceSupport.resourceSet)
		return jslDslModelResourceSupport
	}

	def Collection<EntityDeclaration> entities(JslDslModelResourceSupport it) {
		getStreamOf(EntityDeclaration).collect(Collectors.toList)		
	}

	
	def EntityDeclaration entityByName(JslDslModelResourceSupport it, String name) {
		return getStreamOf(EntityDeclaration).filter[e | e.name.equals(name)].findFirst.orElseThrow[new IllegalArgumentException("EntityDeclaration not found: " + name)]
	}

	
	def QueryDeclaration queryByName(JslDslModelResourceSupport it, String name) {
		return getStreamOf(QueryDeclaration).filter[e | e.name.equals(name)].findFirst.orElseThrow[new IllegalArgumentException("QueryDeclaration not found: " + name)]
	}

	def EntityMemberDeclaration memberByName(EntityDeclaration it, String name) {
		members.stream.filter[e | e.name.equals(name)].findFirst.orElseThrow[new IllegalArgumentException("EntityMemberDeclaration not found: " + name)]
	}

}
