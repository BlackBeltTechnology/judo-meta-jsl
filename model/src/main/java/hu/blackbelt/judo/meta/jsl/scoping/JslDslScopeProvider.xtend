package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration
import org.eclipse.xtext.scoping.Scopes
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension
import com.google.inject.Inject
import org.eclipse.xtext.scoping.IScope
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOpposite
import hu.blackbelt.judo.meta.jsl.jsldsl.ThrowParameter
import hu.blackbelt.judo.meta.jsl.jsldsl.CreateError
import hu.blackbelt.judo.meta.jsl.jsldsl.Feature
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryParameter
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumLiteralReference
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaVariable
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityQueryDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationBaseReference
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryDeclarationParameter
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityMemberDeclaration
import java.util.Collection
import hu.blackbelt.judo.meta.jsl.jsldsl.ErrorField
import java.util.List
import org.eclipse.xtext.naming.IQualifiedNameProvider
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration
import org.eclipse.emf.ecore.EClass
import org.eclipse.xtext.scoping.impl.SelectableBasedScope
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
import com.google.common.cache.CacheLoader
import com.google.common.cache.LoadingCache
import com.google.common.cache.CacheBuilder
import java.time.Duration
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionedExpression
import org.eclipse.xtext.scoping.impl.FilteringScope
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionCall
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaFunction
import hu.blackbelt.judo.meta.jsl.jsldsl.InstanceFunction
import hu.blackbelt.judo.meta.jsl.jsldsl.Expression
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationExpression
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryCallExpression
import hu.blackbelt.judo.meta.jsl.jsldsl.SelfExpression
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationBaseExpression
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDerivedDeclaration

class JslDslScopeProvider extends AbstractJslDslScopeProvider {

	@Inject extension JslDslModelExtension
	@Inject extension JslDslIndex
	@Inject extension IQualifiedNameProvider

	@Inject IResourceScopeCache cache = IResourceScopeCache.NullImpl.INSTANCE;
	@Inject IQualifiedNameProvider qualifiedNameProvider

    override getScope(EObject context, EReference ref) {
    	System.out.println("\u001B[0;32mJslDslLocalScopeProvider - Reference target: " + ref.EReferenceType.name + "\n\tdef scope_" + ref.EContainingClass.name + "_" + ref.name + "(" + context.eClass.name + " context, EReference ref)" +
    		"\n\t" + context.eClass.name + " case ref == JsldslPackage::eINSTANCE." + ref.EContainingClass.name.toFirstLower + "_" + ref.name.toFirstUpper 
    			+ ": return context.scope_" + ref.EContainingClass.name + "_" + ref.name + "(ref)\u001B[0m")
    	printParents(context)
    	
    	switch context {    		
    		EntityDerivedDeclaration case ref == JsldslPackage::eINSTANCE.navigationBaseExpression_NavigationBaseType: return context.scope_NavigationBaseExpression_navigationBaseType(ref)
    		CreateError case ref == JsldslPackage::eINSTANCE.throwParameter_ErrorFieldType: return context.scope_ThrowParameter_errorFieldType(ref)
    		ThrowParameter case ref == JsldslPackage::eINSTANCE.throwParameter_ErrorFieldType: return context.scope_ThrowParameter_errorFieldType(ref)
    		ErrorField case ref == JsldslPackage::eINSTANCE.errorField_ReferenceType: return context.scope_ErrorField_referenceType(ref)
    		QueryParameter case ref == JsldslPackage::eINSTANCE.queryParameter_Parameter: return context.scope_QueryParameter_parameter(ref)
    		QueryCallExpression case ref == JsldslPackage::eINSTANCE.queryParameter_QueryParameterType: return context.scope_QueryParameter_queryParameterType(ref)
    		EntityRelationOpposite case ref == JsldslPackage::eINSTANCE.entityRelationOpposite_OppositeType: return context.scope_EntityRelationOpposite_oppositeType(ref)
			EntityQueryDeclaration case ref == JsldslPackage::eINSTANCE.entityQueryDeclaration_ReferenceType: return context.scope_EntityQueryDeclaration_referenceType(ref)
    		Feature case ref == JsldslPackage::eINSTANCE.feature_NavigationTargetType: return context.scope_Feature_navigationTargetType(ref)
    		QueryParameter case ref == JsldslPackage::eINSTANCE.queryParameter_QueryParameterType: return context.scope_QueryParameter_queryParameterType(ref)
    		Feature case ref == JsldslPackage::eINSTANCE.queryParameter_QueryParameterType: return context.scope_QueryParameter_queryParameterType(ref)    		
    		EnumLiteralReference case ref == JsldslPackage::eINSTANCE.enumLiteralReference_EnumLiteral: return context.scope_EnumLiteralReference_enumLiteral(ref)
			QueryDeclaration case ref == JsldslPackage::eINSTANCE.queryDeclarationParameter_ReferenceType: return context.scope_QueryDeclarationParameter_referenceType(ref)
    	}
    	super.getScope(context, ref)	
	}
	
