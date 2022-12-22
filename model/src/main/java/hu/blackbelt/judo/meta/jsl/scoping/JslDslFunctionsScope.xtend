package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.xtext.resource.impl.AbstractResourceDescription
import hu.blackbelt.judo.meta.jsl.jsldsl.impl.JsldslFactoryImpl
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslFactory
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.emf.ecore.EObject
import java.util.Collections
import javax.inject.Singleton
import com.google.inject.Inject
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.naming.IQualifiedNameProvider
import java.util.List
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.naming.QualifiedName
import com.google.inject.Injector
import org.eclipse.xtext.util.StringInputStream
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.emf.ecore.resource.ResourceSet

@Singleton
class JslDslFunctionsScope extends AbstractResourceDescription implements IScope {
	val uri = org.eclipse.emf.common.util.URI.createPlatformResourceURI("__injectedjudofunctions/_synthetic.jsl", true)

	@Inject XtextResourceSet resourceSet
	@Inject extension IQualifiedNameProvider
	@Inject extension JslResourceDescriptionStrategy

	@Inject Injector injector
	//@Inject IResourceDescription.Manager mgr;

	def getAdditionalObjectsResource() {
		System.out.println("getAdditionalObjectsResource")
		val judoFunctionsResourceURI = uri
		
		val XtextResourceSet xtextResourceSet = new XtextResourceSet
		var Resource judoFunctionsResource = xtextResourceSet.getResource(judoFunctionsResourceURI, false);
		if (judoFunctionsResource === null) {
			val functionsXtextResourceSet = new XtextResourceSet();
			judoFunctionsResource = functionsXtextResourceSet.createResource(judoFunctionsResourceURI);
			//judoFunctionsResource.load(new StringInputStream(model().toString), null);
		}

		return judoFunctionsResource		
	}

	def private getFactory() {
		System.out.println("getFactory")
    	JsldslFactoryImpl.init()
    	val JsldslFactory factory = new JsldslFactoryImpl()		
    	return factory
	}		


	override protected computeExportedObjects() {
		return Collections.emptyList();
		
//		functions.filter[o | o.fullyQualifiedName !== null].map[o |
//					EObjectDescription::create(
//						o.fullyQualifiedName, o, o.indexInfo
//					)			
//		].toList
	}
	
	override getImportedNames() {
		return Collections.emptyList();
	}
	
	override getReferenceDescriptions() {
		return Collections.emptyList();	
	}
	
	override getURI() {
		uri
	}
	
	override getAllElements() {
		exportedObjects
	}
	
	override getElements(QualifiedName name) {
		allElements.filter[it.name == name]
	}
	
	override getElements(EObject object) {
		this.getExportedObjectsByObject(object);
	}
	
	override getSingleElement(QualifiedName name) {
		allElements.filter[it.name == name].head
	}
	
	override getSingleElement(EObject object) {
		this.getExportedObjectsByObject(object).head;
	}

}