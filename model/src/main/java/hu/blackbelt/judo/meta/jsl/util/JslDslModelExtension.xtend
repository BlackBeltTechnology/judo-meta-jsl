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
import hu.blackbelt.judo.meta.jsl.jsldsl.DiagramDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.DiagramShowDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.FilterModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.FieldsModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.ClassDeclaration
import java.util.Map
import java.util.Set
import hu.blackbelt.judo.meta.jsl.jsldsl.RelationsModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.PrimitiveDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.BooleanLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.BinaryOperation
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationBase
import hu.blackbelt.judo.meta.jsl.jsldsl.Literal
import hu.blackbelt.judo.meta.jsl.jsldsl.NumberLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.IntegerLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.DecimalLiteral
import java.math.BigDecimal
import hu.blackbelt.judo.meta.jsl.jsldsl.UnaryOperation
import hu.blackbelt.judo.meta.jsl.jsldsl.Parentheses
import hu.blackbelt.judo.meta.jsl.jsldsl.Self
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelImportDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionOrQueryCall
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionOrQueryDeclaration
import static org.mockito.Mockito.inOrder
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.util.EObjectContainmentEList
import org.eclipse.emf.ecore.util.EObjectEList
import org.eclipse.emf.common.util.UniqueEList
import java.util.Arrays
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumLiteralReference
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaCall
import hu.blackbelt.judo.meta.jsl.jsldsl.RowColumnDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationBaseDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaVariable
import hu.blackbelt.judo.meta.jsl.jsldsl.UpdateModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.CreateModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.DeleteModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferChoiceModifier

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
		return it.getterExpr !== null && !it.maps
	}

	def isMaps(TransferDataDeclaration it) {
		if (it.getterExpr === null) return false
		
		if (it instanceof TransferRelationDeclaration) {
			val CreateModifier createModifier = it.getModifier(JsldslPackage::eINSTANCE.createModifier) as CreateModifier
			val TransferChoiceModifier choiceModifier = it.getModifier(JsldslPackage::eINSTANCE.transferChoiceModifier) as TransferChoiceModifier
			
			return (createModifier !== null && createModifier.isTrue) || choiceModifier !== null
		}
		
		val UpdateModifier updateModifier = it.getModifier(JsldslPackage::eINSTANCE.updateModifier) as UpdateModifier
		return updateModifier !== null && updateModifier.isAuto
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

    def Collection<ModelDeclaration> modelDeclarations(ModelDeclaration it) {
    	var Collection<ModelDeclaration> result = new ArrayList<ModelDeclaration>()
    	
    	for (i: it.imports) result.add(i.model)
    	result.add(it)

    	return result
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
//        declarations.filter[d | d instanceof TransferDeclaration && !(d instanceof ActorDeclaration)].map[d | d as TransferDeclaration].toList
        declarations.filter[d | d instanceof TransferDeclaration].map[d | d as TransferDeclaration].toList
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

    def Collection<DiagramDeclaration> diagramDeclarations(ModelDeclaration it) {
        declarations.filter[d | d instanceof DiagramDeclaration].map[d | d as DiagramDeclaration].toList
    }

    def boolean diagramShowFields(DiagramShowDeclaration show) {
		val FieldsModifier fields = show.getModifier(JsldslPackage::eINSTANCE.fieldsModifier) as FieldsModifier;
		return fields === null || fields.value.isTrue
    }

    def Collection<DiagramShowDeclaration> diagramShowDeclarations(DiagramDeclaration it) {
        members.filter[m | m instanceof DiagramShowDeclaration].map[d | d as DiagramShowDeclaration].toList
    }

//	def Collection<ClassDeclaration> filterClasses(DiagramShowDeclaration show, ModelDeclaration model, EClassifier classifier) {
//    	var Collection<ClassDeclaration> result = new ArrayList<ClassDeclaration>;
//		val FilterModifier filter = show.getModifier(JsldslPackage::eINSTANCE.filterModifier) as FilterModifier;
//
//		val String pattern = filter !== null ? "^" + filter.value.value.toString.toLowerCase.replace("*", "([a-z0-9]*)").replace("?", "([a-z0-9])") + "$" : "^([a-z0-9:]*)$";
//
//		for (cls: model.declarations
//						.filter[c | c.eClass === classifier]
//						.filter[c | c.fullyQualifiedName.toString('::').toLowerCase.matches(pattern) || c.name.toLowerCase.matches(pattern)]
//						.map[c | c as ClassDeclaration].toList)
//		{
//			result.add(cls);
//		}
//		
//		for (i: model.imports) {
//			val ModelDeclaration m = i.model;
//			val String alias = i.alias !== null ? i.alias + "::" : ""
//			
//			for (cls: m.declarations
//							.filter[c | c.eClass === classifier]
//							.filter[c | c.fullyQualifiedName.toString('::').toLowerCase.matches(pattern) || (alias + c.name).toLowerCase.matches(pattern)]
//							.map[c | c as ClassDeclaration].toList)
//			{
//				result.add(cls);
//			}
//		}
//		
//		return result
//	}

    def Collection<ClassDeclaration> showClassDeclarations(DiagramShowDeclaration show, ModelDeclaration model) {
    	var Collection<ClassDeclaration> result = new ArrayList<ClassDeclaration>;

//		if (show.entity || show.all) {
//			result.addAll(show.filterClasses(model, JsldslPackage::eINSTANCE.entityDeclaration))
//		}
//
//		if (show.transfer || show.all) {
//			result.addAll(show.filterClasses(model, JsldslPackage::eINSTANCE.simpleTransferDeclaration))
//		}
//
//		if (show.view || show.all) {
//			result.addAll(show.filterClasses(model, JsldslPackage::eINSTANCE.viewDeclaration))
//			result.addAll(show.filterClasses(model, JsldslPackage::eINSTANCE.rowDeclaration))
//		}
//
//		if (show.actor || show.all) {
//			result.addAll(show.filterClasses(model, JsldslPackage::eINSTANCE.actorDeclaration))
//		}
		
//		else {
//			if (show.declaration instanceof EntityDeclaration)
//				result.add(show.declaration as EntityDeclaration);
//		}

		return result
    }

	def Map<String, ClassDeclaration> getDiagramClasses(DiagramDeclaration diagram, ModelDeclaration model, boolean withRelations) {
		var Map<String, ClassDeclaration> result = new HashMap<String, ClassDeclaration>;
		
		for (show: diagram.diagramShowDeclarations) {
			for (cls: show.showClassDeclarations(model)) {
				if (withRelations) {
					val RelationsModifier relations = show.getModifier(JsldslPackage::eINSTANCE.relationsModifier) as RelationsModifier
					if (relations === null || relations.value.isTrue) result.put(model.getExternalName(cls), cls)
				} else {
					result.put(model.getExternalName(cls), cls)
				}
			}
		}

		for (grp: diagram.diagramGroupDeclarations) {
			result.putAll(grp.getDiagramClasses(model, withRelations))
		}

		return result
	}

	def Set<EntityRelationDeclaration> getDiagramRelations(DiagramDeclaration diagram, ModelDeclaration model) {
		var Set<EntityRelationDeclaration> result = new HashSet<EntityRelationDeclaration>;
		var Map<String, ClassDeclaration> fromClasses = diagram.getDiagramClasses(model, true);
		var Map<String, ClassDeclaration> toClasses = diagram.getDiagramClasses(model, false);
		
		for (name: fromClasses.filter[k,v| v instanceof EntityDeclaration].keySet) {
			val EntityDeclaration entity = fromClasses.get(name) as EntityDeclaration
			
			for (relation : entity.members.filter[m | m instanceof EntityRelationDeclaration].map[m | m as EntityRelationDeclaration]) {
				if (toClasses.containsValue(relation.referenceType)) {
					result.add(relation)
				}
			}
		}
		
		return result
	}

    def Collection<DiagramDeclaration> diagramGroupDeclarations(DiagramDeclaration it) {
    	members.filter[m | m instanceof DiagramDeclaration].map[m | m as DiagramDeclaration].toList
    }

    def Collection<TransferFieldDeclaration> fields(TransferDeclaration it) {
        eAllContents.filter[d | d instanceof TransferFieldDeclaration].map[d | d as TransferFieldDeclaration].toList
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

    def Collection<EntityDeclaration> allEntityDeclarations(ModelDeclaration model) {
        model.declarations.filter[d | d instanceof EntityDeclaration].map[e | e as EntityDeclaration].toList
    }

    def Collection<TransferDeclaration> allTransferDeclarations(ModelDeclaration model) {
        model.declarations.filter[d | d instanceof TransferDeclaration].map[e | e as TransferDeclaration].toList
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
            case "KB": return it.numeric.multiply(BigInteger.valueOf(1000))
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
			return eagerModifier === null || eagerModifier.isTrue
		} else {
			return eagerModifier !== null && eagerModifier.isTrue
		}
	}

	def isEager(TransferDataDeclaration member) {
		if (member.getterExpr === null) return false;  // because it has no expression
		val EagerModifier eagerModifier = member.getModifier(JsldslPackage::eINSTANCE.eagerModifier) as EagerModifier
		return eagerModifier !== null && eagerModifier.isTrue
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
    
    def String getExternalName(ModelDeclaration it, EObject object) {
    	if (!(object instanceof Named)) {
    		return "<none>";
    	}
    	
    	val Named named = object as Named;
    	
        if (named.parentContainer(ModelDeclaration) === null) {
            return named.name
        }

        if (it.name !== named?.parentContainer(ModelDeclaration).name) {
            val importList = imports.filter[i | i.model.name.equals(named.parentContainer(ModelDeclaration)?.name)]
                .map[i | i.alias !== null ? i.alias + "::" + named.name : named.name]
            if (importList !== null && importList.size > 0) {
                return importList.get(0)
            } else {
                return named.name
            }
        } else {
            return named.name
        }
    }

    def boolean isJudoMeta(EObject object) {
    	return !object.eIsProxy && object.parentContainer(ModelDeclaration).name.equals("judo::meta")
    }

/******************
 * META evaluation
 ******************/

	def Object evalMeta(Expression it, Object base) {
		switch it {
			BinaryOperation: return it.evalMeta(base)
			UnaryOperation: return it.evalMeta(base)
			Navigation: return it.evalMeta(base)
		}
	}

	def Object evalMeta(BinaryOperation it, Object base) {
		val Object leftObject = it.leftOperand.evalMeta(base)
		val Object rightObject = it.rightOperand.evalMeta(base)
		
		if (leftObject === null || rightObject === null) return null
		
		if (leftObject instanceof Boolean && rightObject instanceof Boolean) {
			val left = leftObject as Boolean
			val right = rightObject as Boolean

			switch it.operator.toLowerCase {
				case "==": return left == right
				case "!=": return left != right
				case "and": return left && right
				case "or": return left || right
				case "xor": return (left && !right) || (!left && right)
				case "implies": return left ? right : true
			}
		}
		
		if (leftObject instanceof BigDecimal && rightObject instanceof BigDecimal) {
			val left = leftObject as BigDecimal
			val right = rightObject as BigDecimal

			switch it.operator.toLowerCase {
				case "==": return left == right
				case "!=": return left != right
				case "<": return left < right
				case ">": return left > right
				case "<=": return left <= right
				case ">=": return left >= right

				case "*": return left.multiply(right)
				case "/": return left.divide(right)
				case "+": return left.add(right)
				case "-": return left.subtract(right)
				case "div": return new BigDecimal(left.toBigInteger.divide(right.toBigInteger))
				case "mod": return new BigDecimal(left.toBigInteger.mod(right.toBigInteger))
				case "^": return left.pow(right.intValue)
			}
		}

		if (leftObject instanceof String && rightObject instanceof String) {
			val left = leftObject as String
			val right = rightObject as String

			switch it.operator.toLowerCase {
				case "==": return left.equals(right)
				case "!=": return !left.equals(right)
				case "<": return left < right
				case ">": return left > right
				case "<=": return left <= right
				case ">=": return left >= right
			}
		}
		
		return true
	}

	def Object evalMeta(UnaryOperation it, Object base) {
		return !(it.operand.evalMeta(base) as Boolean)
	}

	def Object evalMeta(Navigation it, Object base) {
		if (base instanceof Set) {
			var Set<Object> result = new HashSet<Object>
			for (b: base) {
				var tmp = it.evalMeta(b)
				tmp instanceof Set ? result.addAll(tmp) : if (tmp !== null) result.add(tmp)
			}
			return result
		}

		var Object result = it.base.evalMeta(base)

		for (feature: it.features) {
			result = feature.evalMeta(result)
		}

		return result
	}

	def Object evalMeta(Feature it, Object base) {
		if (it instanceof FunctionOrQueryCall) return it.evalMeta(base)
		
		if (base instanceof Set) {
			var Set<Object> result = new HashSet<Object>
			for (b: base) {
				var tmp = it.evalMeta(b)
				tmp instanceof Set ? result.addAll(tmp) : if (tmp !== null) result.add(tmp)
			}
			return result
		}

		switch it {
			MemberReference: return it.member.evalMeta(base)
			LambdaCall: it.evalMeta(base)
		}
	}

	def Object evalMeta(LambdaCall it, Object base) {
		if (base === null) return null

		switch it.declaration.name {
			case "filter": return it.lambdaExpression.evalMeta(base) as Boolean ? base : null
		}
	}

	def Object evalMeta(FunctionOrQueryCall it, Object base) {
		switch it.declaration.name {
			case "isDefined": return base !== null
			case "isUndefined": return base === null
			case "orElse": return base !== null ? base : it.arguments.get(0).expression.evalMeta(base)
		}
		
		if (base === null) return null

		if (base instanceof EntityDeclaration) {
			if (base.name.toLowerCase.equals("entity") && it.declaration.name.equals("any")) return it.parentContainer(ModelDeclaration).entityDeclarations.head
			if (base.name.toLowerCase.equals("entity") && it.declaration.name.equals("all")) return it.parentContainer(ModelDeclaration).entityDeclarations.toSet

			if (base.name.toLowerCase.equals("transfer") && it.declaration.name.equals("any")) return it.parentContainer(ModelDeclaration).transferDeclarations.head
			if (base.name.toLowerCase.equals("transfer") && it.declaration.name.equals("all")) return it.parentContainer(ModelDeclaration).transferDeclarations.toSet
		}
		
		switch it.declaration.name {
			case "asString": return base.toString
			
			case "size": return new BigDecimal(base instanceof String ? base.length : (base as Collection<EObject>).size)
			case "any": return (base as Collection<EObject>).head
			case "all": return base
			
			case "matches": return (base as String).matches(it.arguments.get(0).expression.evalMeta(base).toString)
			case "left": return (base as String).substring(0, Math.min((base as String).length(), Math.max(0, (it.arguments.get(0).expression.evalMeta(base) as BigDecimal).intValue)))
			case "right": return (base as String).substring((base as String).length() - Math.min((base as String).length(), Math.max(0, (it.arguments.get(0).expression.evalMeta(base) as BigDecimal).intValue)))
			case "position": return new BigDecimal((base as String).indexOf(it.arguments.get(0).expression.evalMeta(base).toString) + 1)
			case "lower": return (base as String).toLowerCase
			case "upper": return (base as String).toUpperCase
			case "trim": return (base as String).trim
			case "ltrim": return (base as String).replaceAll("^\\s+", "")
			case "rtrim": return (base as String).replaceAll("\\s+$", "")
			
			case "container": return (base as EObject).eContainer.equalMeta(it.arguments.get(0).expression.evalMeta(null) as EntityDeclaration) ? (base as EObject).eContainer : null
		}
	}

	def boolean equalMeta(EObject object, EntityDeclaration metaObject) {
		switch object {
			ModelDeclaration: return metaObject.name.equalsIgnoreCase("model")
			EntityDeclaration: return metaObject.name.equalsIgnoreCase("entity")
			TransferDeclaration: return metaObject.name.equalsIgnoreCase("transfer")
		}

		return false
	}

	def Object evalMeta(FunctionOrQueryDeclaration it, Object base) {
		switch it {
			FunctionDeclaration: return it.evalMeta(base)
		}
	}

	def Object evalMeta(NavigationTarget it, Object base) {
		switch it {
			EntityFieldDeclaration: return it.evalMeta(base)
			EntityRelationDeclaration: return it.evalMeta(base)
		}
	}
	
	def Object evalMeta(EntityFieldDeclaration it, Object base) {
		if (base === null) return null

		if (it.name.equals("name")) return (base as EObject).eGet((base as EObject).eClass.EAllAttributes.findFirst[a | a.name.equals(it.name)])

		switch base {
			EntityFieldDeclaration case it.name.equals("type"):
				return "Type#" + (base.referenceType instanceof DataTypeDeclaration ? (base.referenceType as DataTypeDeclaration).primitive.toLowerCase : "enum")
			EntityFieldDeclaration case it.name.equals("target"): return base.referenceType

			TransferFieldDeclaration case it.name.equals("type"):
				return "Type#" + (base.referenceType instanceof DataTypeDeclaration ? (base.referenceType as DataTypeDeclaration).primitive.toLowerCase : "enum")
			TransferFieldDeclaration case it.name.equals("target"): return base.referenceType

			TransferDeclaration case it.name.equals("kind") && base instanceof ActorDeclaration: return "TransferKind#actor"
			TransferDeclaration case it.name.equals("kind") && base instanceof ViewDeclaration: return "TransferKind#view"
			TransferDeclaration case it.name.equals("kind") && base instanceof RowDeclaration: return "TransferKind#row"
			TransferDeclaration case it.name.equals("kind") && base instanceof RowColumnDeclaration: return "TransferKind#column"
			TransferDeclaration case it.name.equals("kind"): return "TransferKind#transfer"
		}
	}

	def Object evalMeta(EntityRelationDeclaration it, Object base) {
		if (base === null) return null

		switch base {
			EntityDeclaration case it.name.equals("fields"): return base.members.filter[m | m instanceof EntityFieldDeclaration].toSet
			EntityDeclaration case it.name.equals("relations"): return base.members.filter[m | m instanceof EntityRelationDeclaration].toSet
			EntityDeclaration case it.name.equals("extends"): return base.extends.toSet
			EntityRelationDeclaration case it.name.equals("target"): return base.referenceType

			TransferDeclaration case it.name.equals("fields"): return base.members.filter[m | m instanceof TransferFieldDeclaration].toSet
			TransferDeclaration case it.name.equals("relations"): return base.members.filter[m | m instanceof TransferRelationDeclaration].toSet
			TransferDeclaration case it.name.equals("map"): return base.map.entity
			TransferRelationDeclaration case it.name.equals("target"): return base.referenceType
			
			ModelDeclaration case it.name.equals("entities"): return base.allEntityDeclarations.toSet
			ModelDeclaration case it.name.equals("transfers"): return base.allTransferDeclarations.toSet
		}
	}

	def Object evalMeta(NavigationBase it, Object base) {
		switch it {
			Literal: return it.evalMeta
			Parentheses: return it.expression.evalMeta(base)
			Self: return base
			NavigationBaseDeclarationReference: return it.reference.evalMeta(base)
		}
		
		return base
	}

	def Object evalMeta(NavigationBaseDeclaration it, Object base) {
		switch (it) {
			EntityDeclaration: return it
			LambdaVariable: return base
		}
	}

	def Object evalMeta(Literal it) {
		switch it {
			BooleanLiteral: return it.isTrue
			StringLiteral: return it.value
			IntegerLiteral: return new BigDecimal(it.minus ? it.value.negate : it.value)
			DecimalLiteral: return it.minus ? it.value.negate : it.value
			EnumLiteralReference: return it.enumDeclaration.name + "#" + it.enumLiteral.name
		}
	}
}
