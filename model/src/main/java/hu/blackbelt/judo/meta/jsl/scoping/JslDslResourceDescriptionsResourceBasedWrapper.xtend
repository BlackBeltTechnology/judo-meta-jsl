package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.impl.ResourceSetBasedResourceDescriptions
import org.eclipse.xtext.resource.IResourceDescriptions
import org.eclipse.emf.ecore.resource.ResourceSet

class JslDslResourceDescriptionsResourceBasedWrapper extends ResourceSetBasedResourceDescriptions {
	
	var JslDslInjectedObjectsProvider provider;
	var IResourceDescriptions descriptions;
	var ResourceSet resourceSet;

	new(ResourceSet fallbackResourceSet, IResourceDescriptions descriptionsParam, JslDslInjectedObjectsProvider providerParam) {    
		descriptions = descriptionsParam
		provider = providerParam
		resourceSet = fallbackResourceSet
	}	
	
	override getResourceSet() {
		if (descriptions instanceof ResourceSetBasedResourceDescriptions) {
			return (descriptions as ResourceSetBasedResourceDescriptions).getResourceSet()
		} else {
			return resourceSet;
		}
	}
	
	override getAllResourceDescriptions() {
	    val resources = descriptions.allResourceDescriptions.toList
	    resources.add(provider)
	    resources
	}
	
	override getResourceDescription(URI uri) {
	    if( uri == provider.URI ) provider
	    else descriptions.getResourceDescription(uri)
	}
	
	override getExportedObjects() {
	    val descriptions = descriptions.exportedObjects.toList
	    descriptions.addAll(provider.exportedObjects)	
	    descriptions
	}
	
	override getExportedObjects(EClass type, QualifiedName name, boolean ignoreCase) {
		descriptions.getExportedObjects(type, name, ignoreCase)
	}
	
	override getExportedObjectsByObject(EObject object) {
		descriptions.getExportedObjectsByObject(object)
	}
	
	override getExportedObjectsByType(EClass type) {
		descriptions.getExportedObjectsByType(type)
	}
	
	override isEmpty() {
		descriptions.isEmpty
	}
	
}