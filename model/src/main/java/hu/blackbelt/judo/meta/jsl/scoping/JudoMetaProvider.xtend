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
		
		type string String min-size:0 max-size:4000;
		
		enum Type {
			string = 1;
			boolean = 2;
			date = 3;
			time = 4;
			timestamp = 5;
			numeric = 6;
			`entity` = 7;
		}
		
		enum TransferKind {
			simple = 1;
			`view` = 2;
			`row` = 3;
			`column` = 4;
			`actor` = 5;
		}
		
		entity EntityField {
			field String name;
			field Type type;
			relation Entity target;
		}
		
		entity EntityRelation {
			field String name;
			relation Entity target;
		}
		
		entity Entity {
			field String name;
			relation Entity[] supertypes; 
			relation Entity[] subtypes;
			relation EntityField[] fields;
			relation EntityRelation[] relations;
		}
		
		entity TransferField {
			field String name;
			field Type type;
		}
		
		entity TransferRelation {
			field String name;
			relation Transfer target;
		}
		
		entity Transfer {
			field String name;
			field TransferKind kind;
			relation Entity map;
			relation TransferField[] fields;
			relation TransferRelation[] relations;
		}
    '''

}
