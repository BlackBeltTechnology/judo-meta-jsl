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
import org.eclipse.emf.ecore.util.EcoreUtil

@Singleton
class JudoFunctionsProvider {
	
	@Inject IResourceDescription.Manager mgr;
	@Inject Injector injector

	def Resource getResource() {
		val judoFunctionsResourceURI = org.eclipse.emf.common.util.URI.createPlatformResourceURI("__injectedjudofunctions/_synthetic.jsl", true)

		val XtextResourceSet xtextResourceSet =  injector.getInstance(XtextResourceSet);	
		var Resource judoFunctionsResource = xtextResourceSet.getResource(judoFunctionsResourceURI, false);
		if (judoFunctionsResource === null) {
			judoFunctionsResource = xtextResourceSet.createResource(judoFunctionsResourceURI);
			judoFunctionsResource.load(new StringInputStream(model().toString), null);
		}
		
		judoFunctionsResource
	}


	def List<IEObjectDescription> getDescriptions() {
		val IResourceDescription resourceDescription = mgr.getResourceDescription(getResource());
		resourceDescription.getExportedObjects().toList;
	}

	def IScope getScope(IScope parentScope) {
		var judoFunctions = getDescriptions().filter[f | !(f.EObjectOrProxy instanceof ModelDeclaration)].toList
		
//		if (filter !== null) {
//			judoFunctions = judoFunctions
//				.filter[f | !(f.EObjectOrProxy instanceof ModelDeclaration)]
//				.filter[f | filter.apply(f)].toList
//		}
		
		return new SimpleScope(parentScope, judoFunctions, false);	
	}

	def IScope getModelDeclarationScope(IScope parentScope) {
		var judoFunctions = getDescriptions().filter[f | f.EObjectOrProxy instanceof ModelDeclaration].toList
		return new SimpleScope(parentScope, judoFunctions, false);	
	}
	 	
	def model() '''
		model judo::functions;

		function string asString() on boolean;
		function string asString() on enum;
		
		function boolean isDefined() on boolean;
		function boolean isDefined() on numeric;
		function boolean isDefined() on string;
		function boolean isDefined() on date;
		function boolean isDefined() on time;
		function boolean isDefined() on timestamp;
		function boolean isDefined() on enum;
		function boolean isDefined() on entity;
		
		function boolean isUndefined() on boolean;
		function boolean isUndefined() on numeric;
		function boolean isUndefined() on string;
		function boolean isUndefined() on date;
		function boolean isUndefined() on time;
		function boolean isUndefined() on timestamp;
		function boolean isUndefined() on enum;
		function boolean isUndefined() on entity;
		
		function boolean orElse(required boolean value) on boolean;
		function numeric orElse(required numeric value) on numeric;
		function string orElse(required string value) on string;
		function date orElse(required date value) on date;
		function time orElse(required time value) on time;
		function timestamp orElse(required timestamp value) on timestamp;
		function enum orElse(required enum value) on enum;
		function entity orElse(required entity value) on entity;
		
		function boolean getVariable(required string category, required string key) on declaration<boolean>;
		function numeric getVariable(required string category, required string key) on declaration<numeric>;
		function string getVariable(required string category, required string key) on declaration<string>;
		function date getVariable(required string category, required string key) on declaration<date>;
		function time getVariable(required string category, required string key) on declaration<time>;
		function timestamp getVariable(required string category, required string key) on declaration<timestamp>;
		
		function numeric size() on string;
		function string left(required numeric count) on string;
		function string right(required numeric count) on string;
		function numeric position(required string substring) on string;
		function string substring(required numeric offset, required numeric count) on string;
		function string lower() on string;
		function string upper() on string;
		function string capitalize() on string;
		function boolean matches(required string pattern) on string;
		function boolean like(required string pattern) on string;
		function boolean ilike(required string pattern) on string;
		function string replace(required string oldstring, required string newstring) on string;
		function string trim() on string;
		function string ltrim() on string;
		function string rtrim() on string;
		function string lpad(required numeric size, string padstring) on string;
		function string rpad(required numeric size, string padstring) on string;
		
		function numeric round(numeric scale) on numeric;
		function numeric floor() on numeric;
		function numeric ceil() on numeric;
		function numeric abs() on numeric;
		function string asString() on numeric;
		
		function date now() on declaration<date>;
		function numeric year() on date;
		function numeric month() on date;
		function numeric day() on date;
		function date of(required numeric year, required numeric month, required numeric day) on declaration<date>;
		function numeric dayOfWeek() on date;
		function numeric dayOfYear() on date;
		function string asString() on date;
		
		function time now() on declaration<time>;
		function numeric hour() on time;
		function numeric minute() on time;
		function numeric second() on time;
		function time of(required numeric hour, required numeric minute, required numeric second) on declaration<time>;
		function string asString() on time;
		
		function timestamp now() on declaration<timestamp>;
		function date date() on timestamp;
		function time time() on timestamp;
		function timestamp of(required date date, required time time) on declaration<timestamp>;
		function numeric asMilliseconds() on timestamp;
		function timestamp fromMilliseconds(required numeric milliseconds) on declaration<timestamp>;
		function timestamp plus(numeric milliseconds, numeric seconds, numeric minutes, numeric hours, numeric days, numeric months, numeric years) on timestamp;
		function string asString() on timestamp;
		
		function boolean typeOf(required declaration<entity> entityType) on entity;
		function boolean kindOf(required declaration<entity> entityType) on entity;
		function entity container(required declaration<entity> entityType) on entity;   //  type change !!!!!!!!!
		function entity asType(required declaration<entity> entityType) on entity;      //  type change !!!!!!!!!
		function boolean memberOf(required collection<entity> instances) on entity;
		
		function collection<entity> all() on declaration<entity>;
		
		lambda collection<entity> first();
		lambda collection<entity> last();
		lambda collection<entity> front();
		lambda collection<entity> back();
		lambda collection<entity> filter();
		lambda boolean anyTrue();
		lambda boolean allTrue();
		lambda boolean anyFalse();
		lambda boolean allFalse();
		lambda numeric min();
		lambda numeric max();
		lambda numeric avg();
		lambda numeric sum();
		
		function entity any() on collection<entity>;
		function numeric size() on collection<entity>;
		function collection<entity> asCollection(required declaration<entity> entityType) on collection<entity>;   //  type change !!!!!!!!!
		function boolean contains(required entity instance) on collection<entity>;
	'''
		
}