package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.scoping.Scopes
import com.google.inject.Inject
import org.eclipse.xtext.scoping.IScope
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOpposite
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityMemberDeclaration
import java.util.List
import org.eclipse.xtext.naming.IQualifiedNameProvider
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration
import org.eclipse.emf.ecore.EClass
import org.eclipse.xtext.resource.ISelectable
import org.eclipse.emf.ecore.resource.Resource
import com.google.inject.Provider
import java.util.Iterator
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.scoping.impl.MultimapBasedSelectable
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.util.IResourceScopeCache
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.xtext.naming.QualifiedName
import static java.util.Collections.singletonList
import org.eclipse.xtext.scoping.impl.ImportScope
import java.util.concurrent.atomic.AtomicReference
import org.eclipse.xtext.scoping.impl.FilteringScope
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeReferenced
import hu.blackbelt.judo.meta.jsl.jsldsl.Navigation
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaDeclaration
import hu.blackbelt.judo.meta.jsl.runtime.TypeInfo
import hu.blackbelt.judo.meta.jsl.jsldsl.MemberReference
import hu.blackbelt.judo.meta.jsl.jsldsl.TypeDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeInjected
import org.eclipse.xtext.EcoreUtil2
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaVariable
import hu.blackbelt.judo.meta.jsl.jsldsl.ErrorDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumLiteralReference
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension
import java.util.ArrayList
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaCall
import hu.blackbelt.judo.meta.jsl.jsldsl.AnnotationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.AnnotationParameterDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.AnnotationMark
import hu.blackbelt.judo.meta.jsl.jsldsl.AnnotationArgument
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityMapDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewActionDeclaration
import org.eclipse.emf.ecore.EClassifier
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferActionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorAccessDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorMenuDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.SimpleTransferDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewLinkDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewTableDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferCreateDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.Argument
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionOrQueryCall
import hu.blackbelt.judo.meta.jsl.jsldsl.ParameterDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.DiagramDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.PrimitiveDeclaration

class JslDslScopeProvider extends AbstractJslDslScopeProvider {

    @Inject extension JslDslIndex
    @Inject extension IQualifiedNameProvider

    @Inject IResourceScopeCache cache = IResourceScopeCache.NullImpl.INSTANCE;
    @Inject IQualifiedNameProvider qualifiedNameProvider

    @Inject extension JslDslModelExtension

