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
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.eclipse.xtext.resource.IResourceDescriptions

class JslDslGlobalScopeProvider extends DefaultGlobalScopeProvider {

	@Inject extension IQualifiedNameConverter
	@Inject extension JslDslModelExtension
	@Inject JslDslInjectedObjectsProvider injectedObjectsProvider

    override IScope getScope(Resource resource, EReference reference, Predicate<IEObjectDescription> filter) {
		// System.out.println("JslDslGlobalScopeProvider.getScope Res: " + resource + "Ref: " + reference);
    	// System.out.println("JslDslGlobalScopeProvider.scope=scope_" + reference.EContainingClass.name + "_" + reference.name + "(" + resource + " context, EReference ref) : " + reference.EReferenceType.name);
		
		if (JsldslPackage::eINSTANCE.modelImport_ModelName == reference) {
			// System.out.println("JslDslGlobalScopeProvider.getScope NULL");
			return new JslDslInjectedObjectsScopeWrapper(super.getScope(resource, reference, filter), injectedObjectsProvider);
			//return super.getScope(resource, reference, filter)

		}

	    val overridedFilter = new Predicate<IEObjectDescription>() {
            override boolean apply(IEObjectDescription input) {
				val model = resource.getContents().get(0).parentContainer(ModelDeclaration)

				var found = false
				for (modelImport : model.imports) {
					// System.out.println("> JslDslGlobalScopeProvider.getScope Import NS: " + modelImport.modelName.importName + " FIELD: " + input.qualifiedName.toString("::"));
					val normalizer = new ImportNormalizer(modelImport.modelName.importName.toQualifiedName, true, false);
					if (normalizer.deresolve(input.qualifiedName) !== null) {
						// System.out.println("> JslDslGlobalScopeProvider.getScope=" + input.qualifiedName.toString("::") + "Res: " + resource + " Ref: " + reference + " Input: " + input);
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
        return new JslDslInjectedObjectsScopeWrapper(super.getScope(resource, reference, overridedFilter), injectedObjectsProvider);
    }
    
    override IResourceDescriptions getResourceDescriptions(Resource resource) {
    	return new JslDslResourceDescriptionsResourceBasedWrapper(resource.resourceSet, super.getResourceDescriptions(resource), injectedObjectsProvider)    		    		
	}
}