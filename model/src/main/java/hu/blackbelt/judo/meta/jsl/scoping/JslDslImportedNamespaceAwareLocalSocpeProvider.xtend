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
import java.util.ArrayList

class JslDslImportedNamespaceAwareLocalSocpeProvider extends ImportedNamespaceAwareLocalScopeProvider {

	@Inject extension IQualifiedNameConverter

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

	override protected List<ImportNormalizer> internalGetImportedNamespaceResolvers(EObject context, boolean ignoreCase) {
		val resolvers = new ArrayList<ImportNormalizer>()
		
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