package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.naming.QualifiedName;
import org.eclipse.xtext.scoping.IScope;
import java.util.ArrayList

class JslDslInjectedObjectsScopeWrapper implements IScope {

	var IScope scope
	var JslDslInjectedObjectsProvider injectedObjectsProvider
	
	new(IScope scopeParam, JslDslInjectedObjectsProvider providerParam ) {
    	scope = scopeParam
    	injectedObjectsProvider = providerParam
	}
	
	override getAllElements() {
		val ret = new ArrayList(scope.allElements.toList)
		ret.addAll(injectedObjectsProvider.exportedObjects.toList)
		return ret
	}
	
	override getElements(QualifiedName name) {
		scope.getElements(name)
	}
	
	override getElements(EObject object) {
		scope.getElements(object)
	}
	
	override getSingleElement(QualifiedName name) {
		allElements.filter[it.name == name].head
	}
	
	override getSingleElement(EObject object) {
		scope.getSingleElement(object)
	}
	

}
