package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.xtext.scoping.impl.DefaultGlobalScopeProvider
import org.eclipse.xtext.scoping.IScope
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.EReference
import com.google.common.base.Predicate
import org.eclipse.xtext.resource.IEObjectDescription
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameConverter
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension
import org.eclipse.xtext.scoping.impl.ImportNormalizer

class JslDslGlobalScopeProvider extends DefaultGlobalScopeProvider {

	@Inject extension IQualifiedNameConverter
	@Inject extension JslDslModelExtension
	
	override getScope(Resource resource, EReference reference) {
		//System.out.println("JslDslGlobalScopeProvider.getScope=" + reference);
		super.getScope(resource, reference)
	}
	
    override IScope getScope(Resource resource, EReference reference, Predicate<IEObjectDescription> filter) {
		//		System.out.println("JslDslGlobalScopeProvider.getScope=" + reference);

	    val overridedFilter = new Predicate<IEObjectDescription>() {
            override boolean apply(IEObjectDescription input) {
				//				System.out.println("> JslDslGlobalScopeProvider.getScope=" + reference + " for " + input.qualifiedName.toString("::"));
				//				System.out.println("> JslDslGlobalScopeProvider.getScope=" + resource.toString);
				//				System.out.println("> JslDslGlobalScopeProvider.getScope=" + model.fullyQualifiedName.toString("::"));
					
				val model = resource.getContents().get(0).modelDeclaration
				var found = false
				for (modelImport : model.imports) {
					val normalizer = new ImportNormalizer(modelImport.importedNamespace.toQualifiedName, true, false);
					if (normalizer.deresolve(input.qualifiedName) !== null) {
						// System.out.println("> JslDslGlobalScopeProvider.getScope=" + input.qualifiedName.toString("::"));
						found = true
					}
				}
	
				if (filter === null) {
					return found
				} else {
	            	return filter.apply(input) && found					
				}
            }
        }
        super.getScope(resource, reference, overridedFilter);
    }
	
}