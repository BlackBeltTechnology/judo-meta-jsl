package hu.blackbelt.judo.meta.jsl.scoping

import com.google.inject.Inject
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.impl.ResourceDescriptionsProvider
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import org.eclipse.xtext.resource.IContainer
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.eclipse.xtext.naming.IQualifiedNameProvider

class JslDslIndex {
	
	@Inject ResourceDescriptionsProvider rdp

	@Inject IContainer$Manager cm
	
	@Inject extension IQualifiedNameProvider
	

	def getVisibleEObjectDescriptions(EObject o) {
		//System.out.println("JslDslIndex.getVisibleEObjectDescriptions Object: " + o)
		o.getVisibleContainers.map[ container |
			container.getExportedObjects
		].flatten
	}

	def getVisibleEObjectDescriptions(EObject o, EClass type) {
		//System.out.println("JslDslIndex.getVisibleEObjectDescriptions Object: " + o + " Type: " + type)
		o.getVisibleContainers.map[ container |
			container.getExportedObjectsByType(type)
		].flatten
	}

	def getVisibleClassesDescriptions(EObject o) {
		o.getVisibleEObjectDescriptions(JsldslPackage::eINSTANCE.modelDeclaration)
	}

	def getEObjectDescription(EObject o) {
		o.getVisibleEObjectDescriptions.findFirst[d | d.qualifiedName.toString.equals(o.fullyQualifiedName.toString)]
	}

	def getEObjectDescriptionByName(EObject o, String fullyQualifiedName) {
		o.getVisibleEObjectDescriptions.findFirst[d | d.qualifiedName.toString.equals(fullyQualifiedName)]
	}


	def getImportedEntityDeclarations(ModelDeclaration model, EClass instance) {
		val importNames = model.imports.map[i | i.modelName.importName].toList
		model.getVisibleEObjectDescriptions.filter[d |
			importNames.exists[i | d.qualifiedName.toString.startsWith(i) && instance.isInstance(d.EObjectOrProxy)]
		].toList
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
