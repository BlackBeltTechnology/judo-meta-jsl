package hu.blackbelt.judo.meta.jsl.util

import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.eclipse.emf.ecore.EObject
import com.google.inject.Singleton
import java.util.Collection
import java.util.ArrayList
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration
import java.util.LinkedList
import java.util.HashSet
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
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.AnnotationDeclaration
//import hu.blackbelt.judo.meta.jsl.jsldsl.ServiceDeclaration
//import hu.blackbelt.judo.meta.jsl.jsldsl.ServiceDataDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityStoredRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityStoredFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityCalculatedMemberDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.SingleType
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityCalculatedFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityCalculatedRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorAccessDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorMenuDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewTableDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewLinkDeclaration

@Singleton
class JslDslModelExtension {

    @Inject extension IQualifiedNameProvider

    def isEqual(EObject it, EObject other) {
        if (it === null || other === null) {
            return false;
        }

        if (it.equals(other))
            return true;
        if (EcoreUtil.getURI(it).equals(EcoreUtil.getURI(other)))
            return true;

        return false;
    }

    def isResolvedReference(EObject it, int featureID) {
        val EObject featureObject = it.eGet(it.eClass().getEStructuralFeature(featureID), false) as EObject;
        return featureObject !== null && !featureObject.eIsProxy();
    }

	def SingleType getReferenceType(EntityMemberDeclaration member) { 
		if (member instanceof EntityStoredFieldDeclaration) {
			if ((member as EntityStoredFieldDeclaration).primitiveReferenceType !== null) {
				return (member as EntityStoredFieldDeclaration).primitiveReferenceType;
			} if ((member as EntityStoredFieldDeclaration).entityReferenceType !== null) {
				return (member as EntityStoredFieldDeclaration).entityReferenceType;
			} else {
				return (member as EntityStoredFieldDeclaration).singleReferenceType;
			}
		} else if (member instanceof EntityStoredRelationDeclaration) {
			return (member as EntityStoredRelationDeclaration).entityReferenceType;
		} else if (member instanceof EntityCalculatedFieldDeclaration) {
			return (member as EntityCalculatedFieldDeclaration).primitiveReferenceType;
		} else if (member instanceof EntityCalculatedRelationDeclaration) {
			return (member as EntityCalculatedRelationDeclaration).entityReferenceType;
		}
	}

