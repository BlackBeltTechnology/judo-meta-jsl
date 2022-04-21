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
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDerivedDeclaration

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
						Scopes.scopeFor((context.eContainer as EntityRelationDeclaration).getAllOppositeRelations, IScope.NULLSCOPE)			
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
					case JsldslPackage::eINSTANCE.feature_EntityMemberDeclarationType:
						(context as Feature).scopeForFeatureEntityMemberDeclarationType
					case JsldslPackage::eINSTANCE.queryParameter_DerivedParameterType:
						(context as Feature).scopeForQueryParameterDerivedParameterType(super.getScope(context, ref))
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
					case JsldslPackage::eINSTANCE.queryParameter_DerivedParameterType:
						(context.eContainer as Feature).scopeForQueryParameterDerivedParameterType(super.getScope(context, ref))
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

	def IScope scopeForQueryParameterDerivedParameterType(Feature feature, IScope fallback) {
		if (feature.entityMemberDeclarationType !== null 
			&& feature.entityMemberDeclarationType instanceof EntityDerivedDeclaration) {
			Scopes.scopeFor((feature.entityMemberDeclarationType as EntityDerivedDeclaration).parameters, IScope.NULLSCOPE)							
		} else {
			fallback
		}
	}

	def IScope scopeForQueryParameterParameterType(Feature feature) {
		Scopes.scopeFor(feature.getDerivedDeclaration.parameters, IScope.NULLSCOPE)							
	}

	def IScope scopeForFeatureEntityMemberDeclarationType(Feature feature) {
		Scopes.scopeFor(feature.modelDeclaration.allEntityMemberDeclarations, IScope.NULLSCOPE)		
	}


}