    override getScope(EObject context, EReference ref) {
//        System.out.println("\u001B[0;32mJslDslLocalScopeProvider - Reference target: " + ref.EReferenceType.name + "\n\tdef scope_" + ref.EContainingClass.name + "_" + ref.name + "(" + context.eClass.name + " context, EReference ref)" +
//        "\n\t" + context.eClass.name + " case ref == JsldslPackage::eINSTANCE." + ref.EContainingClass.name.toFirstLower + "_" + ref.name.toFirstUpper
//            + ": return context.scope_" + ref.EContainingClass.name + "_" + ref.name + "(ref)\u001B[0m")
//        printParents(context)

        var IScope scope = delegateGetScope(context, ref);

        scope = this.scope_FilterByDiagram(scope, ref, context);
        scope = this.scope_FilterByReferenceType(scope, ref);
        scope = this.scope_FilterByVisibility(scope, ref, context);

        switch context {
            EntityRelationOppositeReferenced case ref == JsldslPackage::eINSTANCE.entityRelationOppositeReferenced_OppositeType: return context.scope_EntityRelationOppositeReferenced_oppositeType(ref)
            MemberReference case ref == JsldslPackage::eINSTANCE.memberReference_Member: return this.scope_Navigation(scope, ref, TypeInfo.getTargetType(context))
            EnumLiteralReference case ref == JsldslPackage::eINSTANCE.enumLiteralReference_EnumLiteral: return scope.scope_Containments(context.enumDeclaration, ref)

            FunctionOrQueryCall case ref == JsldslPackage::eINSTANCE.functionOrQueryCall_Declaration: return this.scope_Navigation(scope, ref, TypeInfo.getTargetType(context))
            FunctionOrQueryCall case ref == JsldslPackage::eINSTANCE.lambdaCall_Declaration: return this.scope_Navigation(scope, ref, TypeInfo.getTargetType(context))
            FunctionOrQueryCall case ref == JsldslPackage::eINSTANCE.argument_Declaration: return scope.scope_Containments(context.declaration, ref)

            Argument case ref == JsldslPackage::eINSTANCE.argument_Declaration: return scope.scope_Containments((context.eContainer as FunctionOrQueryCall).declaration, ref)

            AnnotationMark case ref == JsldslPackage::eINSTANCE.annotationArgument_Declaration: return scope.scope_Containments(context.declaration, ref)

            AnnotationArgument case ref == JsldslPackage::eINSTANCE.annotationArgument_Declaration && context.eContainer instanceof AnnotationMark: return scope.scope_Containments((context.eContainer as AnnotationMark).declaration, ref)

			EntityRelationDeclaration case ref == JsldslPackage::eINSTANCE.entityMemberDeclaration_ReferenceType: return this.scope_FilterByEClassifier(scope, JsldslPackage::eINSTANCE.entityDeclaration)
			EntityFieldDeclaration case ref == JsldslPackage::eINSTANCE.entityMemberDeclaration_ReferenceType && context.identifier: return this.scope_FilterByEClassifier(scope, JsldslPackage::eINSTANCE.primitiveDeclaration)

			ViewActionDeclaration case ref == JsldslPackage::eINSTANCE.transferActionDeclaration_ParameterType: return this.scope_FilterByEClassifier(scope, JsldslPackage::eINSTANCE.viewDeclaration)
			TransferActionDeclaration case ref == JsldslPackage::eINSTANCE.transferActionDeclaration_ParameterType: return this.scope_FilterByEClassifier(scope, JsldslPackage::eINSTANCE.simpleTransferDeclaration)

			ViewActionDeclaration case ref == JsldslPackage::eINSTANCE.returnFragment_ReferenceTypes: return this.scope_FilterByEClassifier(scope, JsldslPackage::eINSTANCE.viewDeclaration)
			TransferActionDeclaration case ref == JsldslPackage::eINSTANCE.returnFragment_ReferenceTypes: return this.scope_FilterByEClassifier(scope, JsldslPackage::eINSTANCE.simpleTransferDeclaration)

			ActorMenuDeclaration case ref == JsldslPackage::eINSTANCE.transferRelationDeclaration_ReferenceType: return this.scope_FilterByEClassifier(scope, JsldslPackage::eINSTANCE.visibleDeclaration)
			ActorAccessDeclaration case ref == JsldslPackage::eINSTANCE.transferRelationDeclaration_ReferenceType: return this.scope_FilterByEClassifier(scope, JsldslPackage::eINSTANCE.simpleTransferDeclaration)

			TransferCreateDeclaration case ref == JsldslPackage::eINSTANCE.transferCreateDeclaration_ParameterType && context.eContainer instanceof SimpleTransferDeclaration: return this.scope_FilterByEClassifier(scope, JsldslPackage::eINSTANCE.simpleTransferDeclaration)
			TransferCreateDeclaration case ref == JsldslPackage::eINSTANCE.transferCreateDeclaration_ParameterType && context.eContainer instanceof ViewDeclaration: return this.scope_FilterByEClassifier(scope, JsldslPackage::eINSTANCE.viewDeclaration)

			ViewLinkDeclaration case ref == JsldslPackage::eINSTANCE.transferRelationDeclaration_ReferenceType: return this.scope_FilterByEClassifier(scope, JsldslPackage::eINSTANCE.viewDeclaration)
			ViewTableDeclaration case ref == JsldslPackage::eINSTANCE.transferRelationDeclaration_ReferenceType: return this.scope_FilterByEClassifier(scope, JsldslPackage::eINSTANCE.rowDeclaration)

			TransferRelationDeclaration case ref == JsldslPackage::eINSTANCE.transferRelationDeclaration_ReferenceType: return this.scope_FilterByEClassifier(scope, JsldslPackage::eINSTANCE.simpleTransferDeclaration)

            Navigation: return this.scope_Navigation(scope, ref, TypeInfo.getTargetType(context))
        }

        return scope
    }

    def scope_AllContainments(IScope scope, EObject context, EReference ref) {
        return new FilteringScope(scope.getLocalElementsScope(context, ref), [desc | {
        	var EObject container = desc.EObjectOrProxy.eContainer;
        	
        	while (container !== null) {
        		if (container.isEqual(context)) return true;
        		container = container.eContainer;
        	}
        	
        	return false;
        }]);
    }

    def scope_Containments(IScope scope, EObject context, EReference ref) {
        return new FilteringScope(scope.getLocalElementsScope(context, ref), [desc | {
            return desc.EObjectOrProxy.eContainer.isEqual(context)
        }]);
    }