	def TransferDeclaration getReferenceType(TransferRelationDeclaration relation) { 
		if (relation instanceof ActorMenuDeclaration) {
			if ((relation as ActorMenuDeclaration).rowReferenceType !== null) {
				return (relation as ActorMenuDeclaration).rowReferenceType
			}
			return (relation as ActorMenuDeclaration).viewReferenceType;
		} else if (relation instanceof ActorAccessDeclaration) {
			return (relation as ActorAccessDeclaration).transferReferenceType;
		} else if (relation instanceof ViewTableDeclaration) {
			return (relation as ViewTableDeclaration).rowReferenceType;
		} if (relation instanceof ViewLinkDeclaration) {
			return (relation as ViewLinkDeclaration).viewReferenceType;
		} 
		
		return relation.simpleTransferReferenceType;
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

    def getAllOppositeRelations(EntityStoredRelationDeclaration relation) {
        relation.getAllOppositeRelations(null)
    }

    def getValidOppositeRelations(EntityStoredRelationDeclaration relation) {
        relation.getValidOppositeRelations(null)
    }

    def getValidOppositeRelations(EntityStoredRelationDeclaration relation, Boolean single) {
        (relation.referenceType as EntityDeclaration).getAllRelations(single).filter[r | relation.isSelectableForRelation(r)].toList
    }

    def getAllOppositeRelations(EntityStoredRelationDeclaration relation, Boolean single) {
        (relation.referenceType as EntityDeclaration).getAllRelations(single)
    }

    def Collection<EntityStoredRelationDeclaration> getAllRelations(EntityDeclaration entity) {
        entity.getAllRelations(null)
    }

    def Collection<EntityStoredRelationDeclaration> getAllRelations(EntityDeclaration entity, Boolean single) {
        entity.getAllRelations(single, new LinkedList, new LinkedList)
    }

    private def Collection<EntityStoredRelationDeclaration> getAllRelations(EntityDeclaration entity, Boolean single, Collection<EntityStoredRelationDeclaration> collected, Collection<EntityDeclaration> visited) {
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

    def isSelectableForRelation(EntityStoredRelationDeclaration currentRelation, EntityStoredRelationDeclaration selectableRelation) {    	
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
            object.isMany
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

    def Collection<EntityStoredRelationDeclaration> getRelations(EntityDeclaration it) {
        members.filter[m | m instanceof EntityStoredRelationDeclaration].map[d | d as EntityStoredRelationDeclaration].toList
    }

    def Collection<EntityCalculatedRelationDeclaration> getCalculatedRelations(EntityDeclaration it) {
        members.filter[m | m instanceof EntityCalculatedRelationDeclaration].map[d | d as EntityCalculatedRelationDeclaration].toList
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

    def Collection<EntityStoredFieldDeclaration> fields(EntityDeclaration it) {
        members.filter[d | d instanceof EntityStoredFieldDeclaration].map[d | d as EntityStoredFieldDeclaration].toList
    }

    def Collection<EntityCalculatedMemberDeclaration> derivedes(EntityDeclaration it) {
        members.filter[d | d instanceof EntityCalculatedMemberDeclaration].map[d | d as EntityCalculatedMemberDeclaration].toList
    }

//    def Collection<EntityQueryDeclaration> queries(EntityDeclaration it) {
//        members.filter[d | d instanceof EntityQueryDeclaration].map[d | d as EntityQueryDeclaration].toList
//    }

    def Collection<ConstraintDeclaration> constraints(EntityDeclaration it) {
        members.filter[d | d instanceof ConstraintDeclaration].map[d | d as ConstraintDeclaration].toList
    }

//    def Collection<EntityIdentifierDeclaration> identifiers(EntityDeclaration it) {
//        members.filter[d | d instanceof EntityIdentifierDeclaration].map[d | d as EntityIdentifierDeclaration].toList
//    }

    def Collection<EntityStoredFieldDeclaration> allFields(EntityDeclaration it) {
        allMembers.filter[d | d instanceof EntityStoredFieldDeclaration].map[d | d as EntityStoredFieldDeclaration].toList
    }

//    def Collection<EntityDerivedDeclaration> allDerivedes(EntityDeclaration it) {
//        allMembers.filter[d | d instanceof EntityDerivedDeclaration].map[d | d as EntityDerivedDeclaration].toList
//    }

//    def Collection<EntityQueryDeclaration> allQueries(EntityDeclaration it) {
//        allMembers.filter[d | d instanceof EntityQueryDeclaration].map[d | d as EntityQueryDeclaration].toList
//    }

    def Collection<ConstraintDeclaration> allConstraints(EntityDeclaration it) {
        allMembers.filter[d | d instanceof ConstraintDeclaration].map[d | d as ConstraintDeclaration].toList
    }

//    def Collection<EntityIdentifierDeclaration> allIdentifiers(EntityDeclaration it) {
//        allMembers.filter[d | d instanceof EntityIdentifierDeclaration].map[d | d as EntityIdentifierDeclaration].toList
//    }
    
    def Collection<AnnotationDeclaration> annotationDeclarations(ModelDeclaration it) {
        declarations.filter[d | d instanceof AnnotationDeclaration].map[d | d as AnnotationDeclaration].toList
    }
    
    def Collection<TransferDeclaration> transferDeclarations(ModelDeclaration it) {
        declarations.filter[d | d instanceof TransferDeclaration].map[d | d as TransferDeclaration].toList
    }
    
    def Collection<TransferFieldDeclaration> fields(TransferDeclaration it) {
        members.filter[d | d instanceof TransferFieldDeclaration].map[d | d as TransferFieldDeclaration].toList
    }

//	def Collection<ServiceDeclaration> serviceDeclarations(ModelDeclaration it) {
//        declarations.filter[d | d instanceof ServiceDeclaration].map[d | d as ServiceDeclaration].toList
//    }
//    
//    def Collection<ServiceDataDeclaration> dataDeclarationsForService(ServiceDeclaration it) {
//        it.members.filter[m | m instanceof ServiceDataDeclaration].map[m | m as ServiceDataDeclaration].toList 
//    }
//    
//    def Collection<ServiceFunctionDeclaration> functionDeclarationsForService(ServiceDeclaration it) {
//        it.members.filter[m | m instanceof ServiceFunctionDeclaration].map[m | m as ServiceFunctionDeclaration].toList 
//    }
    
    def Collection<ActorDeclaration> actorDeclarations(ModelDeclaration it) {
        it.declarations.filter[m | m instanceof ActorDeclaration].map[m | m as ActorDeclaration].toList 
    }

    def String sourceCode(Expression it) {
        return NodeModelUtils.findActualNodeFor(it)?.getText()
    }

    def Collection<EntityStoredRelationDeclaration> getAllRelations(ModelDeclaration it, boolean singleInstanceOfBidirectional) {
        val List<EntityStoredRelationDeclaration> relations = new ArrayList()

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

    def Collection<TransferRelationDeclaration> getAllTransferRelations(ModelDeclaration it) {
    	return eAllContents.filter[c | c instanceof TransferRelationDeclaration].map[e | e as TransferRelationDeclaration].toList
//        val List<TransferRelationDeclaration> relations = new ArrayList()
//
//        for (transfer : transferDeclarations) {
//            for (relation : transfer.eContents.filter[c | c instanceof TransferRelationDeclaration].toList) {
//                if (singleInstanceOfBidirectional && relation.opposite?.oppositeType !== null && !relations.contains(relation.opposite.oppositeType) ||
//                    relation.opposite?.oppositeType === null
//                ) {
//                    relations.add(relation)
//                }
//            }
//        }
//        return relations
    }

    def Collection<EntityCalculatedRelationDeclaration> getAllCalculatedRelations(ModelDeclaration it, boolean singleInstanceOfBidirectional) {
        val List<EntityCalculatedRelationDeclaration> relations = new ArrayList()

        for (entity : entityDeclarations) {
            for (relation : entity.calculatedRelations) {
            	relations.add(relation)
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
        switch it.measure {
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

    def Collection<TransferDeclaration> transfers(JslDslModelResourceSupport it) {
        getStreamOf(TransferDeclaration).collect(Collectors.toList)
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
