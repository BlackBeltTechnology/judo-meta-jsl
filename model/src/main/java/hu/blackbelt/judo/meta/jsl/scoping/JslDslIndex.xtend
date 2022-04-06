package hu.blackbelt.judo.meta.jsl.scoping

import com.google.inject.Inject
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.impl.ResourceDescriptionsProvider
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import org.eclipse.xtext.resource.IContainer

class JslDslIndex {
	
	@Inject ResourceDescriptionsProvider rdp

	@Inject IContainer$Manager cm

	def getVisibleEObjectDescriptions(EObject o) {
		System.out.println("JslDslIndex.getVisibleEObjectDescriptions Object: " + o)
		o.getVisibleContainers.map[ container |
			container.getExportedObjects
		].flatten
	}

	def getVisibleEObjectDescriptions(EObject o, EClass type) {
		System.out.println("JslDslIndex.getVisibleEObjectDescriptions Object: " + o + " Type: " + type)
		o.getVisibleContainers.map[ container |
			container.getExportedObjectsByType(type)
		].flatten
	}

	def getVisibleClassesDescriptions(EObject o) {
		o.getVisibleEObjectDescriptions(JsldslPackage::eINSTANCE.modelDeclaration)
	}

	def getVisibleContainers(EObject o) {
		val index = rdp.getResourceDescriptions(o.eResource)
		val rd = index.getResourceDescription(o.eResource.URI)
		if (rd !== null)
			cm.getVisibleContainers(rd, index)
		else
			emptyList
	}
	
	def getResourceDescription(EObject o) {
		val index = rdp.getResourceDescriptions(o.eResource)
		index.getResourceDescription(o.eResource.URI)
	}

	def getExportedEObjectDescriptions(EObject o) {
		o.getResourceDescription.getExportedObjects
	}
}