    def scope_Navigation(IScope scope, EReference ref, TypeInfo navigationTypeInfo) {
        var IScope navigationScope

        if (navigationTypeInfo.isEntity && navigationTypeInfo.declaration) {
            navigationScope = new FilteringScope(scope, [desc | {
                val obj = desc.EObjectOrProxy

                switch obj {
                    FunctionDeclaration: return obj.baseType !== null && navigationTypeInfo.isBaseCompatible(TypeInfo.getTargetType(obj.baseType)) && TypeInfo.getTargetType(obj.baseType).declaration
                }

                return false
            }]);
        }
        else if (navigationTypeInfo.isEntity && !navigationTypeInfo.declaration) {
            navigationScope = this.getEntityMembers(scope, navigationTypeInfo.getEntity, ref, new ArrayList<EntityDeclaration>())

            navigationScope = new FilteringScope(navigationScope, [desc | {
                val obj = desc.EObjectOrProxy

                switch obj {
                    EntityMemberDeclaration: return !(navigationTypeInfo.isCollection && TypeInfo.getTargetType(obj).isPrimitive)
                    EntityRelationOppositeInjected: return true
                    FunctionDeclaration: return obj.baseType !== null && navigationTypeInfo.isBaseCompatible(TypeInfo.getTargetType(obj.baseType))
                    LambdaDeclaration: return navigationTypeInfo.isCollection()
                    QueryDeclaration: return navigationTypeInfo.isInstanceOf(TypeInfo.getTargetType(obj.entity))
                }

                return false
            }]);
        } else {
            navigationScope = new FilteringScope(scope, [desc | {
                val obj = desc.EObjectOrProxy

                switch obj {
                	FunctionDeclaration: return obj.baseType !== null && navigationTypeInfo.isBaseCompatible(TypeInfo.getTargetType(obj.baseType))
                 	LambdaDeclaration: return navigationTypeInfo.isEntity() && navigationTypeInfo.isCollection()
                 	QueryDeclaration: return obj.entity === null
                }

                false
            }]);
        }

        return navigationScope
    }

    def scope_FilterByEClassifier(IScope scope, EClassifier classifier) {
        return new FilteringScope(scope, [desc | {
            return classifier.isInstance(desc.EObjectOrProxy);
        }]);
    }

    def scope_FilterByEClassifierNot(IScope scope, EClassifier classifier) {
        return new FilteringScope(scope, [desc | {
            return !classifier.isInstance(desc.EObjectOrProxy);
        }]);
    }

    def scope_FilterByReferenceType(IScope scope, EReference ref) {
        return new FilteringScope(scope, [desc | {
            return ref.EReferenceType.isInstance(desc.EObjectOrProxy);
        }]);
    }
	
    def scope_FilterByDiagram(IScope scope, EReference ref, EObject context) {
		return new FilteringScope(scope, [desc | {
			val obj = desc.EObjectOrProxy
						
			if (obj.parentContainer(ModelDeclaration) === null) return true;
			if (context instanceof EntityDeclaration) return true
			if (context instanceof EntityMemberDeclaration) return true
			
			if (context.parentContainer(DiagramDeclaration) !== null) {
                switch obj {
                	EntityDeclaration: return (obj.parentContainer(ModelDeclaration) as ModelDeclaration).name.equals("judo::meta")
                	QueryDeclaration: return false
                	PrimitiveDeclaration: return false
				}
			}
			
            switch obj {
            	TypeDeclaration: return !(obj.parentContainer(ModelDeclaration) as ModelDeclaration).name.equals("judo::meta")
			}				

            return true
        }]);
    }

    def scope_FilterByVisibility(IScope scope, EReference ref, EObject context) {
        return new FilteringScope(scope, [desc | {
            val obj = desc.EObjectOrProxy

            switch obj {
                ModelDeclaration: return true
                ErrorDeclaration: return true
                TypeDeclaration: return true
                FunctionDeclaration: return context instanceof FunctionOrQueryCall || context instanceof Navigation
                QueryDeclaration: return obj.entity === null || context instanceof FunctionOrQueryCall || context instanceof Navigation
                LambdaDeclaration: return true
                AnnotationDeclaration: return true
                TransferFieldDeclaration: return true
                ActorMenuDeclaration: return true

                LambdaVariable: return context.parentContainer(LambdaCall).isEqual(obj.eContainer)
                ParameterDeclaration: return context.parentContainer(ParameterDeclaration) === null && (context.isEqual(obj.eContainer) || EcoreUtil2.getAllContainers(context).exists[c | c.isEqual(obj.eContainer)])
                EntityMapDeclaration: return context.isEqual(obj.eContainer) || EcoreUtil2.getAllContainers(context).exists[c | c.isEqual(obj.eContainer)]
                AnnotationParameterDeclaration: return EcoreUtil2.getAllContainers(context).exists[c | c.isEqual(obj.eContainer)]
            }

            return false;
        }]);
    }

    def scope_EntityRelationOppositeReferenced_oppositeType(EntityRelationOpposite context, EReference ref) {
        val entityRelationDeclaration = context.eContainer as EntityRelationDeclaration

        if (context.eContainer !== null && entityRelationDeclaration.isResolvedReference(JsldslPackage.ENTITY_MEMBER_DECLARATION__REFERENCE_TYPE)) {
	        val scope = new AtomicReference<IScope>(getLocalElementsScope(IScope.NULLSCOPE, entityRelationDeclaration.referenceType as EntityDeclaration, ref))
	        return scope.get
        } else {
            return IScope.NULLSCOPE
        }
    }

