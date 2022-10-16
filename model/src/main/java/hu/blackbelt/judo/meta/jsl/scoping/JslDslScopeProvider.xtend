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
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionedExpression
import org.eclipse.xtext.scoping.impl.FilteringScope
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionCall
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaFunction
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationExpression
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryCallExpression
import hu.blackbelt.judo.meta.jsl.jsldsl.SelfExpression
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationBaseExpression
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDerivedDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaFunctionParameters
import hu.blackbelt.judo.meta.jsl.jsldsl.BinaryOperation
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.LiteralFunction
import hu.blackbelt.judo.meta.jsl.jsldsl.LiteralFunctionParameter
import hu.blackbelt.judo.meta.jsl.jsldsl.LiteralFunctionParameters
import hu.blackbelt.judo.meta.jsl.jsldsl.DefaultExpressionType
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityIdentifierDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeReferenced
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelImportDeclaration

class JslDslScopeProvider extends AbstractJslDslScopeProvider {

	@Inject extension JslDslModelExtension
	@Inject extension JslDslIndex
	@Inject extension IQualifiedNameProvider

	@Inject IResourceScopeCache cache = IResourceScopeCache.NullImpl.INSTANCE;
	@Inject IQualifiedNameProvider qualifiedNameProvider

    override getScope(EObject context, EReference ref) {
    	//System.out.println("\u001B[0;32mJslDslLocalScopeProvider - Reference target: " + ref.EReferenceType.name + "\n\tdef scope_" + ref.EContainingClass.name + "_" + ref.name + "(" + context.eClass.name + " context, EReference ref)" +
    	//  "\n\t" + context.eClass.name + " case ref == JsldslPackage::eINSTANCE." + ref.EContainingClass.name.toFirstLower + "_" + ref.name.toFirstUpper 
    	//     + ": return context.scope_" + ref.EContainingClass.name + "_" + ref.name + "(ref)\u001B[0m")
    	//printParents(context)
    	
    	switch context {
    		ModelImportDeclaration case ref == JsldslPackage::eINSTANCE.modelImportDeclaration_Model: return context.scope_ModelImportDeclaration_model(ref)
			EntityDeclaration case ref == JsldslPackage::eINSTANCE.entityFieldDeclaration_ReferenceType: return delegateGetScope(context, ref).filterType(FunctionDeclaration)
    		EntityDerivedDeclaration case ref == JsldslPackage::eINSTANCE.navigationBaseExpression_NavigationBaseType: return context.scope_NavigationBaseExpression_navigationBaseType(ref)
			EntityDerivedDeclaration case ref == JsldslPackage::eINSTANCE.queryCallExpression_QueryDeclarationType: return delegateGetScope(context, ref).filterType(FunctionDeclaration)
			EntityDerivedDeclaration case ref == JsldslPackage::eINSTANCE.enumLiteralReference_EnumDeclaration: return delegateGetScope(context, ref).filterType(FunctionDeclaration)
            EntityFieldDeclaration case ref == JsldslPackage::eINSTANCE.entityFieldDeclaration_ReferenceType: return delegateGetScope(context, ref).filterType(FunctionDeclaration)
			EntityIdentifierDeclaration case ref == JsldslPackage::eINSTANCE.entityIdentifierDeclaration_ReferenceType: return delegateGetScope(context, ref).filterType(FunctionDeclaration)
    		CreateError case ref == JsldslPackage::eINSTANCE.throwParameter_ErrorFieldType: return context.scope_ThrowParameter_errorFieldType(ref)
    		ThrowParameter case ref == JsldslPackage::eINSTANCE.throwParameter_ErrorFieldType: return context.scope_ThrowParameter_errorFieldType(ref)
    		QueryParameter case ref == JsldslPackage::eINSTANCE.queryParameter_Parameter: return context.scope_QueryParameter_parameter(ref)
    		QueryParameter case ref == JsldslPackage::eINSTANCE.queryParameter_QueryParameterType: return context.scope_QueryParameter_queryParameterType(ref)
    		QueryCallExpression case ref == JsldslPackage::eINSTANCE.queryParameter_QueryParameterType: return context.scope_QueryParameter_queryParameterType(ref)
    		EntityRelationOppositeReferenced case ref == JsldslPackage::eINSTANCE.entityRelationOppositeReferenced_OppositeType: return context.scope_EntityRelationOppositeReferenced_oppositeType(ref)
    		Feature case ref == JsldslPackage::eINSTANCE.feature_NavigationTargetType: return context.scope_Feature_navigationTargetType(ref)
    		Feature case ref == JsldslPackage::eINSTANCE.queryParameter_QueryParameterType: return context.scope_QueryParameter_queryParameterType(ref)    		
    		EnumLiteralReference case ref == JsldslPackage::eINSTANCE.enumLiteralReference_EnumLiteral: return context.scope_EnumLiteralReference_enumLiteral(ref)
    		LiteralFunction case ref == JsldslPackage::eINSTANCE.literalFunctionParameter_Declaration: return context.scope_LiteralFunctionParameter_declaration(ref)
			LiteralFunctionParameter case ref == JsldslPackage::eINSTANCE.literalFunctionParameter_Declaration: return context.scope_LiteralFunctionParameter_declaration(ref)
			LiteralFunctionParameters case ref == JsldslPackage::eINSTANCE.literalFunctionParameter_Declaration: return context.scope_LiteralFunctionParameter_declaration(ref)			
			LambdaFunction case ref == JsldslPackage::eINSTANCE.navigationBaseExpression_NavigationBaseType: return context.scope_NavigationBaseExpression_navigationBaseType(ref)
			LambdaFunction case ref == JsldslPackage::eINSTANCE.queryCallExpression_QueryDeclarationType: return delegateGetScope(context, ref).filterType(FunctionDeclaration)
			LambdaFunction case ref == JsldslPackage::eINSTANCE.enumLiteralReference_EnumDeclaration: return delegateGetScope(context, ref).filterType(FunctionDeclaration)
			DefaultExpressionType case ref == JsldslPackage::eINSTANCE.enumLiteralReference_EnumDeclaration: return delegateGetScope(context, ref).filterType(FunctionDeclaration)
			DefaultExpressionType case ref == JsldslPackage::eINSTANCE.queryCallExpression_QueryDeclarationType: return delegateGetScope(context, ref).filterType(FunctionDeclaration)
			DefaultExpressionType case ref == JsldslPackage::eINSTANCE.navigationBaseExpression_NavigationBaseType: return delegateGetScope(context, ref).filterType(FunctionDeclaration)
    		BinaryOperation: return context.scope_Expression(ref)
    		LambdaFunctionParameters: return context.scope_LambdaFunctionParameters(ref)

    	}
    	return super.getScope(context, ref)
	}

