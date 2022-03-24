package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.emf.ecore.EObject

class JslDslImportedNamespaceAwareLocalSocpeProvider extends ImportedNamespaceAwareLocalScopeProvider {

	/* 
	override getImplicitImports(boolean ignoreCase) {
		newArrayList(new ImportNormalizer(QualifiedName.create("smalljava", "lang"), true, ignoreCase
		))
	} */
	
	// https://github.com/eclipse/xtext-extras/blob/master/org.eclipse.xtext.xbase/deprecated/org/eclipse/xtext/xbase/scoping/XbaseImportedNamespaceScopeProvider.java
	
	override protected getImportedNamespace(EObject object) {
		super.getImportedNamespace(object)
	}
	
}