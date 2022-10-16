package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.emf.ecore.EObject
import java.util.List
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameConverter
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.eclipse.emf.ecore.EReference
import java.util.ArrayList
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension

class JslDslImportedNamespaceAwareLocalSocpeProvider extends ImportedNamespaceAwareLocalScopeProvider {

	@Inject extension IQualifiedNameConverter
	@Inject extension JslDslIndex
	@Inject extension JslDslModelExtension

	override protected List<ImportNormalizer> internalGetImportedNamespaceResolvers(EObject context, boolean ignoreCase) {
		val resolvers = new ArrayList<ImportNormalizer>()
		if (context instanceof ModelDeclaration) {
			//System.out.println("Import NS: " + model.EObjectDescription.getUserData("imports"))
			
			for (String import : context.EObjectDescription.getUserData("imports").split(",")) {
				if (import.contains("=")) {
					val split = import.split("=")
					val ns = split.get(0);
					var alias = null as String;
					if (split.size > 1) {
						alias = split.get(1)						
					}
					resolvers += new JslDslImportNormalizer(alias, ns.toQualifiedName, true, ignoreCase)					
				}
			}		
		}
		resolvers
	}
	
	override getScope(EObject context, EReference ref) {
    	// System.out.println("JslDslImportedNamespaceAwareLocalSocpeProvider.scope=scope_" + ref.EContainingClass.name + "_" + ref.name + "(" + context.eClass.name + " context, EReference ref) : " + ref.EReferenceType.name);
    	// printParents(context)
		return super.getScope(context, ref)		
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