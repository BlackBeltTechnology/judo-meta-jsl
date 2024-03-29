package hu.blackbelt.judo.meta.jsl.scoping

import com.google.inject.Inject
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.impl.ResourceDescriptionsProvider
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import org.eclipse.xtext.resource.IContainer
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelImportDeclaration
import org.eclipse.emf.ecore.resource.Resource
import java.util.Map
import java.util.LinkedHashMap

class JslDslIndex {

    @Inject ResourceDescriptionsProvider rdp

    @Inject IContainer$Manager cm

    // Returns all ModelDeclaration
    def getAllModelDelcaration(EObject context) {
        if (context.eResource === null) {
            return #[]
        }
        val index = rdp.getResourceDescriptions(context.eResource)
        return index.getExportedObjectsByType(JsldslPackage.eINSTANCE.modelDeclaration)
    }

    // Returns all ModelDeclaration
    def getAllModelDelcaration(Resource context) {
        val index = rdp.getResourceDescriptions(context)
        return index.getExportedObjectsByType(JsldslPackage.eINSTANCE.modelDeclaration)
    }

    // Returns all ModelDeclaration's from the current resource
    def getModelDeclarations(EObject context) {
        val resource = context.eResource
        val index = rdp.getResourceDescriptions(resource)
        val resourceDescription = index.getResourceDescription(resource.URI)
        resourceDescription.getExportedObjectsByType(JsldslPackage.eINSTANCE.modelDeclaration)
    }

    def getAllImports(ModelDeclaration context) {
        var Map<String, String> imports = new LinkedHashMap;

        if (context.EObjectDescription !== null) {
            for (String import : context.EObjectDescription.getUserData("imports").split(",")) {
                if (import.contains("=")) {
                    val split = import.split("=")
                    if (split.size > 0) {
                        val ns = split.get(0);
                        var alias = null as String;
                        if (split.size > 1) {
                            alias = split.get(1)
                        }
                        imports.put(ns, alias);
                    }
                }
            }
        }
        return imports
    }

    def getVisibleEObjectDescriptions(EObject o) {
        // System.out.println("JslDslIndex.getVisibleEObjectDescriptions Object: " + o)
        o.getVisibleContainers.map[ container |
            container.getExportedObjects
        ].flatten
    }

    def getVisibleEObjectDescriptions(EObject o, EClass type) {
        // System.out.println("JslDslIndex.getVisibleEObjectDescriptions Object: " + o + " Type: " + type)
        o.getVisibleContainers.map[ container |
            container.getExportedObjectsByType(type)
        ].flatten
    }

    def getVisibleClassesDescriptions(EObject o) {
        o.getVisibleEObjectDescriptions(JsldslPackage::eINSTANCE.modelDeclaration)
    }

    def getEObjectDescription(EObject o) {
    	for (container : o.getVisibleContainers) {
    		var descr = container.getExportedObjectsByObject(o).head
    		if (descr !== null) return descr
    	}
    }

    def getEObjectDescriptionByName(EObject o, String fullyQualifiedName) {
        o.getVisibleEObjectDescriptions.findFirst[d | d.qualifiedName.toString.equals(fullyQualifiedName)]
    }


    def getImportedEntityDeclarations(ModelDeclaration model, EClass instance) {
        val importNames = model.imports.map[i | i.model.name].toList
        model.getVisibleEObjectDescriptions.filter[d |
            importNames.exists[i | d.qualifiedName.toString.startsWith(i) && instance.isInstance(d.EObjectOrProxy)]
        ].toList
    }

    def getImportedModelDeclarationFullyQualifiedName(ModelImportDeclaration model) {
        return getVisibleEObjectDescriptions(JsldslPackage::eINSTANCE.modelImportDeclaration)
    }

    def getVisibleContainers(EObject o) {
        if (o === null || o.eResource === null) {
            return emptyList
        }
        val index = rdp.getResourceDescriptions(o.eResource)
        val rd = index.getResourceDescription(o.eResource.URI)
        if (rd !== null)
            return cm.getVisibleContainers(rd, index)
        else
            return emptyList
    }

    def getResourceDescription(EObject o) {
        val index = rdp.getResourceDescriptions(o.eResource)
        index.getResourceDescription(o.eResource.URI)
    }

    def getExportedEObjectDescriptions(EObject o) {
        o.getResourceDescription.getExportedObjects
    }
}
