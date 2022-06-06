package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.emf.ecore.EObject
import java.util.List
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelImport
import org.eclipse.xtext.naming.IQualifiedNameConverter
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.resource.Resource
import com.google.common.base.Predicate
import org.eclipse.xtext.resource.IEObjectDescription
import java.beans.Expression
import java.util.ArrayList
import org.eclipse.xtext.scoping.IScope
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.Feature
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationExpression
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityMemberDeclaration

class JslDslImportedNamespaceAwareLocalSocpeProvider extends ImportedNamespaceAwareLocalScopeProvider {

	@Inject extension IQualifiedNameConverter
	@Inject extension JslDslModelExtension

	/* 
	override getImplicitImports(boolean ignoreCase) {
		newArrayList(new ImportNormalizer(QualifiedName.create("smalljava", "lang"), true, ignoreCase
		))
	} */	
	// https://github.com/eclipse/xtext-extras/blob/master/org.eclipse.xtext.xbase/deprecated/org/eclipse/xtext/xbase/scoping/XbaseImportedNamespaceScopeProvider.java
	
	override protected getImportedNamespace(EObject object) {		
		if (object instanceof ModelImport) {
			val modelImport = object as ModelImport;
			modelImport.modelName.importName			
		}
	}


	def protected List<ImportNormalizer> getImportedNamespaceResolvers2(EObject context, boolean ignoreCase) {
		val resolvers = new ArrayList<ImportNormalizer>()
		// System.out.println("Resolver for: " + context)
	
		if (context instanceof ModelDeclaration) {
			resolvers.addAll(super.getImportedNamespaceResolvers(context, ignoreCase))
		} else if (context instanceof EntityDeclaration) {
			val entityDecl = context as EntityDeclaration
			entityDecl.superEntityTypes.forEach[e | {
				val qn = e.qualifiedNameOfLocalElement
				if (qn !== null) {
					System.out.println(e.qualifiedNameOfLocalElement.toString() + ".*")
					resolvers.add(createImportedNamespaceResolver(e.qualifiedNameOfLocalElement.toString() + ".*" , false));					
				}
			}]
		} else if (context instanceof NavigationExpression) {
			val navExpr = context as NavigationExpression
			if (navExpr.navigationBaseType !== null && navExpr.navigationBaseType instanceof EntityDeclaration) {
//				val qn = navExpr.navigationBaseType.qualifiedNameOfLocalElement
//				if (qn !== null) {
//					resolvers.add(createImportedNamespaceResolver(navExpr.navigationBaseType.qualifiedNameOfLocalElement.toString() + ".*" , false));												
//				}	
//			} else if (navExpr.isSelf) {
//				navExpr.parentContainer(EntityDeclaration).getSuperEntityTypes.forEach[e | {
//					resolvers.addAll(getImportedNamespaceResolvers(e, false))
//				}]
			}
		} else if (context instanceof Feature) {
			val feature = context as Feature
			/*
			if (feature.navigationDeclarationType !== null) {
				val nav = feature.navigationDeclarationType as NavigationDeclaration
				nav.
			} */
			/*
			val navExpression = feature.parentContainer(NavigationExpression)
			var Feature lastFeature = null
			if (navExpression.features.size > 1) {
				lastFeature = navExpression.features.get(navExpression.features.size - 2)
			}
			if (lastFeature !== null) {
				val navDecl = lastFeature.member.navigationDeclarationType
				if (navDecl instanceof EntityMemberDeclaration) {
					// return (navDecl as EntityMemberDeclaration).memberTargetMembers
				}
			} */

		}
		//} else if (context instanceof EntityDeclaration) {
		//	System.out.println("Resolver for: " + (context as EntityDeclaration).qualifiedNameOfLocalElement.toString("::"))
		//	resolvers.add(createImportedNamespaceResolver((context as EntityDeclaration).qualifiedNameOfLocalElement.toString("::"), false))
		//}
		resolvers
		//return new ArrayList<ImportNormalizer>()
	}

	override protected List<ImportNormalizer> internalGetImportedNamespaceResolvers(EObject context, boolean ignoreCase) {
		//val resolvers = new ArrayList<ImportNormalizer>()
		//super.internalGetImportedNamespaceResolvers(context, ignoreCase)
		
		val resolvers = new ArrayList<ImportNormalizer>()
//			super.internalGetImportedNamespaceResolvers(context, ignoreCase)
//		)
		
		//System.out.println("internalGetImportedNamespaceResolvers: " + context)
		
		if (context instanceof ModelDeclaration) {
			val root = context as ModelDeclaration
			for (ModelImport modelImport : root.imports) {
				if (modelImport.importedNamespace !== null && modelImport.importedNamespace.toQualifiedName !== null) {
					resolvers += new JslDslImportNormalizer(modelImport.modelName.alias, modelImport.importedNamespace.toQualifiedName, true, ignoreCase)
				}
			}
		}
		resolvers
	}
	
	override getScope(EObject context, EReference ref) {
    	System.out.println("JslDslImportedNamespaceAwareLocalSocpeProvider.scope=scope_" + ref.EContainingClass.name + "_" + ref.name + "(" + context.eClass.name + " context, EReference ref) : " + ref.EReferenceType.name);
    	printParents(context)
		return super.getScope(context, ref)		

/*
		val refTypesFromGlobal = #[
			JsldslPackage::eINSTANCE.entityDeclaration_Extends,
			JsldslPackage::eINSTANCE.entityDerivedDeclaration_ReferenceType,
			JsldslPackage::eINSTANCE.entityFieldDeclaration_ReferenceType,
			JsldslPackage::eINSTANCE.entityIdentifierDeclaration_ReferenceType,
			JsldslPackage::eINSTANCE.entityQueryDeclaration_ReferenceType,
			JsldslPackage::eINSTANCE.entityRelationDeclaration_ReferenceType,
			JsldslPackage::eINSTANCE.entityRelationDeclaration_Opposite,								
			JsldslPackage::eINSTANCE.navigationExpression_NavigationBaseType,
			JsldslPackage::eINSTANCE.queryCall_QueryDeclarationReference,
			JsldslPackage::eINSTANCE.queryDeclaration_ReferenceType,
			JsldslPackage::eINSTANCE.queryDeclarationParameter_ReferenceType,
			JsldslPackage::eINSTANCE.errorField_ReferenceType,
			JsldslPackage::eINSTANCE.errorDeclaration_Extends,
			JsldslPackage::eINSTANCE.createError_ErrorDeclarationType
		]

		if (refTypesFromGlobal.contains(ref)) {
			return super.getScope(context, ref)		
		} else {
			return IScope.NULLSCOPE			
		} */
	}
	
	def void printParents(EObject obj) {
		var EObject t = obj;
		var int indent = 1
		while (t.eContainer !== null) {
			for (var i = 0; i<indent; i++) {
				System.out.print("\t");
			}
			indent ++
			System.out.println(t)
			t = t.eContainer
		}
		System.out.println("")	
	}
	
}