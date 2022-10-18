package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.emf.ecore.resource.Resource
import javax.inject.Singleton
import com.google.inject.Inject
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.emf.ecore.EReference
import com.google.common.base.Predicate
import org.eclipse.xtext.util.StringInputStream
import java.io.IOException
import org.eclipse.xtext.scoping.impl.SimpleScope
import org.eclipse.xtext.resource.IResourceServiceProvider
import org.eclipse.xtext.naming.IQualifiedNameConverter
import java.util.List

@Singleton
class JudoTypesProvider {
	
	@Inject IResourceDescription.Manager mgr;
	@Inject IResourceServiceProvider.Registry rspr
	@Inject IQualifiedNameConverter converter

	def Resource getResource(Resource parentResource) {
		// val URI libaryResourceURI = URI.createURI("dummy://system/judo-types.jsl");
		val libaryResourceURI = org.eclipse.emf.common.util.URI.createPlatformResourceURI("__injectedjudotypes/_synthetic.jsl", true)
	
		var Resource libaryResource = parentResource.getResourceSet().getResource(libaryResourceURI, false);
		if (libaryResource == null) {
			libaryResource = parentResource.getResourceSet().createResource(libaryResourceURI);
			try {
				libaryResource.load(new StringInputStream(model().toString), null);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		libaryResource		
	}


	def List<IEObjectDescription> getDescriptions(Resource parentResource) {
		val IResourceDescription resourceDescription = mgr.getResourceDescription(getResource(parentResource));
		resourceDescription.getExportedObjects().toList;
	}

	def IScope getScope(IScope parentScope, Resource parentResource, EReference reference, Predicate<IEObjectDescription> filter) {
		var library = getDescriptions(parentResource)
		if (filter != null) {
			library = library.filter[f | filter.apply(f)].toList
		}
		return new SimpleScope(parentScope, library, false);	
	}
	 
	def getResourceDescription(Resource parentResource) {
		val resource = getResource(parentResource)
	    val resServiceProvider = rspr.getResourceServiceProvider(resource.URI)
	    val manager = resServiceProvider.getResourceDescriptionManager()
	    manager.getResourceDescription(resource)		
	}
	 
	def void printExportedObjects(Resource parentResource) {
	    for (eod : getResourceDescription(parentResource).exportedObjects) {
	        println(converter.toString(eod.qualifiedName))
	    }
	}
	
	def model() '''
		model judo::types;
		
		type string String(min-size = 0, max-size = 128);
		// type string Text(min-size = 0, max-size = 2048);
		// type string UPC(min-size = 0, max-size = 12, regex = r"[0-9]{12}");
		// type string PhoneNumber(min-size = 0, max-size = 32, regex = "^(\\+\\d{1,2}\\s)?\\(?\\d{2,5}\\)?[\\s-]\\d{2,4}[\\s-]\\d{4}$");
		// type string PostalCode(min-size = 0, max-size = 5, regex = r"[0-9]{12}");
		//
		//
		// type numeric Price(precision = 12, scale = 2);
		// type numeric Integer(precision = 12, scale = 0);
		//
		// type boolean Boolean;	
	'''
		
}