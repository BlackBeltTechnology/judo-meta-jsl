package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration
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
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDerivedDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityIdentifierDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeReferenced
import hu.blackbelt.judo.meta.jsl.jsldsl.Navigation
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaDeclaration
import hu.blackbelt.judo.meta.jsl.runtime.TypeInfo
import hu.blackbelt.judo.meta.jsl.jsldsl.MemberReference
import hu.blackbelt.judo.meta.jsl.jsldsl.TypeDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.Call
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeInjected
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityQueryCall
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionCall
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionArgument
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryCall
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryArgument
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryParameterDeclaration
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
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ServiceOperationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferField
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewField

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
        scope = this.scope_FilterByReferenceType(scope, ref);
        scope = this.scope_FilterByVisibility(scope, context);

        switch context {
            EntityRelationOppositeReferenced case ref == JsldslPackage::eINSTANCE.entityRelationOppositeReferenced_OppositeType: return context.scope_EntityRelationOppositeReferenced_oppositeType(ref)
            MemberReference case ref == JsldslPackage::eINSTANCE.memberReference_Member: return this.scope_Navigation(scope, ref, TypeInfo.getTargetType(context))
            EnumLiteralReference case ref == JsldslPackage::eINSTANCE.enumLiteralReference_EnumLiteral: return scope.scope_Containments(context.enumDeclaration, ref)

            Call case ref == JsldslPackage::eINSTANCE.lambdaCall_Declaration: return this.scope_Navigation(scope, ref, TypeInfo.getTargetType(context))
            Call case ref == JsldslPackage::eINSTANCE.functionCall_Declaration: return this.scope_Navigation(scope, ref, TypeInfo.getTargetType(context))
            Call case ref == JsldslPackage::eINSTANCE.entityQueryCall_Declaration: return this.scope_Navigation(scope, ref, TypeInfo.getTargetType(context))
            Call case ref == JsldslPackage::eINSTANCE.memberReference_Member: return this.scope_Navigation(scope, ref, TypeInfo.getTargetType(context))

            QueryCall case ref == JsldslPackage::eINSTANCE.functionCall_Declaration: return this.scope_Navigation(scope, ref, TypeInfo.getTargetType(context))
            QueryCall case ref == JsldslPackage::eINSTANCE.lambdaCall_Declaration: return this.scope_Navigation(scope, ref, TypeInfo.getTargetType(context))
            QueryCall case ref == JsldslPackage::eINSTANCE.entityQueryCall_Declaration: return this.scope_Navigation(scope, ref, TypeInfo.getTargetType(context))
            QueryCall case ref == JsldslPackage::eINSTANCE.memberReference_Member: return this.scope_Navigation(scope, ref, TypeInfo.getTargetType(context))

            FunctionCall case ref == JsldslPackage::eINSTANCE.functionArgument_Declaration: return scope.scope_Containments(context.declaration, ref)
            EntityQueryCall case ref == JsldslPackage::eINSTANCE.queryArgument_Declaration: return scope.scope_Containments(context.declaration, ref)
            QueryCall case ref == JsldslPackage::eINSTANCE.queryArgument_Declaration: return scope.scope_Containments(context.declaration, ref)
            AnnotationMark case ref == JsldslPackage::eINSTANCE.annotationArgument_Declaration: return scope.scope_Containments(context.declaration, ref)

            QueryArgument case ref == JsldslPackage::eINSTANCE.queryArgument_Declaration && context.eContainer instanceof EntityQueryCall: return scope.scope_Containments((context.eContainer as EntityQueryCall).declaration, ref)
            QueryArgument case ref == JsldslPackage::eINSTANCE.queryArgument_Declaration && context.eContainer instanceof QueryCall: return scope.scope_Containments((context.eContainer as QueryCall).declaration, ref)
            FunctionArgument case ref == JsldslPackage::eINSTANCE.functionArgument_Declaration: return scope.scope_Containments((context.eContainer as FunctionCall).declaration, ref)
            AnnotationArgument case ref == JsldslPackage::eINSTANCE.annotationArgument_Declaration && context.eContainer instanceof AnnotationMark: return scope.scope_Containments((context.eContainer as AnnotationMark).declaration, ref)

			ViewField case ref == JsldslPackage::eINSTANCE.viewField_Declaration: return scope.scope_ViewContainments(context.eContainer.eContainer.eContainer, ref)

            Navigation: return this.scope_Navigation(scope, ref, TypeInfo.getTargetType(context))
        }

        return scope
    }

	def scope_ViewContainments(IScope scope, EObject context, EReference ref) {
        return new FilteringScope(scope.getLocalElementsScope(context, ref), [desc | {
            return EcoreUtil2.getAllContainers(desc.EObjectOrProxy).exists[c | c.isEqual(context)]
        }]);
    }

    def scope_Containments(IScope scope, EObject context, EReference ref) {
        return new FilteringScope(scope.getLocalElementsScope(context, ref), [desc | {
            return desc.EObjectOrProxy.eContainer.isEqual(context)
        }]);
    }

    def scope_Navigation(IScope scope, EReference ref, TypeInfo navigationTypeInfo) {
        var IScope navigationScope

        if (navigationTypeInfo.isEntity) {
            navigationScope = this.getEntityMembers(scope, navigationTypeInfo.getEntity, ref, new ArrayList<EntityDeclaration>())

            navigationScope = new FilteringScope(navigationScope, [desc | {
                val obj = desc.EObjectOrProxy

                switch obj {
                    EntityMemberDeclaration: return (navigationTypeInfo.isCollection && TypeInfo.getTargetType(obj).isPrimitive) ? false : true
                    EntityRelationOppositeInjected: return !navigationTypeInfo.getEntity.isEqual(obj.eContainer.eContainer)
                    FunctionDeclaration: obj.baseType !== null && navigationTypeInfo.isBaseCompatible(TypeInfo.getTargetType(obj.baseType)) ? return true : return false
                    LambdaDeclaration: navigationTypeInfo.isEntity() && navigationTypeInfo.isCollection() ? return true : return false
                }

                return false
            }]);
        } else {
            navigationScope = new FilteringScope(scope, [desc | {
                val obj = desc.EObjectOrProxy

                switch obj {
                    FunctionDeclaration: obj.baseType !== null && navigationTypeInfo.isBaseCompatible(TypeInfo.getTargetType(obj.baseType)) ? return true : return false
                    LambdaDeclaration: navigationTypeInfo.isEntity() && navigationTypeInfo.isCollection() ? return true : return false
                }

                false
            }]);
        }

        return navigationScope
    }

    def scope_FilterByReferenceType(IScope scope, EReference ref) {
        return new FilteringScope(scope, [desc | {
            return ref.EReferenceType.isInstance(desc.EObjectOrProxy) ? true : false;
        }]);
    }

    def scope_FilterByVisibility(IScope scope, EObject context) {
        return new FilteringScope(scope, [desc | {
            val obj = desc.EObjectOrProxy

            switch obj {
                ModelDeclaration: return true
                TypeDeclaration: return true
                QueryDeclaration: return true
                FunctionDeclaration: return true
                LambdaDeclaration: return true
                ErrorDeclaration: return true
                AnnotationDeclaration: return true
                TransferFieldDeclaration: return true
                ViewFieldDeclaration: return true

                LambdaVariable: return context.parentContainer(LambdaCall).isEqual(obj.eContainer)
                QueryParameterDeclaration: return context.parentContainer(QueryParameterDeclaration) === null && (context.isEqual(obj.eContainer) || EcoreUtil2.getAllContainers(context).exists[c | c.isEqual(obj.eContainer)])
                EntityMapDeclaration: return context.isEqual(obj.eContainer) || EcoreUtil2.getAllContainers(context).exists[c | c.isEqual(obj.eContainer)]
                AnnotationParameterDeclaration: return EcoreUtil2.getAllContainers(context).exists[c | c.isEqual(obj.eContainer)]

                // ServiceOperationDeclaration: return context.parentContainer(ViewDeclaration).exports.exists[g | g.isEqual(obj.eContainer)]
            }

            return false;
        }]);
    }

    def scope_EntityRelationOppositeReferenced_oppositeType(EntityRelationOpposite context, EReference ref) {
        val entityRelationDeclaration = context.eContainer as EntityRelationDeclaration
        if (context.eContainer !== null && entityRelationDeclaration.isResolvedReference(JsldslPackage.ENTITY_RELATION_DECLARATION__REFERENCE_TYPE)) {
            getEntityMembers(IScope.NULLSCOPE, entityRelationDeclaration.referenceType, ref, new ArrayList<EntityDeclaration>())
        } else {
            return IScope.NULLSCOPE
        }
    }

    def getEntityRelationOppositeInjected(IScope parent, EntityDeclaration entity, EReference reference) {
        val scope = new AtomicReference<IScope>(parent)
        entity.getVisibleEObjectDescriptions(JsldslPackage::eINSTANCE.entityRelationDeclaration)
            .filter[d | d.getUserData("oppositeName") !== null]
            .filter[d | entity?.fullyQualifiedName?.toString?.equals(entity?.getResolvedProxy(d)?.referenceTypeFromIndex?.fullyQualifiedName?.toString)]
//            .filter[d | entity.fullyQualifiedName.toString.equals((entity.getResolvedProxy(d) as EntityRelationDeclaration).referenceType.fullyQualifiedName.toString)]
            .forEach[d | {
                scope.set(getLocalElementsScope(scope.get, entity.getResolvedProxy(d), reference))
            }]
        scope.get

    }

    def IScope getLocalElementsScope(IScope parent, EObject context, EReference reference) {
        var IScope result = parent;
        if (context.eResource === null) {
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
        if (visited.contains(entity)) return IScope.NULLSCOPE;
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
                EntityFieldDeclaration: resolved = object.eGet(JsldslPackage::eINSTANCE.entityFieldDeclaration_ReferenceType, true) as EObject
                EntityIdentifierDeclaration: resolved = object.eGet(JsldslPackage::eINSTANCE.entityIdentifierDeclaration_ReferenceType, true) as EObject
                EntityRelationDeclaration: resolved = object.eGet(JsldslPackage::eINSTANCE.entityRelationDeclaration_ReferenceType, true) as EObject
                EntityDerivedDeclaration: resolved = object.eGet(JsldslPackage::eINSTANCE.entityDerivedDeclaration_ReferenceType, true) as EObject
//                EntityQueryDeclaration: resolved = object.eGet(JsldslPackage::eINSTANCE.entityQueryDeclaration_ReferenceType, true) as EObject
                QueryDeclaration: resolved = object.eGet(JsldslPackage::eINSTANCE.queryDeclaration_ReferenceType, true) as EObject
            }
            if (resolved !== null) {
                return resolved
            }
//            val descriptor = object.EObjectDescription
//            if (descriptor !== null) {
//                val type = descriptor.getUserData("referenceType")
//                val referenceDesc = object.getEObjectDescriptionByName(type)
//                if (referenceDesc !== null) {
//                    return referenceDesc.EObjectOrProxy
//                }
//            }
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

//    def IScope nullSafeScope(Object input) {
//        nullSafeScope(input, IScope.NULLSCOPE)
//    }
//
//    def IScope nullSafeScope(Object input, IScope fallback) {
//        if (input === null) {
//            return fallback
//        }
//        if (input instanceof IScope) {
//            return input
//        } else if (input instanceof Iterable) {
//            if (input.size > 0) {
//                return Scopes.scopeFor(input, fallback)
//            } else {
//                return fallback
//            }
//        } else if (input instanceof EObject) {
//            return Scopes.scopeFor(#[input], fallback)
//        } else {
//            throw new IllegalArgumentException("Only EObject / Iterable / IScope are accepted")
//        }
//    }
}
