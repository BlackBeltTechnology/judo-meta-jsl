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
import org.eclipse.xtext.scoping.IScope

class JslDslImportedNamespaceAwareLocalSocpeProvider extends ImportedNamespaceAwareLocalScopeProvider {

	@Inject extension IQualifiedNameConverter
	@Inject extension JslDslIndex
	@Inject extension JslDslModelExtension

	override protected List<ImportNormalizer> internalGetImportedNamespaceResolvers(EObject context, boolean ignoreCase) {
		val resolvers = new ArrayList<ImportNormalizer>()
		if (context instanceof ModelDeclaration) {
			System.out.println("Import NS: " + context.EObjectDescription.getUserData("imports"))
			for (e : context.allImports.entrySet) {
				resolvers += new JslDslImportNormalizer(e.value, e.key.toQualifiedName, true, ignoreCase)				
			}			
		}
		resolvers
	}
	
	override getScope(EObject context, EReference ref) {
    	System.out.println("JslDslImportedNamespaceAwareLocalSocpeProvider.scope=scope_" + ref.EContainingClass.name + "_" + ref.name + "(" + context.eClass.name + " context, EReference ref) : " + ref.EReferenceType.name);
    	// printParents(context)
	
		if (context == null)
			throw new NullPointerException("context");
		var IScope result = null;
		if (context.eContainer() != null) {
			System.out.println("\tContainr scope")
			result = getScope(context.eContainer(), ref);
		} else {
			System.out.println("\tResource scope")
			result = getResourceScope(context.eResource(), ref);
		}
		return getLocalElementsScope(result, context, ref);
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