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
import org.eclipse.xtext.scoping.impl.FilteringScope
import org.eclipse.xtext.scoping.Scopes

class JslDslGlobalScopeProvider extends DefaultGlobalScopeProvider {

	@Inject extension JslDslIndex
	@Inject extension IQualifiedNameConverter
	@Inject extension JslDslModelExtension
	@Inject JudoTypesProvider judoTypesProvider

    override IScope getScope(Resource resource, EReference reference, Predicate<IEObjectDescription> filter) {
		// System.out.println("JslDslGlobalScopeProvider.getScope Res: " + resource + "Ref: " + reference);
    	// System.out.println("JslDslGlobalScopeProvider.scope=scope_" + reference.EContainingClass.name + "_" + reference.name + "(" + resource + " context, EReference ref) : " + reference.EReferenceType.name);
		// System.out.println("\tRes: " + resource + "Ref: " + reference);
		val model = resource.getContents().get(0).parentContainer(ModelDeclaration)
		
				
		if (JsldslPackage::eINSTANCE.modelImportDeclaration_Model == reference) {			
			System.out.println("JslDslGlobalScopeProvider.getScope ModelImportDeclaration - " + model.name);
			val overridedFilter = new Predicate<IEObjectDescription>() {
	            override boolean apply(IEObjectDescription input) {
					var found = true
					for (e : model.allImports.entrySet) {
						if (e.key.equals(model.name)) {
							return false;
						}
					}

					if (filter === null) {
						return found
					} else {
		            	return filter.apply(input) && found					
					}
	            	
	            }
            }
	        super.getScope(resource, reference, overridedFilter)
			//return judoTypesProvider.getScope(super.getScope(resource, reference, overridedFilter), resource, reference, overridedFilter);  
		}
				
	    val overridedFilter = new Predicate<IEObjectDescription>() {
            override boolean apply(IEObjectDescription input) {

				// System.out.println("> ModelDeclaration: " + model);
				// System.out.println("> Input: " + input)
				// System.out.println("> Import NS: " + model.EObjectDescription.getUserData("imports"))

				var found = false
				for (e : model.allImports.entrySet) {
					val normalizer = new ImportNormalizer(e.key.toQualifiedName, true, false);
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
        super.getScope(resource, reference, overridedFilter)
        		
        //return judoTypesProvider.getScope(super.getScope(resource, reference, overridedFilter), resource, reference, overridedFilter);    
    }

	def typeOnly(IScope parent, Class<?> type) {
		return new FilteringScope(parent, [desc | {
			val obj = desc.EObjectOrProxy
			if (type.isAssignableFrom(obj.class)) {
				return true								
			}
			false
		}]);
	}
    
    override IResourceDescriptions getResourceDescriptions(Resource resource) {
    	//System.out.println("=== JslDslGlobalScopeProvider.getResourceDescriptions = " + resource);
    	return new ResourceDescriptionsWrapper(resource.resourceSet, super.getResourceDescriptions(resource), judoTypesProvider.getResourceDescription(resource))    		
	}
}