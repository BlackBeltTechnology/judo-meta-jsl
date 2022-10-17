package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.naming.QualifiedName;
import org.eclipse.xtext.scoping.IScope;
import java.util.ArrayList
import org.eclipse.xtext.resource.IEObjectDescription
import com.google.common.base.Predicate

class JslDslInjectedObjectsScopeWrapper implements IScope {

	var IScope scope
	var JslDslInjectedObjectsProvider injectedObjectsProvider
	var Predicate<IEObjectDescription> filter
	
	new(IScope scopeParam, JslDslInjectedObjectsProvider providerParam, Predicate<IEObjectDescription> filterParam) {
    	scope = scopeParam
    	injectedObjectsProvider = providerParam
    	//if (filterParam == null) {
    		filter = new Predicate<IEObjectDescription>() {
							
							override apply(IEObjectDescription arg0) {
								return true;
							}
    		};
    	//} else {
    	//	filter = filterParam;
    	//}
	}
	
	override getAllElements() {
		val ret = new ArrayList(scope.allElements.toList)
		ret.addAll(injectedObjectsProvider.exportedObjects.filter[f | filter.apply(f)].toList)
		return ret
	}
	
	override getElements(QualifiedName name) {
		System.out.println("All QN: " + name)
		val ret = new ArrayList(scope.getElements(name).toList)
		ret.addAll(allElements.filter[f | f.name.startsWith(name)].toList)

		ret.forEach[e | 
			System.out.println("\tElem: " + e + " - " + e.EObjectOrProxy)		
		]

		return ret
	}
	
	override getElements(EObject object) {
		System.out.println("All OB: " + object)
		return scope.getElements(object)
	}
	
	override getSingleElement(QualifiedName name) {
		System.out.println("Single QN: " + name)
		//return injectedObjectsProvider.exportedObjects.filter[f | filter.apply(f)].head
		return allElements.filter[it.name == name].head
	}
	
	override getSingleElement(EObject object) {
		System.out.println("Single OB: " + object)
		//var IEObjectDescription d = injectedObjectsProvider.exportedObjects.filter[f | filter.apply(f)].head
		return scope.getSingleElement(object)
	}
	

}