	def scope_ModelImportDeclaration_model(ModelImportDeclaration context, EReference ref) {
		nullSafeScope(super.getScope(context, ref))
	}

	def scope_LiteralFunctionParameter_declaration(LiteralFunction context, EReference ref) {
		nullSafeScope(context.functionDeclarationReference.parameterDeclarations)
	}
	
	def scope_LiteralFunctionParameter_declaration(LiteralFunctionParameter context, EReference ref) {
		nullSafeScope((context.eContainer as LiteralFunction).functionDeclarationReference.parameterDeclarations)			
	}
	
	def scope_LiteralFunctionParameter_declaration(LiteralFunctionParameters context, EReference ref) {
		nullSafeScope((context.eContainer as LiteralFunction).functionDeclarationReference.parameterDeclarations)					
	}
	
	def scope_LambdaFunctionParameters(LambdaFunctionParameters context, EReference ref) {
		getLambdaFunctionParametersReferences(getDefaultExpressionScope(context, ref), context, ref)
	}

	def scope_NavigationBaseExpression_navigationBaseType(LambdaFunction context, EReference ref) {
		nullSafeScope(#[context.lambdaArgument], delegateGetScope(context, ref)
			.filterType(FunctionDeclaration)
			.filterType(LambdaVariable)
		)
	}
	def scope_Expression(BinaryOperation context, EReference ref) {
		var operator = context;
		while (operator.eContainer instanceof BinaryOperation) {
			operator = operator.eContainer as BinaryOperation
		}
		
		if (operator.eContainer instanceof LambdaFunctionParameters) {
			return getLambdaFunctionParametersReferences(getDefaultExpressionScope(context, ref), operator.eContainer as LambdaFunctionParameters, ref)			
		} else if (operator.eContainer instanceof LambdaFunction) {
			return nullSafeScope(#[(operator.eContainer as LambdaFunction).lambdaArgument], delegateGetScope(context, ref)
				.filterType(FunctionDeclaration)
				.filterType(LambdaVariable))			
				.filterType(QueryDeclarationParameter)
	
		}
		return super.getScope(context, ref)
				.filterType(FunctionDeclaration)
				.filterType(QueryDeclarationParameter)
				.filterType(LambdaVariable);
	}
	
