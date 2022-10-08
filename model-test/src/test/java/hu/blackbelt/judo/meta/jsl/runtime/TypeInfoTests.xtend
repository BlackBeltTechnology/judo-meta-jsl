package hu.blackbelt.judo.meta.jsl.runtime

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.^extension.ExtendWith
import org.eclipse.xtext.testing.util.ParseHelper
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.junit.jupiter.api.Test
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension
import static org.junit.jupiter.api.Assertions.assertEquals
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityIdentifierDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDerivedDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration

@ExtendWith(InjectionExtension) 
@InjectWith(JslDslInjectorProvider)
class TypeInfoTests {
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension JslDslModelExtension 	
	
	@Test
	def void testPrimitiveField() {
		val m = '''
			model PrimitiveDefaultsModel;
			
			type boolean Bool;
			
			entity Test {
				field Bool boolAttr;
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test")
		val boolAttr = testEntity.memberByName("boolAttr")
		
		val boolAttrTypeInfo = TypeInfo.getTargetType(boolAttr)
		
		assertEquals(false, boolAttrTypeInfo.isCollection);
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, boolAttrTypeInfo.getPrimitive);

	}

	@Test
	def void testIdentifier() {
		val m = '''
			model TestModel;
			
			type boolean Bool;
			
			entity Test {
				identifier Bool boolAttr;
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test")
		val boolAttr = testEntity.memberByName("boolAttr")
		
		val boolAttrTypeInfo = TypeInfo.getTargetType(boolAttr)
		
		assertEquals(false, boolAttrTypeInfo.isCollection);
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, boolAttrTypeInfo.getPrimitive);
	}

	@Test
	def void testSingleField() {
		val m = '''
			model TestModel;
			
			type boolean Bool;

			entity T1 {
			}

			
			entity Test {
				field T1 t1;
			}
		'''.parse.fromModel
		
		val testEntity = m.entityByName("Test")
		val t1Field = testEntity.memberByName("t1")
		
		val t1FieldTypeInfo = TypeInfo.getTargetType(t1Field)
		
		assertEquals(false, t1FieldTypeInfo.isCollection);
		assertEquals((t1Field as EntityFieldDeclaration).referenceType, t1FieldTypeInfo.getEntity);
	}

