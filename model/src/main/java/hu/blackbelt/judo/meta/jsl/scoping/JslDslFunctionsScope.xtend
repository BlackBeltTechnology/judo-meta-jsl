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
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionReturnType
import java.util.Collection
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionBaseType
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionParameterDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.impl.FunctionParameterDeclarationImpl
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionParameterType
import static hu.blackbelt.judo.meta.jsl.jsldsl.FunctionReturnType.*
import static hu.blackbelt.judo.meta.jsl.jsldsl.FunctionBaseType.*
import static hu.blackbelt.judo.meta.jsl.jsldsl.FunctionParameterType.*
import hu.blackbelt.judo.meta.jsl.jsldsl.LiteralFunctionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.impl.LiteralFunctionDeclarationImpl
import hu.blackbelt.judo.meta.jsl.jsldsl.impl.LambdaFunctionDeclarationImpl
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaFunctionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.SelectorFunctionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.impl.SelectorFunctionDeclarationImpl
import org.eclipse.xtext.naming.IQualifiedNameProvider
import java.util.List
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.naming.QualifiedName

@Singleton
class JslDslFunctionsScope extends AbstractResourceDescription implements IScope {
	
	val uri = org.eclipse.emf.common.util.URI.createPlatformResourceURI("__injectedobjectprovider/_synthetic.jsl", true)
	
	@Inject XtextResourceSet resourceSet
	@Inject extension IQualifiedNameProvider
	@Inject extension JslResourceDescriptionStrategy

	def getAdditionalObjectsResource() {
    	var resource = resourceSet.getResource(uri, false)
    	if (resource === null) {
    		resource = resourceSet.createResource(uri)		
	   		resource.addAllFunctions
    	}
    	return resource	
	}

	def private getFactory() {
    	JsldslFactoryImpl.init()
    	val JsldslFactory factory = new JsldslFactoryImpl()		
    	return factory
	}		

