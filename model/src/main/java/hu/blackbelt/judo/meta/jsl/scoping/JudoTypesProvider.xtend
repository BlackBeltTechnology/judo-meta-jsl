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
import java.util.List
import com.google.inject.Injector
import org.eclipse.xtext.resource.XtextResourceSet
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration

@Singleton
class JudoTypesProvider {
	
	@Inject IResourceDescription.Manager mgr;
	@Inject Injector injector

	def Resource getResource() {
		val judoTypesResourceURI = org.eclipse.emf.common.util.URI.createPlatformResourceURI("__injectedjudotypes/_synthetic.jsl", true)
		
		val XtextResourceSet xtextResourceSet =  injector.getInstance(XtextResourceSet);	
		var Resource judoTypesResource = xtextResourceSet.getResource(judoTypesResourceURI, false);
		if (judoTypesResource === null) {
			judoTypesResource = xtextResourceSet.createResource(judoTypesResourceURI);
			judoTypesResource.load(new StringInputStream(model().toString), null);
		}
		judoTypesResource		
	}


	def List<IEObjectDescription> getDescriptions() {
		val IResourceDescription resourceDescription = mgr.getResourceDescription(getResource());
		resourceDescription.getExportedObjects().toList;
	}

	def IScope getScope(IScope parentScope, EReference reference, Predicate<IEObjectDescription> filter) {
		var judoTypes = getDescriptions()
		if (filter !== null) {
			judoTypes = judoTypes
				.filter[f | !(f.EObjectOrProxy instanceof ModelDeclaration)]
				.filter[f | filter.apply(f)].toList
		}
		return new SimpleScope(parentScope, judoTypes, false);	
	}

	def IScope getModelDeclarationScope(IScope parentScope) {
		var judoTypes = getDescriptions().filter[f | f.EObjectOrProxy instanceof ModelDeclaration].toList
		return new SimpleScope(parentScope, judoTypes, false);	
	}

	 	
	def model() '''
		model judo::types;
		
		type boolean Boolean;
		type date Date;
		type time Time;
		type timestamp Timestamp;
		type numeric Integer(precision = 15, scale = 0);
		type string String(min-size = 0, max-size = 4000);
		
		// type numeric Scaled(precision = 9, scale = 2);
		// type binary Binary(mime-types = ["application/octet-stream", "text/plain"], max-file-size=1 MB);
		// type binary Image(mime-types = ["image/*"], max-file-size=1 MB);
		// type binary PDF(mime-types = ["application/pdf"], max-file-size=5 MB);

	'''
		
}