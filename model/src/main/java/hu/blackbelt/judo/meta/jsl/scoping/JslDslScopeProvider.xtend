/*
 * generated by Xtext 2.26.0
 */
package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import org.eclipse.xtext.scoping.Scopes
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension
import com.google.inject.Inject
import org.eclipse.xtext.scoping.IScope
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOpposite
import hu.blackbelt.judo.meta.jsl.jsldsl.ThrowParameter
import hu.blackbelt.judo.meta.jsl.jsldsl.CreateError
import hu.blackbelt.judo.meta.jsl.jsldsl.Feature
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryParameter
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationExpression
import hu.blackbelt.judo.meta.jsl.jsldsl.DefaultExpressionType
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumLiteralReference
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityIdentifierDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaVariable
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaFunctionParameters
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityQueryDeclaration

/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 */ 
 
class JslDslScopeProvider extends AbstractJslDslScopeProvider {

	@Inject extension JslDslModelExtension

    override getScope(EObject context, EReference ref) {
    	// System.out.println("JslDslLocalScopeProvider.getScope="+ context.toString + " for " + ref.toString);
		switch context {
			EntityRelationOpposite : 
				switch (ref) {
					case JsldslPackage::eINSTANCE.entityRelationOpposite_OppositeType:
						Scopes.scopeFor((context.eContainer as EntityRelationDeclaration).getAllOppositeRelations)			
					default: 
						super.getScope(context, ref)
				}
			DefaultExpressionType :
				switch (ref) {
					case JsldslPackage::eINSTANCE.enumLiteralReference_EnumDeclaration:
						return context.scopeForDefaultExpressionType				
					default: 
						super.getScope(context, ref)
				}

			EnumLiteralReference :
				switch (ref) {
					case JsldslPackage::eINSTANCE.enumLiteralReference_EnumLiteral: {
						return Scopes.scopeFor(context.enumDeclaration.literals)
					}
					default: 
						super.getScope(context, ref)					
				}

			/*			 
			Feature
			    : {Feature} '.' member = EntityMemberDeclarationFeature
			    ;
			
			EntityMemberDeclarationFeature returns Feature
				: entityMemberDeclarationType = [EntityMemberDeclaration | LocalName ] ('(' parameters+=QueryParameter (',' parameters+=QueryParameter)* ')')?
				;
			*/
			Feature :
				switch (ref) {
					case JsldslPackage::eINSTANCE.feature_NavigationDeclarationType:
						return (context as Feature).scopeForNavigationDeclarationType(ref, super.getScope(context, ref))
					case JsldslPackage::eINSTANCE.queryParameter_QueryParameterType:
						(context as Feature).scopeForQueryParameterQueryParameterType(super.getScope(context, ref))
					default: 
						super.getScope(context, ref)
				}
			

			/*
			CreateError
				: errorDeclarationType=[ErrorDeclaration | LocalName] ('(' (parameters+=ThrowParameter (',' parameters+=ThrowParameter)*)? ')')?
				;
			
			ThrowParameter
				: errorFieldType=[ErrorField | LocalName] '=' expession=Expression
				;
			*/
			CreateError : 
				switch (ref) {
					case JsldslPackage::eINSTANCE.throwParameter_ErrorFieldType:
						(context as CreateError).scopeForCreateError
					default: 
						super.getScope(context, ref)
				}

			ThrowParameter : 
				switch (ref) {
					case JsldslPackage::eINSTANCE.throwParameter_ErrorFieldType:
						if (context.eContainer instanceof CreateError) {
							(context.eContainer as CreateError).scopeForCreateError
						} else {
							super.getScope(context, ref)
						}
					default: 
						super.getScope(context, ref)
				}

			/*
			Feature
				: {Feature} '.' name=ID ('(' parameters+=QueryParameter (',' parameters+=QueryParameter)* ')')?
				;
			
			QueryParameter
				:  derivedParameterType=[DerivedParameter | LocalName] '=' expression=MultilineExpression
				;
			 */
			QueryParameter : 
				switch (ref) {
					case JsldslPackage::eINSTANCE.queryParameter_QueryParameterType:
						(context.eContainer as Feature).scopeForQueryParameterQueryParameterType(super.getScope(context, ref))
					case JsldslPackage::eINSTANCE.queryParameter_Parameter:
						(context.eContainer as Feature).scopeForQueryParameterParameterType
					default: 
						super.getScope(context, ref)
				}
			default: super.getScope(context, ref)
		}		
	}
	