	def scope_NavigationBaseExpression_navigationBaseType(EntityDerivedDeclaration context, EReference ref) {
		delegateGetScope(context, ref).filterLambdaVariable(context)
	}
		
	def scope_QueryParameter_queryParameterType(QueryCallExpression context, EReference ref) {
		nullSafeScope((context.queryDeclarationType as QueryDeclaration).parameters)
	}

	def scope_ErrorField_referenceType(ErrorField context, EReference ref) {
		super.getScope(context, ref)
	}

	def scope_QueryDeclarationParameter_referenceType(QueryDeclarationParameter context, EReference ref) {
		nullSafeScope((context.eContainer as EntityQueryDeclaration).parameters)
	}

	def scope_QueryDeclarationParameter_referenceType(QueryDeclaration context, EReference ref) {
    	val ret = super.getScope(context, ref)	
    	return ret		
	}

	def scope_EntityQueryDeclaration_referenceType(EntityQueryDeclaration context, EReference ref) {
    	val ret = super.getScope(context, ref)	
    	return ret
	}

	def IScope filterLambdaVariable(IScope parent, EObject context) {
		return new FilteringScope(parent, [desc | {
			val obj = desc.EObjectOrProxy
			if (obj instanceof LambdaVariable) {
				return false								
			}
			true
		}]);
	}

	def IScope filterSameParentDeclaration(IScope parent, EObject context) {
		return new FilteringScope(parent, [desc | {
			val obj = desc.EObjectOrProxy
			val fieldDecl = context.parentContainer(EntityMemberDeclaration)			
			if (fieldDecl !== null && fieldDecl === obj.parentContainer(EntityMemberDeclaration)){
				return false
			} else {
				val queryDecl = context.parentContainer(QueryDeclaration)			
				if (queryDecl !== null && queryDecl === obj.parentContainer(QueryDeclaration)){
					return false
				}
			}
			true
		}]);
	}


	def getProcessingFeature(Feature context, List<Feature> features) {
		var Feature featureToScope = null
		val contextIndex = features.indexOf(context) - 1
		if (contextIndex > -1) {
			featureToScope = features.get(contextIndex)
		}			
		return featureToScope
	}