	def Collection<FunctionBaseType> anyFunctionBasePrimitiveTypes() {
		#[
			BT_STRING_TYPE,
			BT_DATE_TYPE,
			BT_BOOLEAN_TYPE,
			BT_TIME_TYPE,
			BT_TIMESTAMP_TYPE,
			BT_NUMERIC_TYPE,
			BT_BINARY_TYPE
		]
	}

	def Collection<FunctionBaseType> anyFunctionBasePrimitiveAndSingleInstances() {
		#[
			BT_STRING_INSTANCE,
			BT_DATE_INSTANCE,
			BT_BOOLEAN_INSTANCE,
			BT_TIME_INSTANCE,
			BT_TIMESTAMP_INSTANCE,
			BT_NUMERIC_INSTANCE,
			BT_BINARY_INSTANCE,
			BT_ENTITY_INSTANCE
		]
	}

	def Collection<FunctionBaseType> anyFunctionBasePrimitiveInstances() {
		#[
			BT_STRING_INSTANCE,
			BT_DATE_INSTANCE,
			BT_BOOLEAN_INSTANCE,
			BT_TIME_INSTANCE,
			BT_TIMESTAMP_INSTANCE,
			BT_NUMERIC_INSTANCE,
			BT_BINARY_INSTANCE
		]
	}

	def Collection<FunctionBaseType> anyFunctionBaseInstanceOrCollectionTypes() {
		#[
			BT_ENTITY_INSTANCE,
			BT_ENTITY_COLLECTION,
			BT_ENUM_LITERAL,
			BT_BOOLEAN_INSTANCE,
			BT_BINARY_INSTANCE,
			BT_STRING_INSTANCE,
			BT_NUMERIC_INSTANCE,
			BT_DATE_INSTANCE,
			BT_TIME_INSTANCE,
			BT_TIMESTAMP_INSTANCE
		]
	}


	def void addAllFunctions(Resource resource) {
		resource.addLiteralFunctionDeclaration("getVariable", RT_BASE_TYPE_INSTANCE, anyFunctionBasePrimitiveTypes())
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("category", false, true, PT_STRING_INSTANCE, anyFunctionBasePrimitiveTypes),
				createFunctionParameterDeclaration("key", false, true, PT_STRING_INSTANCE, anyFunctionBasePrimitiveTypes)
			])

		resource.addLiteralFunctionDeclaration("now", RT_BASE_TYPE_INSTANCE, #[BT_DATE_TYPE, BT_TIME_TYPE, BT_TIMESTAMP_TYPE])
		
		resource.addLiteralFunctionDeclaration("isDefined", RT_BOOLEAN_INSTANCE, anyFunctionBaseInstanceOrCollectionTypes)
		resource.addLiteralFunctionDeclaration("isUndefined", RT_BOOLEAN_INSTANCE, anyFunctionBaseInstanceOrCollectionTypes)
		resource.addLiteralFunctionDeclaration("size", RT_NUMERIC_INSTANCE, #[BT_STRING_INSTANCE, BT_ENTITY_COLLECTION])

		resource.addLiteralFunctionDeclaration("orElse", RT_INPUT_SAME, anyFunctionBasePrimitiveInstances)
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("value", false, true, PT_INPUT_SAME, anyFunctionBasePrimitiveInstances)
			])

		resource.addLiteralFunctionDeclaration("left", RT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("count", false, true, PT_NUMERIC_INSTANCE, #[BT_STRING_INSTANCE])
			])
		resource.addLiteralFunctionDeclaration("right", RT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("count", false, true, PT_NUMERIC_INSTANCE, #[BT_STRING_INSTANCE])
			])

		resource.addLiteralFunctionDeclaration("position", RT_NUMERIC_INSTANCE, #[BT_STRING_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("substring", false, true, PT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
			])

		resource.addLiteralFunctionDeclaration("substring", RT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("count", false, true, PT_NUMERIC_INSTANCE, #[BT_STRING_INSTANCE]),
				createFunctionParameterDeclaration("offset", false, true, PT_NUMERIC_INSTANCE, #[BT_STRING_INSTANCE])
			])
		resource.addLiteralFunctionDeclaration("lower", RT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
		resource.addLiteralFunctionDeclaration("lowerCase", RT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
		resource.addLiteralFunctionDeclaration("upper", RT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
		resource.addLiteralFunctionDeclaration("upperCase", RT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
		resource.addLiteralFunctionDeclaration("capitalize", RT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
		resource.addLiteralFunctionDeclaration("matches", RT_BOOLEAN_INSTANCE, #[BT_STRING_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("pattern", false, true, PT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
			])
		resource.addLiteralFunctionDeclaration("like", RT_BOOLEAN_INSTANCE, #[BT_STRING_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("pattern", false, true, PT_STRING_LITERAL, #[BT_STRING_INSTANCE])
			])
		resource.addLiteralFunctionDeclaration("ilike", RT_BOOLEAN_INSTANCE, #[BT_STRING_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("pattern", false, true, PT_STRING_LITERAL, #[BT_STRING_INSTANCE])
			])
		resource.addLiteralFunctionDeclaration("replace", RT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("oldstring", false, true, PT_STRING_INSTANCE, #[BT_STRING_INSTANCE]),
				createFunctionParameterDeclaration("newstring", false, true, PT_STRING_INSTANCE, #[BT_STRING_INSTANCE])

			])
		resource.addLiteralFunctionDeclaration("trim", RT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
		resource.addLiteralFunctionDeclaration("ltrim", RT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
		resource.addLiteralFunctionDeclaration("rtrim", RT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
		resource.addLiteralFunctionDeclaration("lpad", RT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("size", false, true, PT_NUMERIC_INSTANCE, #[BT_STRING_INSTANCE]),
				createFunctionParameterDeclaration("padstring", false, false, PT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
			])
		resource.addLiteralFunctionDeclaration("rpad", RT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("size", false, true, PT_NUMERIC_INSTANCE, #[BT_STRING_INSTANCE]),
				createFunctionParameterDeclaration("padstring", false, false, PT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
			])
		
		resource.addLiteralFunctionDeclaration("round", RT_NUMERIC_INSTANCE, #[BT_NUMERIC_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("scale", false, false, PT_NUMERIC_INSTANCE, #[BT_NUMERIC_INSTANCE])
			])
		resource.addLiteralFunctionDeclaration("floor", RT_NUMERIC_INSTANCE, #[BT_NUMERIC_INSTANCE])
		resource.addLiteralFunctionDeclaration("ceil", RT_NUMERIC_INSTANCE, #[BT_NUMERIC_INSTANCE])
		resource.addLiteralFunctionDeclaration("abs", RT_NUMERIC_INSTANCE, #[BT_NUMERIC_INSTANCE])
		resource.addLiteralFunctionDeclaration("asString", RT_STRING_INSTANCE, anyFunctionBasePrimitiveInstances())
		
		resource.addLiteralFunctionDeclaration("year", RT_NUMERIC_INSTANCE, #[BT_DATE_INSTANCE])
		resource.addLiteralFunctionDeclaration("month", RT_NUMERIC_INSTANCE, #[BT_DATE_INSTANCE])
		resource.addLiteralFunctionDeclaration("day", RT_NUMERIC_INSTANCE, #[BT_DATE_INSTANCE])
		resource.addLiteralFunctionDeclaration("dayOfWeek", RT_NUMERIC_INSTANCE, #[BT_DATE_INSTANCE])
		resource.addLiteralFunctionDeclaration("dayOfYear", RT_NUMERIC_INSTANCE, #[BT_DATE_INSTANCE])

		resource.addLiteralFunctionDeclaration("hour", RT_NUMERIC_INSTANCE, #[BT_TIME_INSTANCE])
		resource.addLiteralFunctionDeclaration("minute", RT_NUMERIC_INSTANCE, #[BT_TIME_INSTANCE])
		resource.addLiteralFunctionDeclaration("second", RT_NUMERIC_INSTANCE, #[BT_TIME_INSTANCE])
		
		resource.addLiteralFunctionDeclaration("fromSeconds", RT_TIME_INSTANCE, #[BT_TIME_TYPE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("seconds", false, true, PT_NUMERIC_INSTANCE, #[BT_TIME_TYPE])
			])
		resource.addLiteralFunctionDeclaration("asSeconds", RT_NUMERIC_INSTANCE, #[BT_TIME_TYPE])

		resource.addLiteralFunctionDeclaration("of", RT_BASE_TYPE_INSTANCE, #[BT_DATE_TYPE, BT_TIME_TYPE, BT_TIMESTAMP_TYPE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("year", false, true, PT_NUMERIC_INSTANCE, #[BT_DATE_TYPE]),
				createFunctionParameterDeclaration("month", false, true, PT_NUMERIC_INSTANCE, #[BT_DATE_TYPE]),
				createFunctionParameterDeclaration("day", false, true, PT_NUMERIC_INSTANCE, #[BT_DATE_TYPE]),

				createFunctionParameterDeclaration("hour", false, true, PT_NUMERIC_INSTANCE, #[BT_TIME_TYPE]),
				createFunctionParameterDeclaration("minute", false, true, PT_NUMERIC_INSTANCE, #[BT_TIME_TYPE]),
				createFunctionParameterDeclaration("second", false, true, PT_NUMERIC_INSTANCE, #[BT_TIME_TYPE]),

				createFunctionParameterDeclaration("date", false, true, PT_DATE_INSTANCE, #[BT_TIMESTAMP_TYPE]),
				createFunctionParameterDeclaration("time", false, false, PT_TIME_INSTANCE, #[BT_TIMESTAMP_TYPE])

			])

		resource.addLiteralFunctionDeclaration("date", RT_DATE_INSTANCE, #[BT_TIMESTAMP_INSTANCE])
		resource.addLiteralFunctionDeclaration("time", RT_TIME_INSTANCE, #[BT_TIMESTAMP_INSTANCE])
		resource.addLiteralFunctionDeclaration("asMilliseconds", RT_NUMERIC_INSTANCE, #[BT_TIMESTAMP_INSTANCE])
		resource.addLiteralFunctionDeclaration("fromMilliseconds", RT_TIMESTAMP_INSTANCE, #[BT_TIMESTAMP_TYPE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("milliseconds", false, true, PT_NUMERIC_INSTANCE, #[BT_TIMESTAMP_INSTANCE])
			])
		
		resource.addLiteralFunctionDeclaration("plus", RT_TIMESTAMP_INSTANCE, #[BT_TIMESTAMP_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("years", false, false, PT_NUMERIC_INSTANCE, #[BT_TIMESTAMP_INSTANCE]),
				createFunctionParameterDeclaration("months", false, false, PT_NUMERIC_INSTANCE, #[BT_TIMESTAMP_INSTANCE]),
				createFunctionParameterDeclaration("days", false, false, PT_NUMERIC_INSTANCE, #[BT_TIMESTAMP_INSTANCE]),
				createFunctionParameterDeclaration("hours", false, false, PT_NUMERIC_INSTANCE, #[BT_TIMESTAMP_INSTANCE]),
				createFunctionParameterDeclaration("minutes", false, false, PT_NUMERIC_INSTANCE, #[BT_TIMESTAMP_INSTANCE]),
				createFunctionParameterDeclaration("seconds", false, false, PT_NUMERIC_INSTANCE, #[BT_TIMESTAMP_INSTANCE]),
				createFunctionParameterDeclaration("milliseconds", false, false, PT_NUMERIC_INSTANCE, #[BT_TIMESTAMP_INSTANCE])
			])
		
		resource.addLiteralFunctionDeclaration("typeOf", RT_BOOLEAN_INSTANCE, #[BT_ENTITY_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("entityType", false, true, PT_ENTITY_TYPE, #[BT_ENTITY_INSTANCE])
			])
		resource.addLiteralFunctionDeclaration("kindOf", RT_BOOLEAN_INSTANCE, #[BT_ENTITY_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("entityType", false, true, PT_ENTITY_TYPE, #[BT_ENTITY_INSTANCE])
			])
		resource.addLiteralFunctionDeclaration("container", RT_ENTITY_INSTANCE, #[BT_ENTITY_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("entityType", false, true, PT_ENTITY_TYPE, #[BT_ENTITY_INSTANCE])
			])
		resource.addLiteralFunctionDeclaration("asType", RT_ENTITY_INSTANCE, #[BT_ENTITY_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("entityType", false, true, PT_ENTITY_TYPE, #[BT_ENTITY_INSTANCE])
			])

		resource.addLiteralFunctionDeclaration("memberOf", RT_BOOLEAN_INSTANCE, #[BT_ENTITY_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("instances", false, true, PT_ENTITY_COLLECTION, #[BT_ENTITY_INSTANCE])
			])

		resource.addLambdaFunctionDeclaration("first", RT_INPUT_SAME, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("last", RT_INPUT_SAME, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("front", RT_INPUT_SAME, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("back", RT_INPUT_SAME, #[BT_ENTITY_COLLECTION])

		resource.addLiteralFunctionDeclaration("any", RT_ENTITY_INSTANCE, #[BT_ENTITY_COLLECTION])
		resource.addLiteralFunctionDeclaration("asCollection", RT_ENTITY_COLLECTION, #[BT_ENTITY_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("entityType", false, true, PT_ENTITY_TYPE, #[BT_ENTITY_INSTANCE])
			])
		resource.addLiteralFunctionDeclaration("contains", RT_BOOLEAN_INSTANCE, #[BT_ENTITY_COLLECTION])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("instance", false, true, PT_ENTITY_INSTANCE, #[BT_ENTITY_COLLECTION])
			])


		resource.addLambdaFunctionDeclaration("filter", RT_INPUT_SAME, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("anyTrue", RT_BOOLEAN_INSTANCE, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("allTrue", RT_BOOLEAN_INSTANCE, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("anyFalse", RT_BOOLEAN_INSTANCE, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("allFalse", RT_BOOLEAN_INSTANCE, #[BT_ENTITY_COLLECTION])

		resource.addLambdaFunctionDeclaration("min", RT_NUMERIC_INSTANCE, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("max", RT_NUMERIC_INSTANCE, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("avg", RT_NUMERIC_INSTANCE, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("sum", RT_NUMERIC_INSTANCE, #[BT_ENTITY_COLLECTION])

	}

	def private LiteralFunctionDeclaration addLiteralFunctionDeclaration(
		Resource resource, 
		String name, 
		FunctionReturnType returnTypes, 
		Iterable<FunctionBaseType> acceptedBaseTypes
	) {
    	val LiteralFunctionDeclarationImpl obj = factory.createLiteralFunctionDeclaration as LiteralFunctionDeclarationImpl
    	obj.name = name
    	obj.returnTypes.addAll(returnTypes)
    	obj.acceptedBaseTypes.addAll(acceptedBaseTypes)
    	resource.contents += obj
    	return obj
  	}

	def private SelectorFunctionDeclaration addSelectorFunctionDeclaration(
		Resource resource, 
		String name, 
		FunctionReturnType returnTypes, 
		Iterable<FunctionBaseType> acceptedBaseTypes
	) {
    	val SelectorFunctionDeclarationImpl obj = factory.createSelectorFunctionDeclaration as SelectorFunctionDeclarationImpl
    	obj.name = name
    	obj.returnTypes.addAll(returnTypes)
    	obj.acceptedBaseTypes.addAll(acceptedBaseTypes)
    	resource.contents += obj
    	return obj
  	}

	def private FunctionParameterDeclaration createFunctionParameterDeclaration(
		String name, 
		boolean isMany, 
		boolean isRequired, 
		FunctionParameterType functionParameterType,
		Iterable<FunctionBaseType> parameterPresentedForBaseTypes
	) {
    	val FunctionParameterDeclarationImpl obj = factory.createFunctionParameterDeclaration as FunctionParameterDeclarationImpl
		obj.name = name
    	obj.isRequired = isRequired
    	obj.functionParameterType = functionParameterType
    	obj.parameterPresentedForBaseTypes.addAll(parameterPresentedForBaseTypes)
    	obj.isMany = isMany
    	return obj
  	}

	def private LambdaFunctionDeclaration addLambdaFunctionDeclaration(
		Resource resource, 
		String name, 
		FunctionReturnType returnTypes, 
		Iterable<FunctionBaseType> acceptedBaseTypes
	) {
    	val LambdaFunctionDeclarationImpl obj = factory.createLambdaFunctionDeclaration as LambdaFunctionDeclarationImpl
    	obj.name = name
    	obj.returnTypes.addAll(returnTypes)
    	obj.acceptedBaseTypes.addAll(acceptedBaseTypes)
    	resource.contents += obj
    	return obj
  	}

	def boolean isProvided(EObject object ) {
		#[functions].flatten.contains(object)
  	}

	def List<EObject> getFunctions() {
		additionalObjectsResource.allContents.toList
	}

	override protected computeExportedObjects() {
		functions.filter[o | o.fullyQualifiedName !== null].map[o |
					EObjectDescription::create(
						o.fullyQualifiedName, o, o.indexInfo
					)			
		].toList
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