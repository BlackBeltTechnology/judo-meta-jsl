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

class JslDslGlobalScopeProvider extends DefaultGlobalScopeProvider {

	@Inject extension JslDslIndex
	@Inject extension IQualifiedNameConverter
	@Inject extension JslDslModelExtension
	@Inject JslDslInjectedObjectsProvider injectedObjectsProvider

    override IScope getScope(Resource resource, EReference reference, Predicate<IEObjectDescription> filter) {
		// System.out.println("JslDslGlobalScopeProvider.getScope Res: " + resource + "Ref: " + reference);
    	System.out.println("JslDslGlobalScopeProvider.scope=scope_" + reference.EContainingClass.name + "_" + reference.name + "(" + resource + " context, EReference ref) : " + reference.EReferenceType.name);
		System.out.println("\tRes: " + resource + "Ref: " + reference);
		
		if (JsldslPackage::eINSTANCE.modelImportDeclaration_Model == reference) {
			System.out.println("JslDslGlobalScopeProvider.getScope ModelImportDeclaration");
			return new JslDslInjectedObjectsScopeWrapper(super.getScope(resource, reference, filter), injectedObjectsProvider, filter).typeOnly(ModelDeclaration)
		}

		val model = resource.getContents().get(0).parentContainer(ModelDeclaration)

	    val overridedFilter = new Predicate<IEObjectDescription>() {
            override boolean apply(IEObjectDescription input) {

				System.out.println("> ModelDeclaration: " + model);
				System.out.println("> Input: " + input)
				System.out.println("> Import NS: " + model.EObjectDescription.getUserData("imports"))

				var found = false
				val qualifiedName = input.qualifiedName;
				
				for (e : model.allImports.entrySet) {
					val normalizer = new ImportNormalizer(e.key.toQualifiedName, true, false);
					if (normalizer.deresolve(input.qualifiedName) !== null) {
						System.out.println("> JslDslGlobalScopeProvider.getScope=" + input.qualifiedName.toString("::") + "Res: " + resource + " Ref: " + reference + " Input: " + input);
						found = true
					}
/*					val alias = e.value
					val ns = e.key
					val normalizer = new ImportNormalizer(ns.toQualifiedName, true, false);
					if (alias != null && ns.toQualifiedName.startsWith(alias.toQualifiedName)) {
						found = true
					} else if (alias == null && normalizer.deresolve(qualifiedName) !== null) {
						found = true						
					} */
				}
	
				if (filter === null) {
					return found
				} else {
	            	return filter.apply(input) && found					
				}
            }
        }
        
//        if (reference == JsldslPackage::eINSTANCE.literalFunctionParameter_Declaration
//        	|| reference == JsldslPackage::eINSTANCE.literalFunction_Parameters
//        	|| reference == JsldslPackage::eINSTANCE.literalFunction_FunctionDeclarationReference
//        	
//        ) {
	        return new JslDslInjectedObjectsScopeWrapper(super.getScope(resource, reference, overridedFilter), injectedObjectsProvider, overridedFilter);    
//	    } else {
//	        return super.getScope(resource, reference, overridedFilter);
//	    }
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
    	System.out.println("JslDslGlobalScopeProvider.getResourceDescriptions = " + resource);
    	return new JslDslResourceDescriptionsResourceBasedWrapper(resource.resourceSet, super.getResourceDescriptions(resource), injectedObjectsProvider)    		    		
	}
}