	// Feature have to be cahed, because on every feature the previous features 
	// are re-scoped. To avoid recursion caching it for 15 sec
	def internal_scope_Feature_navigationTargetType(Feature context, EReference ref) {
		if (context.eContainer instanceof SelfExpression) {
			val selfExpression = context.eContainer as SelfExpression
			var featureToScope = context.getProcessingFeature(selfExpression.features)
			if (featureToScope !== null && featureToScope.navigationTargetType !== null) {
				if (featureToScope.navigationTargetType instanceof EntityMemberDeclaration) {
					return nullSafeScope(getNavigationDeclarationReferences(IScope.NULLSCOPE, 
						getResolvedProxy(selfExpression, featureToScope.navigationTargetType) as EntityMemberDeclaration, ref))
						.filterLambdaVariable(selfExpression).filterSameParentDeclaration(selfExpression)
				}
			} else {
				val entity = context.parentContainer(EntityDeclaration)
				val entityMembers = getEntityMembers(IScope.NULLSCOPE, entity, ref)
				return nullSafeScope(entityMembers)
			}		
		} else if (context.eContainer instanceof NavigationBaseExpression) {
			val navigationBase = context.eContainer as NavigationBaseExpression
			var featureToScope = context.getProcessingFeature(navigationBase.features)
			if (featureToScope !== null && featureToScope.navigationTargetType !== null) {
				if (featureToScope.navigationTargetType instanceof EntityMemberDeclaration) {
					return nullSafeScope(getNavigationDeclarationReferences(IScope.NULLSCOPE, 
						getResolvedProxy(navigationBase, featureToScope.navigationTargetType) as EntityMemberDeclaration, ref))
						.filterLambdaVariable(navigationBase).filterSameParentDeclaration(navigationBase)
				}
			} else {
				return getNavigationBaseTypeReferences(IScope.NULLSCOPE, navigationBase, ref)				
						.filterLambdaVariable(navigationBase).filterSameParentDeclaration(navigationBase)
			}		
		} else if (context.eContainer !== null && context.eContainer instanceof FunctionCall) {
			val functionCall = context.eContainer as FunctionCall
			var featureToScope = context.getProcessingFeature(functionCall.features)
			if (featureToScope !== null && featureToScope.navigationTargetType !== null) {
				if (featureToScope.navigationTargetType instanceof EntityMemberDeclaration) {
					return nullSafeScope(getNavigationDeclarationReferences(IScope.NULLSCOPE, 
						getResolvedProxy(functionCall, featureToScope.navigationTargetType) as EntityMemberDeclaration, ref))
				}
			} else {
				return getFunctionCallReferences(IScope.NULLSCOPE, context.eContainer as FunctionCall, ref)
			}		
		}
		IScope.NULLSCOPE	
	}

	val CacheLoader<Pair<Feature, EReference>, AtomicReference<IScope>> featureCacheLoader = new CacheLoader<Pair<Feature, EReference>, AtomicReference<IScope>>() {
        override AtomicReference<IScope> load(Pair<Feature, EReference> key) {
			return new AtomicReference
        }
    };
   	val LoadingCache<Pair<Feature, EReference>, AtomicReference<IScope>> featureCache = CacheBuilder.newBuilder()
   			.expireAfterAccess(Duration.ofSeconds(15))
   			.build(featureCacheLoader);
    

	
	def scope_Feature_navigationTargetType(Feature context, EReference ref) {
		val cacheRef = featureCache.get(new Pair(context, ref))
		if (cacheRef.get === null) {
			cacheRef.set(IScope.NULLSCOPE)
			cacheRef.set(internal_scope_Feature_navigationTargetType(context, ref))
		}
		return cacheRef.get
	}
		
		
	def scope_EntityRelationOpposite_oppositeType(EntityRelationOpposite context, EReference ref) {
		nullSafeScope(getEntityMembers(IScope.NULLSCOPE, (context.eContainer as EntityRelationDeclaration).referenceType, ref))
	}
	
	def scope_EnumLiteralReference_enumLiteral(EnumLiteralReference context, EReference ref) {
		nullSafeScope(context.enumDeclaration.literals)		
	}
	
	def scope_ThrowParameter_errorFieldType(CreateError context, EReference ref) {
		nullSafeScope(context.errorDeclarationType.fields)
	}
	def scope_ThrowParameter_errorFieldType(ThrowParameter context, EReference ref) {
		nullSafeScope((context.eContainer as CreateError).errorDeclarationType.fields)
	}

	def scope_QueryParameter_queryParameterType(QueryParameter context, EReference ref) {
    	var container = context.eContainer
		if (container instanceof Feature) {
			// System.out.println("=> QueryParameterType.Feature - QD: " + container.parentContainer(QueryDeclaration) + "  EDQ:" + container.parentContainer(EntityQueryDeclaration))
			nullSafeScope(container.queryDeclarationParameters)
		} else if (container instanceof QueryCallExpression) {
//			// System.out.println("=> QueryParameterType.QueryCal - Ref: " + container.queryDeclarationReference + "QD: " + container.parentContainer(QueryDeclaration) + "  EDQ:" + container.parentContainer(EntityQueryDeclaration))
			nullSafeScope((container.queryDeclarationType as QueryDeclaration).parameters)
		}		
	}

	def scope_QueryParameter_queryParameterType(Feature context, EReference ref) {
		// System.out.println("=> QueryParameterType.Feature - QD: " + container.parentContainer(QueryDeclaration) + "  EDQ:" + container.parentContainer(EntityQueryDeclaration))
		nullSafeScope(context.queryDeclarationParameters)
	}