	def scope_NavigationBaseExpression_navigationBaseType(EntityDerivedDeclaration context, EReference ref) {
		delegateGetScope(context, ref)
			.filterType(QueryDeclarationParameter)
			.filterType(LambdaVariable)
			.filterType(FunctionDeclaration)
	}

	
	def scope_QueryParameter_queryParameterType(QueryCallExpression context, EReference ref) {
		nullSafeScope(context.queryDeclarationType.parameters)
	}

	def scope_QueryDeclarationParameter_referenceType(QueryDeclarationParameter context, EReference ref) {
		nullSafeScope((context.eContainer as EntityQueryDeclaration).parameters)
	}

	def scope_Feature_navigationTargetType(Feature context, EReference ref) {		
		if (context.eContainer instanceof SelfExpression) {
			return 
					getFeatureScopeForNavigationTargetTypeReferences(
						IScope.NULLSCOPE,
						getPreviousFeature(context, (context.eContainer as SelfExpression).features),
						context.eContainer as SelfExpression, 
						ref
					)
					.filterSameParentDeclaration(context.eContainer)
		    		.filterType(FunctionDeclaration)
					
		} else if (context.eContainer instanceof NavigationBaseExpression) {
			return 
					getFeatureScopeForNavigationTargetTypeReferences(
						IScope.NULLSCOPE,
						context.getPreviousFeature((context.eContainer as NavigationBaseExpression).features),
						context.eContainer as NavigationBaseExpression, 
						ref
					)
					.filterType(LambdaVariable)
		    		.filterType(FunctionDeclaration)
					.filterSameParentDeclaration(context.eContainer)
		} else if (context.eContainer !== null && context.eContainer instanceof FunctionCall) {
			return 
					getFunctionCallExpressionTargetTypeReferences(
						IScope.NULLSCOPE, 
						context.getPreviousFeature((context.eContainer as FunctionCall).features),
						context.eContainer as FunctionCall, 
						ref
					)
					.filterSameParentDeclaration(context.eContainer)
		    		.filterType(FunctionDeclaration)
		} else if (context.eContainer instanceof QueryCallExpression) {
			return
					getQueryCallExpressionTargetTypeReferences(
						IScope.NULLSCOPE, 
						context.getPreviousFeature((context.eContainer as QueryCallExpression).features),
						context.eContainer as QueryCallExpression, 
						ref
					)
					.filterSameParentDeclaration(context.eContainer)
		    		.filterType(FunctionDeclaration)
		}
		IScope.NULLSCOPE
	}
		
		
	def scope_EntityRelationOppositeReferenced_oppositeType(EntityRelationOpposite context, EReference ref) {
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
			nullSafeScope(container.featureQueryDeclarationParameters)
		} else if (container instanceof QueryCallExpression) {
			nullSafeScope(container.queryDeclarationType.parameters)
		}		
	}

	def scope_QueryParameter_queryParameterType(Feature context, EReference ref) {
		nullSafeScope(context.featureQueryDeclarationParameters)
	}

	def scope_QueryParameter_parameter(QueryParameter context, EReference ref) {
    	var container = context.eContainer
		if (container instanceof Feature) {
			nullSafeScope(container.parentQueryDeclarationParameters)
		} else if (container instanceof QueryCallExpression) {
			nullSafeScope(container.parentQueryDeclarationParameters)
		}
	}
	
	def filterType(IScope parent, Class<?> type) {
		return new FilteringScope(parent, [desc | {
			val obj = desc.EObjectOrProxy
			if (type.isAssignableFrom(obj.class)) {
				return false								
			}
			true
		}]);
	}

	
	def typeOnly(IScope parent, Class<?> type) {
		return new FilteringScope(parent, [desc | {
			val obj = desc.EObjectOrProxy
			if (type.isAssignableFrom(obj.class)) {
				return true								
			}
			false
		}]);
	}


	def filterSameParentDeclaration(IScope parent, EObject context) {
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


	def getPreviousFeature(Feature context, List<Feature> features) {
		var Feature featureToScope = null
		val contextIndex = features.indexOf(context) - 1
		if (contextIndex > -1) {
			featureToScope = features.get(contextIndex)
		}			
		return featureToScope
	}
	
	def getEntityRelationOppositeInjected(IScope parent, EntityDeclaration entity, EReference reference) {
		val scope = new AtomicReference<IScope>(parent)
		entity.getVisibleEObjectDescriptions(JsldslPackage::eINSTANCE.entityRelationDeclaration)
			.filter[d | d.getUserData("oppositeName") !== null]
			.filter[d | entity.fullyQualifiedName.toString.equals(entity.getResolvedProxy(d)?.referenceTypeFromIndex?.fullyQualifiedName?.toString)]
//			.filter[d | entity.fullyQualifiedName.toString.equals((entity.getResolvedProxy(d) as EntityRelationDeclaration).referenceType.fullyQualifiedName.toString)]
			.forEach[d | {
				scope.set(getLocalElementsScope(scope.get, entity.getResolvedProxy(d), reference))
			}]
		scope.get

	}
	
	def getEntityMembers(IScope parent, EntityDeclaration entity, EReference reference) {
		val scope = new AtomicReference<IScope>(getLocalElementsScope(parent, entity, reference))
		scope.set(getEntityRelationOppositeInjected(scope.get, entity, reference))		
		entity.extends.forEach[e | {
			scope.set(getLocalElementsScope(scope.get, e, reference))
			scope.set(getEntityRelationOppositeInjected(scope.get, e, reference))
		}]		
		scope.get
	}

	def getQueryCallExpressionReferences(IScope parent, QueryCallExpression queryCallExpression, EReference reference) {
		val queryDeclarationReferenceType = getResolvedProxy(queryCallExpression, queryCallExpression.queryDeclarationType?.referenceType)
		if (queryDeclarationReferenceType !== null && queryDeclarationReferenceType instanceof EntityDeclaration) {
			return nullSafeScope(getEntityMembers(parent, queryDeclarationReferenceType as EntityDeclaration, reference))			
		}
		parent	
	}

	def getNavigationBaseReferences(IScope parent, NavigationBaseReference navigationBaseReference, EReference reference) {
		if (navigationBaseReference instanceof EntityDeclaration) {
			return getEntityMembers(parent, navigationBaseReference, reference)
		} else if (navigationBaseReference instanceof LambdaVariable) {
			return getFunctionCallReferences(parent, navigationBaseReference.parentContainer(FunctionCall), reference)
		}
		parent
	}

	def getFeatureScopeForNavigationTargetTypeReferences(IScope parent, Feature featureToScope, NavigationExpression navigationExpression, EReference ref) {
		if (featureToScope !== null && featureToScope.navigationTargetType !== null) {
			if (featureToScope.navigationTargetType instanceof EntityMemberDeclaration) {
				return nullSafeScope(getEntityMemberDeclarationReferences(parent, 
					getResolvedProxy(navigationExpression, featureToScope.navigationTargetType) as EntityMemberDeclaration, ref))
			}
		} else {
			return getNavigationExpressionReferences(parent, navigationExpression, ref)
		}
		parent				
	}

	def getFunctionCallExpressionTargetTypeReferences(IScope parent, Feature featureToScope, FunctionCall functionCall, EReference ref) {
		if (featureToScope !== null && featureToScope.navigationTargetType !== null) {
			if (featureToScope.navigationTargetType instanceof EntityMemberDeclaration) {
				return nullSafeScope(getEntityMemberDeclarationReferences(parent, 
					getResolvedProxy(functionCall, featureToScope.navigationTargetType) as EntityMemberDeclaration, ref))
			}
		} else {
			return getFunctionCallReferences(parent, functionCall, ref)
		}		
		parent				
	}

	def getQueryCallExpressionTargetTypeReferences(IScope parent, Feature featureToScope, QueryCallExpression queryCallExpression, EReference ref) {
		if (featureToScope !== null && featureToScope.navigationTargetType !== null) {
			if (featureToScope.navigationTargetType instanceof EntityMemberDeclaration) {
				return nullSafeScope(getEntityMemberDeclarationReferences(parent, 
					getResolvedProxy(queryCallExpression, featureToScope.navigationTargetType) as EntityMemberDeclaration, ref))
			}
		} else {
			return getQueryCallExpressionReferences(parent, queryCallExpression, ref)
		}		
		parent				
	}

	def getNavigationExpressionReferences(IScope parent, NavigationExpression navigationExpression, EReference reference) {
		if (navigationExpression instanceof SelfExpression) {
			val entity = navigationExpression.parentContainer(EntityDeclaration)
			val entityMembers = getEntityMembers(parent, entity, reference)
			return nullSafeScope(entityMembers)
		} else if (navigationExpression instanceof NavigationBaseExpression) {
			return nullSafeScope(getNavigationBaseReferences(parent, 
				getResolvedProxy(navigationExpression, navigationExpression.navigationBaseType) as NavigationBaseReference, reference
			))
		} else if (navigationExpression instanceof QueryCallExpression) {
			return getQueryCallExpressionReferences(parent, navigationExpression, reference)
		}
		parent
	}

	def IScope getFunctionCallReferences(IScope parent, FunctionCall functionCall, EReference reference) {
		if (functionCall.function instanceof LambdaFunction) {
			if (functionCall.eContainer instanceof FunctionedExpression) {
				return getFunctionedExpressionReferences(parent, functionCall.eContainer as FunctionedExpression, reference)
			} else if (functionCall.eContainer instanceof FunctionCall) {
				return getLastFeatureNavigationTargetReferences(parent, functionCall.eContainer, (functionCall.eContainer as FunctionCall).features, reference)
			}			
		}
		parent		
	}

	def getLastFeatureNavigationTargetReferences(IScope parent, EObject context, List<Feature> features, EReference reference) {
		if (features?.last?.navigationTargetType !== null) {
			if (features.last.navigationTargetType instanceof EntityMemberDeclaration) {
				return nullSafeScope(getEntityMemberDeclarationReferences(parent, 
					getResolvedProxy(context, features.last.navigationTargetType) as EntityMemberDeclaration, reference))						
			}
		} else if (context instanceof NavigationBaseExpression) {
			return nullSafeScope(getNavigationBaseReferences(parent, context .navigationBaseType, reference))
		} else if (context instanceof FunctionCall) {
			return nullSafeScope(getFunctionCallReferences(parent, context, reference))
		}
		parent
	}

	def getFunctionedExpressionReferences(IScope parent, FunctionedExpression functionedExpression, EReference reference) {
		if (functionedExpression === null) {
			return parent
		}
		if (functionedExpression.operand instanceof SelfExpression) {
			val selfExpression = functionedExpression.operand as SelfExpression	
			return getLastFeatureNavigationTargetReferences(parent, selfExpression, selfExpression.features, reference)
		} else if (functionedExpression.operand instanceof NavigationBaseExpression) {
			val navigationBase = functionedExpression.operand as NavigationBaseExpression
			return getLastFeatureNavigationTargetReferences(parent, navigationBase, navigationBase.features, reference)
		} else if (functionedExpression.operand instanceof QueryCallExpression) {
			val queryCall = functionedExpression.operand as QueryCallExpression
			return getLastFeatureNavigationTargetReferences(parent, queryCall, queryCall.features, reference)
		}
		parent		
	}
	
	def getDefaultExpressionScope(EObject context, EReference reference) {
			super.getScope(context, reference)
			.filterType(QueryDeclaration)
			.filterType(QueryDeclarationParameter)
			.filterType(LambdaVariable)
    		.filterType(FunctionDeclaration)			
	}
	
	def getLambdaFunctionParametersReferences(IScope parent, LambdaFunctionParameters lambdaFunctionParameters, EReference reference) {
		var scope = nullSafeScope(lambdaFunctionParameters.lambdaArgument, parent)			
		scope = nullSafeScope(lambdaFunctionParameters.eContainer.parentQueryDeclarationParameters, scope)
		scope					
	}
	
	def EObject getReferenceTypeFromIndex(EObject object) {
		if (object !== null && object.eContainer !== null) {
			var EObject resolved = null
			switch object {
				EntityFieldDeclaration: resolved = object.eGet(JsldslPackage::eINSTANCE.entityFieldDeclaration_ReferenceType, true) as EObject
				EntityIdentifierDeclaration: resolved = object.eGet(JsldslPackage::eINSTANCE.entityIdentifierDeclaration_ReferenceType, true) as EObject
				EntityRelationDeclaration: resolved = object.eGet(JsldslPackage::eINSTANCE.entityRelationDeclaration_ReferenceType, true) as EObject
				EntityDerivedDeclaration: resolved = object.eGet(JsldslPackage::eINSTANCE.entityDerivedDeclaration_ReferenceType, true) as EObject
				EntityQueryDeclaration: resolved = object.eGet(JsldslPackage::eINSTANCE.entityQueryDeclaration_ReferenceType, true) as EObject
				QueryDeclaration: resolved = object.eGet(JsldslPackage::eINSTANCE.queryDeclaration_ReferenceType, true) as EObject
			}
			if (resolved !== null) {
				return resolved
			}			
//			val descriptor = object.EObjectDescription
//			if (descriptor !== null) {
//				val type = descriptor.getUserData("referenceType")
//				val referenceDesc = object.getEObjectDescriptionByName(type)
//				if (referenceDesc !== null) {
//					return referenceDesc.EObjectOrProxy				
//				}
//			}
		}
		null
	}
	
	def getEntityMemberDeclarationReferences(IScope parent, EntityMemberDeclaration entityMemberDeclaration, EReference reference) {
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
		parent		
	}

	def Collection<QueryDeclarationParameter> getFeatureQueryDeclarationParameters(EObject feature) {
		if (feature instanceof Feature) {
			if (feature === null || feature.navigationTargetType === null) {
				return null
			} else if (feature.navigationTargetType instanceof EntityQueryDeclaration) {
				return (feature.navigationTargetType as EntityQueryDeclaration).parameters						
			}			
		}
		null
	}

	def Collection<QueryDeclarationParameter> getParentQueryDeclarationParameters(EObject object) {
		if (object !== null) {
			val queryDeclaration = object.parentContainer(QueryDeclaration)
			if (queryDeclaration !== null) {
				return queryDeclaration.parameters
			} else {
				val entityQueryDeclaration = object.parentContainer(EntityQueryDeclaration)
				if (entityQueryDeclaration !== null) {
					return entityQueryDeclaration.parameters
				}				
			}
		} 
		return null		
	}

	/*******************************************************************************************/

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
			throw new IllegalArgumentException("Only EObject / Iterable / IScope are accepted")
		}
	}
}
