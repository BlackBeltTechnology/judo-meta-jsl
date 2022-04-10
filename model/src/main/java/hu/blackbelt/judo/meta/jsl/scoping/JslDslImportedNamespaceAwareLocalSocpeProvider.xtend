package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.emf.ecore.EObject
import java.util.List
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelImport
import org.eclipse.xtext.naming.IQualifiedNameConverter
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration

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
		val resolvers = super.internalGetImportedNamespaceResolvers(context, ignoreCase)
		
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
}