package hu.blackbelt.judo.meta.jsl.util

import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.eclipse.emf.ecore.EObject
import com.google.inject.Singleton
import java.util.Collection
import java.util.ArrayList
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration
import java.util.LinkedList
import java.util.HashSet
import java.util.HashMap
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityMemberDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.Declaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ErrorDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.xtext.naming.IQualifiedNameProvider
import com.google.inject.Inject;
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
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferMemberDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.RowDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.Feature
import hu.blackbelt.judo.meta.jsl.jsldsl.MemberReference
import hu.blackbelt.judo.meta.jsl.jsldsl.MaxFileSizeModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityFieldDeclaration
import org.eclipse.emf.ecore.EClassifier
import hu.blackbelt.judo.meta.jsl.jsldsl.Modifiable
import hu.blackbelt.judo.meta.jsl.jsldsl.Modifier
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferDataDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EagerModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.DefaultModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.Navigation
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationBaseDeclarationReference
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityMapDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationTarget
import hu.blackbelt.judo.meta.jsl.jsldsl.RequiredModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.BooleanLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.AbstractModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferEventDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.OnModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.HumanModifier

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

	def Collection<TransferMemberDeclaration> getMembers(TransferDeclaration transfer) {
		return transfer.eAllContents.filter[c | c instanceof TransferMemberDeclaration].map[e | e as TransferMemberDeclaration].toList
	}

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
        (relation.referenceType as EntityDeclaration).getAllStoredRelations(single).filter[r | relation.isSelectableForRelation(r)].toList
    }

    def getAllOppositeRelations(EntityRelationDeclaration relation, Boolean single) {
        (relation.referenceType as EntityDeclaration).getAllStoredRelations(single)
    }

    def Collection<EntityRelationDeclaration> getAllStoredRelations(EntityDeclaration entity) {
        entity.getAllStoredRelations(null)
    }

    def Collection<EntityRelationDeclaration> getAllStoredRelations(EntityDeclaration entity, Boolean single) {
        entity.getAllStoredRelations(single, new LinkedList, new LinkedList)
    }

    private def Collection<EntityRelationDeclaration> getAllStoredRelations(EntityDeclaration entity, Boolean single, Collection<EntityRelationDeclaration> collected, Collection<EntityDeclaration> visited) {
        if (entity !== null) {
            visited.add(entity)
            collected.addAll(
                entity.storedRelations
                    .filter[r | single === null || (single && !r.isMany) || (!single && r.isMany)]
                    .toList
            )

            for (e : entity.extends) {
                e.getAllStoredRelations(single, collected, visited)
            }
        }
        collected
    }

	def opposite(EntityRelationDeclaration it) {
		it.getModifier(JsldslPackage::eINSTANCE.entityRelationOpposite) as EntityRelationOpposite
	}

	def isCalculated(EntityMemberDeclaration it) {
		it.getterExpr !== null
	}

	def defaultExpr(EntityMemberDeclaration it) {
		return (it.getModifier(JsldslPackage::eINSTANCE.defaultModifier) as DefaultModifier)?.expression
	}

	def isReads(TransferDataDeclaration it) {
		return it.getterExpr !== null && it.mappedMember === null
	}

	def isMaps(TransferDataDeclaration it) {
		return it.getterExpr !== null && it.mappedMember !== null
	}

    def NavigationTarget getMappedMember(TransferDataDeclaration member) {
        if (!(member.getterExpr instanceof Navigation)) {
            return null;
        }

        val Navigation navigation = member.getterExpr as Navigation;

        if (!(navigation.base instanceof NavigationBaseDeclarationReference)) {
            return null;
        }

        val NavigationBaseDeclarationReference navigationBaseDeclarationReference = navigation.base as NavigationBaseDeclarationReference;

        if (!(navigationBaseDeclarationReference.reference instanceof EntityMapDeclaration)) {
            return null;
        }

        if (navigation.features.size() != 1) {
            return null;
        }

        if (!(navigation.features.get(0) instanceof MemberReference)) {
            return null;
        }
		
		val NavigationTarget navigationTarget = (navigation.features.get(0) as MemberReference).member
		
		if (navigationTarget instanceof EntityRelationOpposite) {
			return navigationTarget
		}

		if (navigationTarget instanceof EntityMemberDeclaration) {
			val EntityMemberDeclaration entityMember = navigationTarget as EntityMemberDeclaration
			
			if (!entityMember.calculated) {
				return navigationTarget
			}
		}
		
        return null
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
    	if (currentRelation.calculated || selectableRelation.calculated) return false
    	
        if (currentRelation.opposite === null) {
            return false
        }
        val opposite = currentRelation.opposite
        val oppositeEntity = selectableRelation.eContainer as EntityDeclaration

        if (opposite.oppositeType === null) {
            val oppositeEntityAllRelations = oppositeEntity.getAllStoredRelations().toList

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

    def Collection<EntityRelationDeclaration> getStoredRelations(EntityDeclaration it) {
        members.filter[m | m instanceof EntityRelationDeclaration && !m.calculated].map[d | d as EntityRelationDeclaration].toList
    }

    def Collection<EntityRelationDeclaration> getCalculatedRelations(EntityDeclaration it) {
        members.filter[m | m instanceof EntityRelationDeclaration && m.calculated].map[d | d as EntityRelationDeclaration].toList
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

    def Collection<EntityFieldDeclaration> getFields(EntityDeclaration it) {
        members.filter[d | d instanceof EntityFieldDeclaration].map[d | d as EntityFieldDeclaration].toList
    }

    def Collection<EntityFieldDeclaration> getStoredFields(EntityDeclaration it) {
        members.filter[d | d instanceof EntityFieldDeclaration && !d.calculated].map[d | d as EntityFieldDeclaration].toList
    }

    def Collection<EntityMemberDeclaration> getCalculatedMembers(EntityDeclaration it) {
        members.filter[d | d.calculated].toList
    }

//    def Collection<ConstraintDeclaration> constraints(EntityDeclaration it) {
//        members.filter[d | d instanceof ConstraintDeclaration].map[d | d as ConstraintDeclaration].toList
//    }

    def Collection<EntityFieldDeclaration> getAllStoredFields(EntityDeclaration it) {
        allMembers.filter[d | d instanceof EntityFieldDeclaration && !d.calculated].map[d | d as EntityFieldDeclaration].toList
    }

//    def Collection<ConstraintDeclaration> allConstraints(EntityDeclaration it) {
//        allMembers.filter[d | d instanceof ConstraintDeclaration].map[d | d as ConstraintDeclaration].toList
//    }

    def Collection<AnnotationDeclaration> annotationDeclarations(ModelDeclaration it) {
        declarations.filter[d | d instanceof AnnotationDeclaration].map[d | d as AnnotationDeclaration].toList
    }
    
    def Collection<TransferDeclaration> transferDeclarations(ModelDeclaration it) {
        declarations.filter[d | d instanceof TransferDeclaration && !(d instanceof ActorDeclaration)].map[d | d as TransferDeclaration].toList
    }

    def Collection<ViewDeclaration> viewDeclarations(ModelDeclaration it) {
        declarations.filter[d | d instanceof ViewDeclaration].map[d | d as ViewDeclaration].toList
    }
    
    def Collection<RowDeclaration> rowDeclarations(ModelDeclaration it) {
        declarations.filter[d | d instanceof RowDeclaration].map[d | d as RowDeclaration].toList
    }

    def Collection<ActorDeclaration> actorDeclarations(ModelDeclaration it) {
        declarations.filter[d | d instanceof ActorDeclaration].map[d | d as ActorDeclaration].toList
    }

    def Collection<TransferFieldDeclaration> fields(TransferDeclaration it) {
        eAllContents.filter[d | d instanceof TransferFieldDeclaration].map[d | d as TransferFieldDeclaration].toList
    }

    def Collection<TransferRelationDeclaration> relations(TransferDeclaration it) {
        eAllContents.filter[d | d instanceof TransferRelationDeclaration].map[d | d as TransferRelationDeclaration].toList
    }

    def String sourceCode(Expression it) {
        return NodeModelUtils.findActualNodeFor(it)?.getText()
    }

    def Collection<EntityRelationDeclaration> getAllStoredRelations(ModelDeclaration it, boolean singleInstanceOfBidirectional) {
        val List<EntityRelationDeclaration> relations = new ArrayList()

        for (entity : entityDeclarations) {
            for (relation : entity.storedRelations) {
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
    	return eAllContents.filter[c | c instanceof TransferRelationDeclaration && c.parentContainer(ActorDeclaration) === null].map[e | e as TransferRelationDeclaration].toList
    }

    def Collection<TransferRelationDeclaration> getAllSimpleTransferRelations(ModelDeclaration it) {
    	return eAllContents.filter[c | c instanceof TransferRelationDeclaration && c.parentContainer(TransferDeclaration) !== null].map[e | e as TransferRelationDeclaration].toList
    }

    def Collection<TransferRelationDeclaration> getAllViewTransferRelations(ModelDeclaration it) {
    	return eAllContents.filter[c | c instanceof TransferRelationDeclaration && c.parentContainer(ViewDeclaration) !== null].map[e | e as TransferRelationDeclaration].toList
    }

    def Collection<TransferRelationDeclaration> getAllActorTransferRelations(ModelDeclaration it) {
    	return eAllContents.filter[c | c instanceof TransferRelationDeclaration && c.parentContainer(ActorDeclaration) !== null].map[e | e as TransferRelationDeclaration].toList
    }

    def Collection<EntityRelationDeclaration> getAllCalculatedRelations(ModelDeclaration it, boolean singleInstanceOfBidirectional) {
        val List<EntityRelationDeclaration> relations = new ArrayList()

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

    def Collection<QueryDeclaration> allQueryDeclarations(ModelDeclaration model) {
        model.declarations.filter[d | d instanceof QueryDeclaration].map[e | e as QueryDeclaration].toList
    }

    def Collection<ActorDeclaration> allActorDeclarations(ModelDeclaration model) {
        model.declarations.filter[d | d instanceof ActorDeclaration].map[e | e as ActorDeclaration].toList
    }

    def String getStringLiteralValue(StringLiteral it) {
        switch it {
            RawStringLiteral: return it.value
            EscapedStringLiteral: return it.value
        }
    }

    def BigInteger getMaxFileSizeValue(MaxFileSizeModifier it) {
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

	def isAggregation(TransferRelationDeclaration relation) {
		if (relation.getterExpr === null) return true;
		return relation.eager
	}

	def isEager(EntityMemberDeclaration member) {
		val EagerModifier eagerModifier = member.getModifier(JsldslPackage::eINSTANCE.eagerModifier) as EagerModifier
		
		if (member instanceof EntityFieldDeclaration) {
			return eagerModifier === null || eagerModifier.value.isTrue
		} else {
			return eagerModifier !== null && eagerModifier.value.isTrue
		}
	}

	def isEager(TransferDataDeclaration member) {
		if (member.getterExpr === null) return false;  // because it has no expression
		val EagerModifier eagerModifier = member.getModifier(JsldslPackage::eINSTANCE.eagerModifier) as EagerModifier
		return eagerModifier !== null && eagerModifier.value.isTrue
	}

	def isQueryCall(Feature feature) {
		if (feature instanceof MemberReference && (feature as MemberReference).member instanceof EntityMemberDeclaration) {
			val EntityMemberDeclaration member = (feature as MemberReference).member as EntityMemberDeclaration
			if (member.getterExpr === null) return false;
			return !member.eager
		}
		
		return false
	}
	
	def Modifier getModifier(Modifiable it, EClassifier classifier) {
		return it.modifiers.findFirst[m | classifier.isInstance(m)]
	}
	
    def Collection<ModelDeclaration> allImportedModelDeclarations(ModelDeclaration model) {
    	var HashMap<String, ModelDeclaration> models = new HashMap<String, ModelDeclaration>();
    	model.appendImportedModelDeclarations(models)
    	models.remove(model.name)
    	return models.values
    }

    def void appendImportedModelDeclarations(ModelDeclaration model, HashMap<String, ModelDeclaration> models) {
    	model.imports.filter[i | !models.containsKey(i.model.name)]
    		.forEach[i |
    			i.model.fromModel models.put(i.model.name, i.model)
    			i.model.appendImportedModelDeclarations(models)
    		]
    }
    
    def BooleanLiteral getAsBooleanLiteral(Expression expr) {
    	if (expr === null) return null
    	
    	if (!(expr instanceof Navigation)) return null
    	val Navigation navigation = expr as Navigation

    	if (navigation.base === null) return null
		if (!(navigation.base instanceof BooleanLiteral)) return null 
    	
    	return navigation.base as BooleanLiteral
    }
    
    def boolean isRequired(EntityMemberDeclaration it) {
    	val RequiredModifier modifier = it.getModifier(JsldslPackage::eINSTANCE.requiredModifier) as RequiredModifier
    	if (modifier === null) return false

		if (modifier.expression === null) return true
    	
    	val BooleanLiteral literal = modifier.expression.asBooleanLiteral
    	if (literal === null) return false

    	return literal.isIsTrue
    }

    def boolean isRequired(TransferMemberDeclaration it) {
    	val RequiredModifier modifier = it.getModifier(JsldslPackage::eINSTANCE.requiredModifier) as RequiredModifier
    	if (modifier === null || modifier.expression === null) return false

		if (modifier.expression === null) return true

    	val BooleanLiteral literal = modifier.expression.asBooleanLiteral
    	if (literal === null) return false

    	return literal.isIsTrue
    }

    def boolean isAbstract(EntityDeclaration it) {
    	val AbstractModifier modifier = it.getModifier(JsldslPackage::eINSTANCE.abstractModifier) as AbstractModifier
    	return modifier !== null && (modifier.value === null || modifier.value.isIsTrue)
	}    	

    def boolean isAfter(TransferEventDeclaration it) {
    	val OnModifier modifier = it.getModifier(JsldslPackage::eINSTANCE.onModifier) as OnModifier
    	return modifier !== null && modifier.after
	}    	

    def boolean isBefore(TransferEventDeclaration it) {
    	val OnModifier modifier = it.getModifier(JsldslPackage::eINSTANCE.onModifier) as OnModifier
    	return modifier !== null && modifier.before
	}    	

    def boolean isInstead(TransferEventDeclaration it) {
    	val OnModifier modifier = it.getModifier(JsldslPackage::eINSTANCE.onModifier) as OnModifier
    	return modifier === null
	}    	

    def boolean isHuman(ActorDeclaration it) {
    	val HumanModifier modifier = it.getModifier(JsldslPackage::eINSTANCE.humanModifier) as HumanModifier
    	return modifier !== null && (modifier.value === null || modifier.value.isIsTrue)
	}    	
}