	@Test
	def void testCollectionField() {
		val m = '''
			model TestModel;

			entity T1 {
			}
			
			entity Test {
				field T1[] t1s;
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test")
		val t1sField = testEntity.memberByName("t1s")
		
		val t1sFieldTypeInfo = TypeInfo.getTargetType(t1sField)
		
		assertEquals(true, t1sFieldTypeInfo.isCollection);
		assertEquals((t1sField as EntityFieldDeclaration).referenceType, t1sFieldTypeInfo.getEntity);
	}


	@Test
	def void testSelfDerivedToSingleField() {
		val m = '''
			model TestModel;
			
			entity T1 {
			}

			
			entity Test {
				field T1 t1;
				derived T1 t1d => self.t1;
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test")
		val t1Field = testEntity.memberByName("t1")
		val t1dField = testEntity.memberByName("t1d")
		
		val t1dFieldTypeInfo = TypeInfo.getTargetType(t1dField)
		val t1dFieldExpressionTypeInfo = TypeInfo.getTargetType((t1dField as EntityDerivedDeclaration).expression);
		
		assertEquals(false, t1dFieldTypeInfo.isCollection);
		assertEquals((t1Field as EntityFieldDeclaration).referenceType, t1dFieldTypeInfo.getEntity);
		assertEquals((t1Field as EntityFieldDeclaration).referenceType, t1dFieldExpressionTypeInfo.getEntity);
	}


	@Test
	def void testSelfDerivedToCollectionField() {
		val m = '''
			model TestModel;
			
			entity T1 {
			}

			
			entity Test {
				field T1[] t1s;
				derived T1[] t1sd => self.t1s;
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test")
		val t1sField = testEntity.memberByName("t1s")
		val t1sdField = testEntity.memberByName("t1sd")
		
		val t1sdFieldTypeInfo = TypeInfo.getTargetType(t1sdField)
		val t1sdFieldExpressionTypeInfo = TypeInfo.getTargetType((t1sdField as EntityDerivedDeclaration).expression);
		
		assertEquals(true, t1sdFieldTypeInfo.isCollection);
		assertEquals((t1sField as EntityFieldDeclaration).referenceType, t1sdFieldTypeInfo.getEntity);
		assertEquals((t1sField as EntityFieldDeclaration).referenceType, t1sdFieldExpressionTypeInfo.getEntity);
	}
	
	
	@Test
	def void testStaticDerivedToSingleField() {
		val m = '''
			model TestModel;
			
			entity T1 {
			}

			
			entity Test {
				derived T1 t1sd => T1;
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test")
		val t1sdField = testEntity.memberByName("t1sd")
		
		val t1sdFieldTypeInfo = TypeInfo.getTargetType(t1sdField)
		val t1sdFieldExpressionTypeInfo = TypeInfo.getTargetType((t1sdField as EntityDerivedDeclaration).expression);
		
		assertEquals(false, t1sdFieldTypeInfo.isCollection);
		assertEquals((t1sdField as EntityDerivedDeclaration).referenceType, t1sdFieldTypeInfo.getEntity);
		assertEquals((t1sdField as EntityDerivedDeclaration).referenceType, t1sdFieldExpressionTypeInfo.getEntity);
	}


		@Test
	def void testSingleRelation() {
		val m = '''
			model TestModel;
			
			type boolean Bool;

			entity T1 {
			}

			
			entity Test {
				relation T1 t1;
			}
		'''.parse.fromModel
		
		val testEntity = m.entityByName("Test")
		val t1Field = testEntity.memberByName("t1")
		
		val t1FieldTypeInfo = TypeInfo.getTargetType(t1Field)
		
		assertEquals(false, t1FieldTypeInfo.isCollection);
		assertEquals((t1Field as EntityRelationDeclaration).referenceType, t1FieldTypeInfo.getEntity);
	}

	@Test
	def void testCollectionRelation() {
		val m = '''
			model TestModel;

			entity T1 {
			}
			
			entity Test {
				relation T1[] t1s;
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test")
		val t1sField = testEntity.memberByName("t1s")
		
		val t1sFieldTypeInfo = TypeInfo.getTargetType(t1sField)
		
		assertEquals(true, t1sFieldTypeInfo.isCollection);
		assertEquals((t1sField as EntityRelationDeclaration).referenceType, t1sFieldTypeInfo.getEntity);
	}



	@Test
	def void testDerivedMultipleRelation() {
		val m = '''
			model TestModel;

			entity T1 {
				relation Test test;
			}

			entity T2 {
			}
			
			entity Test {
				relation T1[] t1s;
				relation T2[] t2s;

				derived T2[] t2sd => self.t1s.test.t2s;
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test")
		val t2sField = testEntity.memberByName("t2s")
		val t2sdField = testEntity.memberByName("t2sd")
		
		val t2sFieldTypeInfo = TypeInfo.getTargetType(t2sField)
		
		assertEquals(true, t2sFieldTypeInfo.isCollection);
		assertEquals((t2sField as EntityRelationDeclaration).referenceType, t2sFieldTypeInfo.getEntity);

		val t2sdFieldExpressionTypeInfo = TypeInfo.getTargetType((t2sdField as EntityDerivedDeclaration).expression);
		assertEquals((t2sdField as EntityDerivedDeclaration).referenceType, t2sdFieldExpressionTypeInfo.getEntity);

	}


	@Test
	def void testGetVariableFunction() {
		val m = '''
			model TestModel;
			
			type numeric Integer(precision = 9, scale = 0);
			type date Date;
			type timestamp Timestamp;
			type time Time;
			type string String(min-size = 0, max-size = 32);
			type boolean Boolean;
			
			entity Test {
				derived Integer numeric => Integer!getVariable(category = "ENV", key = "NUMERIC");
				derived Date date => Date!getVariable(category = "ENV", key = "DATE");
				derived Timestamp timestamp => Timestamp!getVariable(category = "ENV", key = "TIMESTAMP");
				derived Time time => Time!getVariable(category = "ENV", key = "TIME");
				derived String string => String!getVariable(category = "ENV", key = "STRING");
				derived Boolean boolean => Boolean!getVariable(category = "ENV", key = "BOOLEAN");
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test") 
		val numericField = testEntity.memberByName("numeric") as EntityDerivedDeclaration
		val dateField = testEntity.memberByName("date") as EntityDerivedDeclaration
		val timestampField = testEntity.memberByName("timestamp") as EntityDerivedDeclaration
		val timeField = testEntity.memberByName("time") as EntityDerivedDeclaration
		val stringField = testEntity.memberByName("string") as EntityDerivedDeclaration
		val booleanField = testEntity.memberByName("boolean") as EntityDerivedDeclaration

		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(numericField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.DATE, TypeInfo.getTargetType(dateField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.TIMESTAMP, TypeInfo.getTargetType(timestampField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.TIME, TypeInfo.getTargetType(timeField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(stringField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(booleanField.expression).getPrimitive);
	}

	@Test
	def void testLiterals() {
		val m = '''
			model TestModel;
			
			type numeric Integer(precision = 9, scale = 0);
			type date Date;
			type timestamp Timestamp;
			type time Time;
			type string String(min-size = 0, max-size = 32);
			type boolean Boolean;
			
			entity Test {
				derived Integer numeric => 12;
				derived Date date => `2022-01-01`;
				derived Timestamp timestamp => `2022-01-01T12:00:00Z`;
				derived Time time => `12:00:00`";
				derived String string => "Test"";
				derived Boolean boolean => true;
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test") 
		val numericField = testEntity.memberByName("numeric") as EntityDerivedDeclaration
		val dateField = testEntity.memberByName("date") as EntityDerivedDeclaration
		val timestampField = testEntity.memberByName("timestamp") as EntityDerivedDeclaration
		val timeField = testEntity.memberByName("time") as EntityDerivedDeclaration
		val stringField = testEntity.memberByName("string") as EntityDerivedDeclaration
		val booleanField = testEntity.memberByName("boolean") as EntityDerivedDeclaration

		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(numericField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.DATE, TypeInfo.getTargetType(dateField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.TIMESTAMP, TypeInfo.getTargetType(timestampField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.TIME, TypeInfo.getTargetType(timeField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(stringField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(booleanField.expression).getPrimitive);
	}
	

	@Test
	def void testStringFunctionsLiteralBase() {
		val m = '''
			model TestModel;
			
			type string String(min-size = 0, max-size = 32);
			type boolean Boolean;
			type numeric Integer(precision = 9, scale = 0);

			
			entity Test {
				derived String first => "Test"!first(count = 1);
				derived String last => "Test"!last(count = 1);
				derived Integer position => "Test"!position(substring = "es");
				derived String substring => "Test"!substring(count = 1, offset = 2);
				derived String lower => "Test"!lower();
				derived String upper => "Test"!upper();
				derived String lowerCase => "Test"!lowerCase();
				derived String upperCase => "Test"!upperCase();
				derived String capitalize => "Test"!capitalize();
				derived Boolean matches => "Test"!matches(pattern = r".*es.*");
				derived Boolean like => "Test"!like(pattern = "%es%", exact = false);
				derived String replace => "Test"!replace(oldstring = "es", newstring = "ee");
				derived String trim => "Test"!trim();
				derived String ltrim => "Test"!ltrim();
				derived String rtrim => "Test"!rtrim();
				derived String lpad => "Test"!lpad(size = 10, padsring = "--");
				derived String rpad => "Test"!rpad(size = 10, padsring = "--");
				
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test") 

		val firstField = testEntity.memberByName("first") as EntityDerivedDeclaration
		val lastField = testEntity.memberByName("last") as EntityDerivedDeclaration
		val positionField = testEntity.memberByName("position") as EntityDerivedDeclaration
		val substringField = testEntity.memberByName("substring") as EntityDerivedDeclaration
		val lowerField = testEntity.memberByName("lower") as EntityDerivedDeclaration
		val upperField = testEntity.memberByName("upper") as EntityDerivedDeclaration
		val lowerCaseField = testEntity.memberByName("lowerCase") as EntityDerivedDeclaration
		val upperCaseField = testEntity.memberByName("upperCase") as EntityDerivedDeclaration


		val capitalizeField = testEntity.memberByName("capitalize") as EntityDerivedDeclaration
		val matchesField = testEntity.memberByName("matches") as EntityDerivedDeclaration
		val likeField = testEntity.memberByName("like") as EntityDerivedDeclaration
		val replaceField = testEntity.memberByName("replace") as EntityDerivedDeclaration
		val trimField = testEntity.memberByName("trim") as EntityDerivedDeclaration
		val ltrimField = testEntity.memberByName("ltrim") as EntityDerivedDeclaration
		val rtrimField = testEntity.memberByName("rtrim") as EntityDerivedDeclaration
		val lpadField = testEntity.memberByName("lpad") as EntityDerivedDeclaration
		val rpadField = testEntity.memberByName("rpad") as EntityDerivedDeclaration


		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(firstField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(lastField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(positionField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(substringField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(lowerField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(upperField.expression).getPrimitive);

		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(lowerCaseField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(upperCaseField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(capitalizeField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(matchesField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(likeField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(upperField.expression).getPrimitive);

		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(replaceField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(trimField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(ltrimField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(rtrimField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(lpadField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(rpadField.expression).getPrimitive);


	}
	
	/*
		resource.addLiteralFunctionDeclaration("getVariable", RT_BASE_TYPE_INSTANCE, anyFunctionBasePrimitiveTypes())
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("category", false, true, PT_STRING_INSTANCE, anyFunctionBasePrimitiveTypes),
				createFunctionParameterDeclaration("key", false, true, PT_STRING_INSTANCE, anyFunctionBasePrimitiveTypes)
			])

		resource.addLiteralFunctionDeclaration("now", RT_BASE_TYPE_INSTANCE, #[BT_DATE_INSTANCE, BT_TIME_INSTANCE, BT_TIMESTAMP_INSTANCE])
		
		resource.addLiteralFunctionDeclaration("isDefined", RT_BOOLEAN_INSTANCE, anyFunctionBaseInstanceOrCollectionTypes)
		resource.addLiteralFunctionDeclaration("isUnDefined", RT_BOOLEAN_INSTANCE, anyFunctionBaseInstanceOrCollectionTypes)
		resource.addLiteralFunctionDeclaration("size", RT_NUMERIC_INSTANCE, #[BT_STRING_INSTANCE])

		resource.addLiteralFunctionDeclaration("orElse", RT_INPUT_SAME, anyFunctionBasePrimitiveInstances)
			.parameterDeclarations.addAll(#[
				createFunctionParameterDeclaration("value", false, true, PT_INPUT_SAME, anyFunctionBasePrimitiveInstances)
			])

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
				createFunctionParameterDeclaration("pattern", false, true, PT_STRING_INSTANCE, #[BT_STRING_INSTANCE]),
				createFunctionParameterDeclaration("exact", false, false, PT_BOOLEAN_INSTANCE, #[BT_STRING_INSTANCE])
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

		resource.addSelectorFunctionDeclaration("head", RT_ENTITY_COLLECTION, #[BT_ENTITY_COLLECTION])
		resource.addSelectorFunctionDeclaration("tail", RT_ENTITY_COLLECTION, #[BT_ENTITY_COLLECTION])


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


		resource.addLambdaFunctionDeclaration("filter", RT_INPUT_SAME, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("anyTrue", RT_BOOLEAN_INSTANCE, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("allTrue", RT_BOOLEAN_INSTANCE, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("anyFalse", RT_BOOLEAN_INSTANCE, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("allFalse", RT_BOOLEAN_INSTANCE, #[BT_ENTITY_COLLECTION])

		resource.addLambdaFunctionDeclaration("min", RT_NUMERIC_INSTANCE, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("max", RT_NUMERIC_INSTANCE, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("avg", RT_NUMERIC_INSTANCE, #[BT_ENTITY_COLLECTION])
		resource.addLambdaFunctionDeclaration("sum", RT_NUMERIC_INSTANCE, #[BT_ENTITY_COLLECTION])

	 */
	
}