    def getEntityRelationOppositeInjected(IScope parent, EntityDeclaration entity, EReference reference) {
        val scope = new AtomicReference<IScope>(parent)

        entity.getVisibleEObjectDescriptions(JsldslPackage::eINSTANCE.entityRelationOppositeInjected)
            .filter[d | entity?.fullyQualifiedName?.equals(entity?.getResolvedProxy(d)?.eContainer.referenceTypeFromIndex?.fullyQualifiedName)]
            .forEach[d | {
                scope.set(getLocalElementsScope(scope.get, entity.getResolvedProxy(d).eContainer, reference))
            }]

        scope.get

    }

    def IScope getLocalElementsScope(IScope parent, EObject context, EReference reference) {
        var IScope result = parent;
        if (context === null || context.eResource === null) {
            return parent
        }
        val ISelectable allDescriptions = getAllDescriptions(context.eResource());
        val QualifiedName name = context.fullyQualifiedName  //getQualifiedNameOfLocalElement(context);
        val boolean ignoreCase = false;
        if (name !== null) {
            val ImportNormalizer localNormalizer = doCreateImportNormalizer(name, true, ignoreCase);
            result = createImportScope(result, singletonList(localNormalizer), allDescriptions, reference.getEReferenceType(), ignoreCase);
        }
        return result;
    }

    def IScope getEntityMembers(IScope parent, EntityDeclaration entity, EReference reference, List<EntityDeclaration> visited) {
        if (entity === null || visited.contains(entity)) return IScope.NULLSCOPE;
        visited.add(entity);

        val scope = new AtomicReference<IScope>(getLocalElementsScope(parent, entity, reference))
        scope.set(getEntityRelationOppositeInjected(scope.get, entity, reference))
        entity.extends.forEach[e | {
            scope.set(getEntityMembers(scope.get, e, reference, visited))
        }]
        return scope.get
    }

    def EObject getReferenceTypeFromIndex(EObject object) {
        if (object !== null && object.eContainer !== null) {
            var EObject resolved = null
            
            switch object {
            	EntityMemberDeclaration: resolved = object.eGet(JsldslPackage::eINSTANCE.entityMemberDeclaration_ReferenceType, true) as EObject
                QueryDeclaration: resolved = object.eGet(JsldslPackage::eINSTANCE.queryDeclaration_ReferenceType, true) as EObject
            }
            if (resolved !== null) {
                return resolved
            }
        }
        null
    }

    def ISelectable getAllDescriptions(Resource resource) {
        return cache.get("jslDslGetAllDescriptions", resource, new Provider<ISelectable>() {
            override ISelectable get() {
                return internalGetAllDescriptions(resource);
            }
        });
    }

    def ISelectable internalGetAllDescriptions(Resource resource) {
        val Iterable<EObject> allContents = new Iterable<EObject>(){
            override Iterator<EObject> iterator() {
                return EcoreUtil.getAllContents(resource, false);
            }
        };
        val Iterable<IEObjectDescription> allDescriptions = Scopes.scopedElementsFor(allContents, qualifiedNameProvider);
        return new MultimapBasedSelectable(allDescriptions);
    }

    def ImportNormalizer doCreateImportNormalizer(QualifiedName importedNamespace, boolean wildcard, boolean ignoreCase) {
        return new ImportNormalizer(importedNamespace, wildcard, ignoreCase);
    }

    def ImportScope createImportScope(IScope parent, List<ImportNormalizer> namespaceResolvers, ISelectable importFrom, EClass type, boolean ignoreCase) {
        return new ImportScope(namespaceResolvers, parent, importFrom, type, ignoreCase);
    }

    def EObject getResolvedProxy(EObject context, IEObjectDescription description) {
          return getResolvedProxy(context, description.EObjectOrProxy)
    }

    def EObject getResolvedProxy(EObject context, EObject objectOrProxy) {
        var proxy = objectOrProxy
          if (proxy !== null && proxy.eIsProxy()) {
              proxy = EcoreUtil.resolve(proxy, context);
        }
          return proxy;
    }

    def void printParents(EObject obj) {
        var EObject t = obj;
        var int indent = 1
        while (t.eContainer !== null) {
            for (var i = 0; i<indent; i++) {
                System.out.print("\t");
            }
            indent ++
            System.out.println("\u001B[0;3" + String.valueOf((indent % 6) + 1) + "m" + t)
            t = t.eContainer
        }
        System.out.println("\u001B[0m")
    }
}