	def scope_QueryParameter_parameter(QueryParameter context, EReference ref) {
    	var container = context.eContainer
		if (container instanceof Feature) {
			//System.out.println("=> QueryParameter.Feature - QD: " + container.parentContainer(QueryDeclaration) + "  EDQ:" + container.parentContainer(EntityQueryDeclaration))
			nullSafeScope(container.parentQueryDeclarationParameters)
		} else if (container instanceof QueryCallExpression) {
//			//System.out.println("=> QueryParameter.QueryCal - Ref: " + container.queryDeclarationReference + "QD: " + container.parentContainer(QueryDeclaration) + "  EDQ:" + container.parentContainer(EntityQueryDeclaration))
			nullSafeScope(container.parentQueryDeclarationParameters)
		}
	}
	

	def IScope getEntityMembers(IScope parent, EntityDeclaration entity, EReference reference) {
		val scope = new AtomicReference<IScope>(getLocalElementsScope(parent, entity, reference))
		entity.extends.forEach[e | {
			scope.set(getLocalElementsScope(scope.get, e, reference))
		}]		
		scope.get
	}

	def IScope getNavigationBaseTypeReferences(IScope parent, NavigationExpression navigationExpression, EReference reference) {
		if (navigationExpression instanceof SelfExpression) {
			val entity = navigationExpression.parentContainer(EntityDeclaration)
			val entityMembers = getEntityMembers(IScope.NULLSCOPE, entity, reference)
			return nullSafeScope(entityMembers)
		} else if (navigationExpression instanceof NavigationBaseExpression) {
			return nullSafeScope(getNavigationBaseReferences(IScope.NULLSCOPE, (navigationExpression as NavigationBaseExpression).navigationBaseType, reference))
		} else if (navigationExpression instanceof QueryCallExpression) {
			val queryDeclarationReferenceType = getResolvedProxy(navigationExpression as QueryCallExpression, (navigationExpression as QueryCallExpression).queryDeclarationType?.referenceType)
			if (queryDeclarationReferenceType !== null && queryDeclarationReferenceType instanceof EntityDeclaration) {
				return nullSafeScope(getEntityMembers(IScope.NULLSCOPE, queryDeclarationReferenceType as EntityDeclaration, reference))			
			}
		}
		IScope.NULLSCOPE
	}

	def IScope getFunctionCallReferences(IScope parent, FunctionCall functionCall, EReference reference) {
		if (functionCall.function instanceof InstanceFunction) {
			return getEntityMembers(IScope.NULLSCOPE, (functionCall.function as InstanceFunction).entityDeclaration, reference)
		} else if (functionCall.function instanceof LambdaFunction) {
			if (functionCall.eContainer instanceof FunctionedExpression) {
				return getFunctionedExpressionReferences(IScope.NULLSCOPE, functionCall.eContainer as FunctionedExpression, reference)
			} else if (functionCall.eContainer instanceof FunctionCall) {
				return getFunctionCallReferences(parent, functionCall.eContainer as FunctionCall, reference)
			}			
		}
		IScope.NULLSCOPE		
	}

	def IScope getFunctionedExpressionReferences(IScope parent, FunctionedExpression functionedExpression, EReference reference) {
		if (functionedExpression !== null && functionedExpression.operand instanceof SelfExpression) {
			val selfExpression = functionedExpression.operand as SelfExpression	
			if (selfExpression.features.last?.navigationTargetType !== null) {
				if (selfExpression.features.last.navigationTargetType instanceof EntityMemberDeclaration) {
					return nullSafeScope(getNavigationDeclarationReferences(IScope.NULLSCOPE, 
						getResolvedProxy(selfExpression, selfExpression.features.last.navigationTargetType) as EntityMemberDeclaration, reference))						
				}
			} else {
				val entity = selfExpression.parentContainer(EntityDeclaration)
				return getEntityMembers(IScope.NULLSCOPE, entity, reference)
			}

		} else if (functionedExpression !== null && functionedExpression.operand instanceof NavigationBaseExpression) {
			val navigationBase = functionedExpression.operand as NavigationBaseExpression
			if (navigationBase.features.last?.navigationTargetType !== null) {
				if (navigationBase.features.last.navigationTargetType instanceof EntityMemberDeclaration) {
					return nullSafeScope(getNavigationDeclarationReferences(IScope.NULLSCOPE, 
						getResolvedProxy(navigationBase, navigationBase.features.last.navigationTargetType) as EntityMemberDeclaration, reference))						
				}
			} else {
				return getNavigationBaseTypeReferences(parent, navigationBase, reference)
			}
		}
		IScope.NULLSCOPE		
	}

