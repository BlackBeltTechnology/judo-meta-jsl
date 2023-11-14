package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.emf.ecore.resource.Resource
import javax.inject.Singleton
import com.google.inject.Inject
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.util.StringInputStream
import org.eclipse.xtext.scoping.impl.SimpleScope
import java.util.List
import com.google.inject.Injector
import org.eclipse.xtext.resource.XtextResourceSet
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration

@Singleton
class JudoMetaProvider {
	static List<IEObjectDescription> descriptions;
	static List<IEObjectDescription> judoMeta;
	
	@Inject IResourceDescription.Manager mgr;
	@Inject Injector injector

	def Resource getResource() {
		val judoMetaResourceURI = org.eclipse.emf.common.util.URI.createPlatformResourceURI("__injectedjudometa/_synthetic.jsl", true)

		val XtextResourceSet xtextResourceSet =  injector.getInstance(XtextResourceSet);	
		var Resource judoMetaResource = xtextResourceSet.getResource(judoMetaResourceURI, false);
		if (judoMetaResource === null) {
			judoMetaResource = xtextResourceSet.createResource(judoMetaResourceURI);
			judoMetaResource.load(new StringInputStream(model().toString), null);
		}
		
		judoMetaResource
	}


	def List<IEObjectDescription> getDescriptions() {
		if (descriptions === null) {
			val IResourceDescription resourceDescription = mgr.getResourceDescription(getResource());
			descriptions = resourceDescription.getExportedObjects().toList;
		}
		
		return descriptions
	}

	def IScope getScope(IScope parentScope) {
		if (judoMeta === null) {
			judoMeta = getDescriptions().filter[f | !(f.EObjectOrProxy instanceof ModelDeclaration)].toList
		}
		return new SimpleScope(parentScope, judoMeta, false);	
	}

	def IScope getModelDeclarationScope(IScope parentScope) {
		var judoMeta = getDescriptions().filter[f | f.EObjectOrProxy instanceof ModelDeclaration].toList
		return new SimpleScope(parentScope, judoMeta, false);	
	}

    def model() '''
		model judo::meta;
		
		type string JudoMetaString min-size:0 max-size:4000;
		
		enum BaseType {
			string = 1;
			boolean = 2;
		}
		
		entity Named {
			field required JudoMetaString name;
		}
		
		entity Type extends Named {
			field BaseType base;
		}
		
		entity Field extends Named {
			field Type type;
		}
		
		entity Class extends Named {
			field Field[] fields;
			field Relation[] relations;
		}
		
		entity Relation extends Named {
			relation required Class reference;
		}
		
		entity Entity extends Class {
			relation Entity[] supertypes;
			relation Entity[] subtypes;
		}
		
		entity Transfer extends Class {
			relation Entity map;
		}
		
		entity View extends Transfer {
		}
		
		entity Actor extends Transfer {
		}
    '''

}