	def IScope scopeForCreateError(CreateError createError) {
		Scopes.scopeFor(createError.errorDeclarationType.fields, IScope.NULLSCOPE)		
	}

	def IScope scopeForQueryParameterQueryParameterType(Feature feature, IScope fallback) {
		if (feature.navigationDeclarationType === null) {
			fallback
		} else if (feature.navigationDeclarationType instanceof EntityQueryDeclaration) {
			Scopes.scopeFor((feature.navigationDeclarationType as EntityQueryDeclaration).parameters, IScope.NULLSCOPE)							
		} else {
			fallback
		}
	}

	def IScope scopeForQueryParameterParameterType(Feature feature) {
		Scopes.scopeFor(feature.getQueryDeclaration.parameters, IScope.NULLSCOPE)							
	}
	
	def IScope scopeForDefaultExpressionType(DefaultExpressionType defaultExpression) {
		var EObject refType

		if (defaultExpression.eContainer instanceof EntityFieldDeclaration) {
			refType = (defaultExpression.eContainer as EntityFieldDeclaration).referenceType
		} else if (defaultExpression.eContainer instanceof EntityIdentifierDeclaration) {
			refType = (defaultExpression.eContainer as EntityIdentifierDeclaration).referenceType
		}
		
		if (refType !== null && refType instanceof EnumDeclaration) {
			val enumDeclaration = refType as EnumDeclaration
			return Scopes.scopeFor(#[enumDeclaration], IScope.NULLSCOPE);				
		}
        
		return IScope.NULLSCOPE
	}

	def IScope scopeForNavigationDeclarationType(Feature feature, EReference ref, IScope fallback) {
		// System.out.println("JslDslLocalScopeProvider.scopeForNavigationDeclarationType="+ feature.toString + " parent=" + feature.eContainer + " grandParent=" + feature.eContainer.eContainer)
		if (feature.eContainer instanceof NavigationExpression) {
            // enums...
            val decl = feature.modelDeclaration.allEnumDeclarations
            val enumDeclaration = decl.findFirst[e | e.name.equals((feature.eContainer as NavigationExpression).QName)];

            if (enumDeclaration !== null) {
                return Scopes.scopeFor(enumDeclaration.literals, fallback)
            } else {
                return Scopes.scopeFor(feature.modelDeclaration.allEntityMemberDeclarations, IScope.NULLSCOPE)
            }
        } else if (feature.eContainer instanceof Feature) {        	
        	return Scopes.scopeFor(feature.modelDeclaration.allEntityMemberDeclarations, IScope.NULLSCOPE)
        } else {
            return feature.getScopeForFeature(ref, fallback)
        }
	}
	
	def LambdaVariable getParentLambdaVariable(Feature feature) {
		var EObject container = feature
		while (container.eContainer !== null) {
			container = feature.eContainer
			if (container instanceof LambdaFunctionParameters) {
				return (container as LambdaFunctionParameters).lambdaArgument
			}
		}
		null
	}


	def void printParents(EObject obj) {
		var EObject t = obj;
		var int indent = 1
		System.out.println("")
		while (t.eContainer !== null) {
			for (var i = 0; i<indent; i++) {
				System.out.print("\t");
			}
			indent ++
			System.out.println(t)
			t = t.eContainer
		}
		
	}
}