	def IScope getNavigationBaseReferences(IScope parent, NavigationBaseReference navigationBaseReference, EReference reference) {
		if (navigationBaseReference instanceof EntityDeclaration) {
			return getEntityMembers(parent, navigationBaseReference as EntityDeclaration, reference)
		} else if (navigationBaseReference instanceof LambdaVariable) {
			return getFunctionCallReferences(parent, navigationBaseReference.parentContainer(FunctionCall), reference)
		}
		IScope.NULLSCOPE
	}
	
	def EObject getReferenceTypeFromIndex(EObject object) {
		if (object !== null && object.eContainer !== null) {
			val descriptor = object.EObjectDescription
			if (descriptor !== null) {
				val type = descriptor.getUserData("referenceType")
				val referenceDesc = object.getEObjectDescriptionByName(type)
				if (referenceDesc !== null) {
					return referenceDesc.EObjectOrProxy				
				}
			}
		}
		null
	}
	
	def IScope getNavigationDeclarationReferences(IScope parent, EntityMemberDeclaration entityMemberDeclaration, EReference reference) {
		val referenceType = getReferenceTypeFromIndex(entityMemberDeclaration)
		if (referenceType !== null) {
			val resolvedProxy = getResolvedProxy(entityMemberDeclaration, referenceType)
			switch referenceType {
				EntityDeclaration: return nullSafeScope(getEntityMembers(parent, resolvedProxy as EntityDeclaration, reference))
				EntityQueryDeclaration case (resolvedProxy as EntityQueryDeclaration).referenceType instanceof EntityDeclaration: {
					return nullSafeScope(getEntityMembers(parent, (resolvedProxy as EntityQueryDeclaration).referenceType as EntityDeclaration, reference))
				}
			}	
		}
		IScope.NULLSCOPE		
	}


	def Collection<QueryDeclarationParameter> queryDeclarationParameters(EObject feature) {
		if (feature instanceof Feature) {
			if (feature === null || feature.navigationTargetType === null) {
				return null
			} else if (feature.navigationTargetType instanceof EntityQueryDeclaration) {
				return (feature.navigationTargetType as EntityQueryDeclaration).parameters						
			}			
		}
		null
	}

	def Collection<QueryDeclarationParameter> parentQueryDeclarationParameters(EObject feature) {
		if (feature !== null) {
			val queryDeclaration = feature.parentContainer(QueryDeclaration)
			if (queryDeclaration !== null) {
				return queryDeclaration.parameters
			} else {
				val entityQueryDeclaration = feature.parentContainer(EntityQueryDeclaration)
				if (entityQueryDeclaration !== null) {
					return entityQueryDeclaration.parameters
				}				
			}
		} 
		return null		
	}

	def IScope getResourceScope(IScope parent, EObject context, EReference reference) {
		if (context.eResource() === null)
			return parent;
		val ISelectable allDescriptions = getAllDescriptions(context.eResource());
		return SelectableBasedScope.createScope(parent, allDescriptions, reference.getEReferenceType(), false);
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
	
	def IScope nullSafeScope(Object input) {
		nullSafeScope(input, IScope.NULLSCOPE)
	}

	
	def IScope nullSafeScope(Object input, IScope fallback) {
		if (input === null) {
			return fallback
		}
		if (input instanceof IScope) {
			return input
		} else if (input instanceof Iterable) {
			if (input.size > 0) {
				return Scopes.scopeFor(input, fallback)
			} else {
				return fallback
			}
		} else if (input instanceof EObject) {
			return Scopes.scopeFor(#[input], fallback)
		} else {
			throw new IllegalArgumentException("Only EObject or Iterable is accepted")
		}
	}
}
