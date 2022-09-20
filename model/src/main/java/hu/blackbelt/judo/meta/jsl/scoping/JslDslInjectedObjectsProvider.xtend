package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.xtext.resource.impl.AbstractResourceDescription
import hu.blackbelt.judo.meta.jsl.jsldsl.impl.JsldslFactoryImpl
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslFactory
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.emf.ecore.EObject
import hu.blackbelt.judo.meta.jsl.jsldsl.impl.JsldslPackageImpl
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
import hu.blackbelt.judo.meta.jsl.jsldsl.NamedFunctionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.LiteralFunctionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.impl.LiteralFunctionDeclarationImpl
import hu.blackbelt.judo.meta.jsl.jsldsl.impl.LambdaFunctionDeclarationImpl
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaFunctionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.SelectorFunctionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.impl.SelectorFunctionDeclarationImpl

@Singleton
class JslDslInjectedObjectsProvider extends AbstractResourceDescription {
	
	val uri = org.eclipse.emf.common.util.URI.createPlatformResourceURI("__injectedobjectprovider/_synthetic.jsl", true)
	
	@Inject
	XtextResourceSet resourceSet
	
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
		/*
		// String functions
		GetVariableFunction returns LiteralFunction : {LiteralFunction} name = 'getVariable' '(' parameters += FunctionParameter ')' ;
		IsDefinedFunction returns LiteralFunction : {LiteralFunction} name = 'isDefined' '(' ')';
		IsUnDefinedFunction returns LiteralFunction : {LiteralFunction} name = 'isUnDefined' '(' ')';
		LengthFunction returns LiteralFunction : {LiteralFunction} name = 'length' '(' ')';
		FirstFunction returns LiteralFunction : {LiteralFunction} name = 'first' '(' 'count' '=' parameters += FunctionParameter ')';
		LastFunction returns LiteralFunction : {LiteralFunction} name = 'last' '(' 'count' '=' parameters += FunctionParameter ')';
		PositionFunction returns LiteralFunction : {LiteralFunction} name = 'position' '(' 'offset' '='parameters += FunctionParameter ')';
		SubstringFunction returns LiteralFunction : {LiteralFunction} name = 'substring' '(' 'offset' '=' parameters += FunctionParameter ',' 'count' '=' parameters += FunctionParameter ')';
		LowerFunction returns LiteralFunction : {LiteralFunction} name = 'lower' '(' ')';
		UpperFunction returns LiteralFunction : {LiteralFunction} name = 'upper' '(' ')';
		CapitalizeFunction returns LiteralFunction : {LiteralFunction} name = 'capitalize' '(' ')';
		MatchesFunction returns LiteralFunction : {LiteralFunction} name = 'matches' '(' 'pattern' '=' parameters += FunctionParameter ')';
		LikeFunction returns LiteralFunction : {LiteralFunction} name = 'like' '(' 'pattern' '=' parameters += FunctionParameter ')';
		IlikeFunction returns LiteralFunction : {LiteralFunction} name = 'ilike' '(' 'pattern' '=' parameters += FunctionParameter ')';
		ReplaceFunction returns LiteralFunction : {LiteralFunction} name = 'replace' '(' 'oldstring' '=' parameters += FunctionParameter ',' 'newstring' '=' parameters += FunctionParameter ')';
		TrimFunction returns LiteralFunction : {LiteralFunction} name = 'trim' '(' ')';
		LtrimFunction returns LiteralFunction : {LiteralFunction} name = 'ltrim' '(' ')';
		RtrimFunction returns LiteralFunction : {LiteralFunction} name = 'rtrim' '(' ')';
		*/
		resource.addLiteralFunctionDeclaration("getVariable", RT_BASE_TYPE_INSTANCE, anyFunctionBasePrimitiveTypes())
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("category", false, true, PT_STRING_INSTANCE, anyFunctionBasePrimitiveTypes),
				createFunctionParameterDeclaration("key", false, true, PT_STRING_INSTANCE, anyFunctionBasePrimitiveTypes)
			])

		resource.addLiteralFunctionDeclaration("now", RT_BASE_TYPE_INSTANCE, #[BT_DATE_INSTANCE, BT_TIME_INSTANCE, BT_TIMESTAMP_INSTANCE])
		
		resource.addLiteralFunctionDeclaration("isDefined", RT_BOOLEAN_INSTANCE, anyFunctionBaseInstanceOrCollectionTypes)
		resource.addLiteralFunctionDeclaration("isUnDefined", RT_BOOLEAN_INSTANCE, anyFunctionBaseInstanceOrCollectionTypes)
		resource.addLiteralFunctionDeclaration("size", RT_NUMERIC_INSTANCE, #[BT_STRING_INSTANCE])

		resource.addLiteralFunctionDeclaration("first", RT_NUMERIC_INSTANCE, #[BT_STRING_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("count", false, true, PT_NUMERIC_INSTANCE, #[BT_STRING_INSTANCE])
			])
		resource.addLiteralFunctionDeclaration("last", RT_NUMERIC_INSTANCE, #[BT_STRING_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("count", false, true, PT_NUMERIC_INSTANCE, #[BT_STRING_INSTANCE])
			])

		resource.addLiteralFunctionDeclaration("position", RT_NUMERIC_INSTANCE, #[BT_STRING_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("substring", false, true, PT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
			])

		resource.addLiteralFunctionDeclaration("substring", RT_NUMERIC_INSTANCE, #[BT_STRING_INSTANCE])
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
				createFunctionParameterDeclaration("pattern", false, true, PT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
			])
		resource.addLiteralFunctionDeclaration("ilike", RT_BOOLEAN_INSTANCE, #[BT_STRING_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("pattern", false, true, PT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
			])
		resource.addLiteralFunctionDeclaration("replace", RT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("oldstring", false, true, PT_STRING_INSTANCE, #[BT_STRING_INSTANCE]),
				createFunctionParameterDeclaration("newstring", false, true, PT_STRING_INSTANCE, #[BT_STRING_INSTANCE])

			])
		resource.addLiteralFunctionDeclaration("trim", RT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
		resource.addLiteralFunctionDeclaration("ltrim", RT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
		resource.addLiteralFunctionDeclaration("rtrim", RT_STRING_INSTANCE, #[BT_STRING_INSTANCE])
		
		/*
		// Numeric functions
		RoundFunction returns LiteralFunction : {LiteralFunction} name = 'round' '(' ')';
		FloorFunction returns LiteralFunction : {LiteralFunction} name = 'floor' '(' ')';
		CeilFunction returns LiteralFunction : {LiteralFunction} name = 'ceil' '(' ')';
		AbsFunction returns LiteralFunction : {LiteralFunction} name = 'abs' '(' ')';
		AsStringFunction returns LiteralFunction : {LiteralFunction} name = 'asString' '(' ')';
		 */
		resource.addLiteralFunctionDeclaration("round", RT_NUMERIC_INSTANCE, #[BT_NUMERIC_INSTANCE])
		resource.addLiteralFunctionDeclaration("floor", RT_NUMERIC_INSTANCE, #[BT_NUMERIC_INSTANCE])
		resource.addLiteralFunctionDeclaration("ceil", RT_NUMERIC_INSTANCE, #[BT_NUMERIC_INSTANCE])
		resource.addLiteralFunctionDeclaration("abs", RT_NUMERIC_INSTANCE, #[BT_NUMERIC_INSTANCE])
		resource.addLiteralFunctionDeclaration("asString", RT_STRING_INSTANCE, anyFunctionBasePrimitiveInstances())
		
		/*
		// Date functions
		YearFunction returns LiteralFunction : {LiteralFunction} name = 'year' '(' ')';
		MonthFunction returns LiteralFunction : {LiteralFunction} name = 'month' '(' ')';
		DayFunction returns LiteralFunction : {LiteralFunction} name = 'day' '(' ')';
		DateOfFunction returns LiteralFunction : {LiteralFunction} name = 'of' '('
			  ('year' '=' parameters += FunctionParameter ',' 'month' '=' parameters += FunctionParameter ',' 'day' '=' parameters += FunctionParameter) 
			')'
			;
		// Time functions
		HourFunction returns LiteralFunction : {LiteralFunction} name = 'hour' '(' ')';
		MinuteFunction returns LiteralFunction : {LiteralFunction} name = 'minute' '(' ')';
		SecondFunction returns LiteralFunction : {LiteralFunction} name = 'second' '(' ')';
		TimeOfFunction returns LiteralFunction : {LiteralFunction} name = 'of' '('
			('hour' '=' parameters += FunctionParameter ',' 'minute' '=' parameters += FunctionParameter ',' 'second' '=' parameters += FunctionParameter)
			')'
			;
		// AsStringFunction returns Named : {AsStringFunction} name = 'asString' '(' ')';
		 */
		resource.addLiteralFunctionDeclaration("year", RT_NUMERIC_INSTANCE, #[BT_DATE_INSTANCE])
		resource.addLiteralFunctionDeclaration("month", RT_NUMERIC_INSTANCE, #[BT_DATE_INSTANCE])
		resource.addLiteralFunctionDeclaration("day", RT_NUMERIC_INSTANCE, #[BT_DATE_INSTANCE])

		resource.addLiteralFunctionDeclaration("hour", RT_NUMERIC_INSTANCE, #[BT_TIME_INSTANCE])
		resource.addLiteralFunctionDeclaration("minute", RT_NUMERIC_INSTANCE, #[BT_TIME_INSTANCE])
		resource.addLiteralFunctionDeclaration("second", RT_NUMERIC_INSTANCE, #[BT_TIME_INSTANCE])

		resource.addLiteralFunctionDeclaration("of", RT_BASE_TYPE_INSTANCE, #[BT_DATE_TYPE, BT_TIME_TYPE, BT_TIMESTAMP_TYPE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("year", false, true, PT_NUMERIC_INSTANCE, #[BT_DATE_TYPE]),
				createFunctionParameterDeclaration("month", false, true, PT_NUMERIC_INSTANCE, #[BT_DATE_TYPE]),
				createFunctionParameterDeclaration("day", false, true, PT_NUMERIC_INSTANCE, #[BT_DATE_TYPE]),

				createFunctionParameterDeclaration("hour", false, true, PT_NUMERIC_INSTANCE, #[BT_TIME_TYPE]),
				createFunctionParameterDeclaration("minute", false, true, PT_NUMERIC_INSTANCE, #[BT_TIME_TYPE]),
				createFunctionParameterDeclaration("second", false, true, PT_NUMERIC_INSTANCE, #[BT_TIME_TYPE]),

				createFunctionParameterDeclaration("date", false, true, PT_DATE_INSTANCE, #[BT_TIMESTAMP_TYPE]),
				createFunctionParameterDeclaration("time", false, true, PT_TIME_INSTANCE, #[BT_TIMESTAMP_TYPE])

			])

		/*
		// Timestamp functions
		DateFunction returns LiteralFunction : {LiteralFunction} name = 'date' '(' ')';
		TimeFunction returns LiteralFunction : {LiteralFunction} name = 'time' '(' ')';
		AsMillisecondsFunction returns LiteralFunction : {LiteralFunction} name = 'asMilliseconds' '(' ')';
		FromMillisecondsFunction returns LiteralFunction : {LiteralFunction} name = 'fromMilliseconds' '(' 'millisecond' '=' parameters += FunctionParameter ')';
		PlusMillisecondsFunction returns LiteralFunction : {LiteralFunction} name = 'plusMilliseconds' '(' 'millisecond' '=' parameters += FunctionParameter ')';
		PlusSecondsFunction returns LiteralFunction : {LiteralFunction} name = 'plusSeconds' '(' 'sec' '=' parameters += FunctionParameter ')';
		PlusMinutesFunction returns LiteralFunction : {LiteralFunction} name = 'plusMinutes' '(' 'min' '=' parameters += FunctionParameter ')';
		PlusHoursFunction returns LiteralFunction : {LiteralFunction} name = 'plusHours' '(' 'hour' '=' parameters += FunctionParameter ')';
		PlusDaysFunction returns LiteralFunction : {LiteralFunction} name = 'plusDays' '(' 'day' '=' parameters += FunctionParameter ')';
		PlusMonthsFunction returns LiteralFunction : {LiteralFunction} name = 'plusMonths' '(' 'month' '=' parameters += FunctionParameter ')';
		PlusYearsFunction returns LiteralFunction : {LiteralFunction} name = 'plusYears' '(' 'year' '=' parameters += FunctionParameter ')';
		// AsStringFunction returns Named : {AsBooleanAsStringFunction} name = 'asString' '(' ')';
		TimestampOfFunction returns LiteralFunction : {LiteralFunction} name = 'of' '('
			('date' '=' parameters += FunctionParameter ',' 'time' '=' parameters += FunctionParameter)
			')'
			;
		 */		

		resource.addLiteralFunctionDeclaration("date", RT_DATE_INSTANCE, #[BT_TIMESTAMP_INSTANCE])
		resource.addLiteralFunctionDeclaration("time", RT_TIME_INSTANCE, #[BT_TIMESTAMP_INSTANCE])
		resource.addLiteralFunctionDeclaration("asMilliseconds", RT_NUMERIC_INSTANCE, #[BT_TIMESTAMP_INSTANCE])
		resource.addLiteralFunctionDeclaration("fromMilliseconds", RT_TIMESTAMP_INSTANCE, #[BT_TIMESTAMP_TYPE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("milliseconds", false, true, PT_NUMERIC_INSTANCE, #[BT_TIMESTAMP_INSTANCE])
			])
		
		resource.addLiteralFunctionDeclaration("plus", RT_TIMESTAMP_INSTANCE, #[BT_TIMESTAMP_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("milliseconds", false, true, PT_NUMERIC_INSTANCE, #[BT_TIMESTAMP_INSTANCE]),
				createFunctionParameterDeclaration("seconds", false, true, PT_NUMERIC_INSTANCE, #[BT_TIMESTAMP_INSTANCE]),
				createFunctionParameterDeclaration("minutes", false, true, PT_NUMERIC_INSTANCE, #[BT_TIMESTAMP_INSTANCE]),
				createFunctionParameterDeclaration("hours", false, true, PT_NUMERIC_INSTANCE, #[BT_TIMESTAMP_INSTANCE]),
				createFunctionParameterDeclaration("days", false, true, PT_NUMERIC_INSTANCE, #[BT_TIMESTAMP_INSTANCE]),
				createFunctionParameterDeclaration("months", false, true, PT_NUMERIC_INSTANCE, #[BT_TIMESTAMP_INSTANCE]),
				createFunctionParameterDeclaration("years", false, true, PT_NUMERIC_INSTANCE, #[BT_TIMESTAMP_INSTANCE])
			])
		
		/*
		// Instance functions
		TypeOfFunction returns InstanceFunction : {InstanceFunction} name = 'typeOf' '(' entityDeclaration = [EntityDeclaration | LocalName] ')';
		KindOfFunction returns InstanceFunction : {InstanceFunction} name = 'kindOf' '(' entityDeclaration = [EntityDeclaration | LocalName] ')';
		ContainerFunction returns InstanceFunction : {InstanceFunction} name = 'container' '(' entityDeclaration = [EntityDeclaration | LocalName] ')';
		AsTypeFunction returns InstanceFunction : {InstanceFunction} name = 'asType' '(' entityDeclaration = [EntityDeclaration | LocalName] ')';
		*/
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

		/*
		MemberOfFunction returns LiteralFunction : {LiteralFunction} name = 'memberOf' '(' parameters += FunctionParameter ')';
		 */
		resource.addLiteralFunctionDeclaration("memberOf", RT_BOOLEAN_INSTANCE, #[BT_ENTITY_INSTANCE])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("instances", false, true, PT_ENTITY_COLLECTION, #[BT_ENTITY_INSTANCE])
			])

		/*
		 // Collection function
		HeadFunction returns SelectorFunction : {SelectorFunction} name = 'head' '(' selectorArgument = SelectorFunctionParameters ')';
		TailFunction returns SelectorFunction : {SelectorFunction} name = 'tail' '(' selectorArgument = SelectorFunctionParameters ')';
		*/
		resource.addSelectorFunctionDeclaration("head", RT_ENTITY_COLLECTION, #[BT_ENTITY_COLLECTION])
		resource.addSelectorFunctionDeclaration("tail", RT_ENTITY_COLLECTION, #[BT_ENTITY_COLLECTION])


		/*
		AnyFunction returns LambdaFunction : {LambdaFunction} name = 'any' '(' ')';
		CountFunction returns LiteralFunction : {LiteralFunction} name = 'count' '(' ')';
		AsCollectionFunction returns InstanceFunction : {InstanceFunction} name = 'asCollection' '(' entityDeclaration = [EntityDeclaration | LocalName] ')';
		ContainsFunction returns LiteralFunction : {LiteralFunction} name = 'contains' '(' parameters += FunctionParameter ')';
		*/
		resource.addLiteralFunctionDeclaration("any", RT_ENTITY_INSTANCE, #[BT_ENTITY_COLLECTION])
		resource.addLiteralFunctionDeclaration("size", RT_NUMERIC_INSTANCE, #[BT_ENTITY_COLLECTION])
		resource.addLiteralFunctionDeclaration("asCollection", RT_ENTITY_COLLECTION, #[BT_ENTITY_COLLECTION])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("entityType", false, true, PT_ENTITY_TYPE, #[BT_ENTITY_INSTANCE])
			])
		resource.addLiteralFunctionDeclaration("contains", RT_BOOLEAN_INSTANCE, #[BT_ENTITY_COLLECTION])
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("instance", false, true, PT_ENTITY_INSTANCE, #[BT_ENTITY_COLLECTION])
			])


		/*
		FilterFunction returns LambdaFunction : {LambdaFunction} name = 'filter' '(' lambdaArgument = LambdaFunctionParameters ')';
		AnyTrueFunction returns LambdaFunction : {LambdaFunction} name = 'anyTrue' '(' lambdaArgument = LambdaFunctionParameters ')';
		AllTrueFunction returns LambdaFunction : {LambdaFunction} name = 'allTrue' '(' lambdaArgument = LambdaFunctionParameters ')';
		MinFunction returns LambdaFunction : {LambdaFunction} name = 'min' '(' lambdaArgument = LambdaFunctionParameters ')';
		MaxFunction returns LambdaFunction : {LambdaFunction} name = 'max' '(' lambdaArgument = LambdaFunctionParameters ')';
		AvgFunction returns LambdaFunction : {LambdaFunction} name = 'avg' '(' lambdaArgument = LambdaFunctionParameters ')';
		SumFunction returns LambdaFunction : {LambdaFunction} name = 'sum' '(' lambdaArgument = LambdaFunctionParameters ')';		
		 */

		resource.addLambdaFunctionDeclaration("filter", RT_ENTITY_COLLECTION, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("anyTrue", RT_BOOLEAN_INSTANCE, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("allTrue", RT_BOOLEAN_INSTANCE, #[BT_ENTITY_COLLECTION])

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
    	if (object.eClass.classifierID === JsldslPackageImpl.LITERAL_FUNCTION_DECLARATION ||
    		object.eClass.classifierID === JsldslPackageImpl.LAMBDA_FUNCTION_DECLARATION ||
    		object.eClass.classifierID === JsldslPackageImpl.SELECTOR_FUNCTION_DECLARATION
    	) {
    		return allFunctions.contains(object)
   		} else {
        	return false    	
    	}
  	}

	def Collection<NamedFunctionDeclaration> getAllFunctions() {
		additionalObjectsResource.allContents.toIterable.filter(NamedFunctionDeclaration).toList
	} 
	
	override protected computeExportedObjects() {
		getAllFunctions().map[e | EObjectDescription.create(e.name, e, null)].toList
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
	
}