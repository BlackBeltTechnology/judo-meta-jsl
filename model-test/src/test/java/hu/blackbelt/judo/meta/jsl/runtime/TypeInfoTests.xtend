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
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDerivedDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityQueryDeclaration
import static org.junit.Assert.assertTrue

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
		//assertEquals(TypeInfo.PrimitiveType.BOOLEAN, boolAttrTypeInfo.getPrimitive);

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
		assertTrue(boolAttrTypeInfo.isBoolean());
		///assertEquals(TypeInfo.PrimitiveType.BOOLEAN, boolAttrTypeInfo.getPrimitive);
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
				derived String left => "Test"!left(count = 1);
				derived String right => "Test"!right(count = 1);
				derived Integer position => "Test"!position(substring = "es");
				derived String substring => "Test"!substring(count = 1, offset = 2);
				derived String lower => "Test"!lower();
				derived String upper => "Test"!upper();
				derived String lowerCase => "Test"!lower();
				derived String upperCase => "Test"!upper();
				derived String capitalize => "Test"!capitalize();
				derived Boolean matches => "Test"!matches(pattern = r".*es.*");
				derived Boolean like => "Test"!like(pattern = "%es%");
				derived Boolean ilike => "Test"!ilike(pattern = "%es%");
				derived String replace => "Test"!replace(oldstring = "es", newstring = "ee");
				derived String trim => "Test"!trim();
				derived String ltrim => "Test"!ltrim();
				derived String rtrim => "Test"!rtrim();
				derived String lpad => "Test"!lpad(size = 10, padstring = "--");
				derived String rpad => "Test"!rpad(size = 10, padstring = "--");
				derived Integer size => "Test"!size();
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test") 

		val firstField = testEntity.memberByName("left") as EntityDerivedDeclaration
		val lastField = testEntity.memberByName("right") as EntityDerivedDeclaration
		val positionField = testEntity.memberByName("position") as EntityDerivedDeclaration
		val substringField = testEntity.memberByName("substring") as EntityDerivedDeclaration
		val lowerField = testEntity.memberByName("lower") as EntityDerivedDeclaration
		val upperField = testEntity.memberByName("upper") as EntityDerivedDeclaration
		val lowerCaseField = testEntity.memberByName("lowerCase") as EntityDerivedDeclaration
		val upperCaseField = testEntity.memberByName("upperCase") as EntityDerivedDeclaration


		val capitalizeField = testEntity.memberByName("capitalize") as EntityDerivedDeclaration
		val matchesField = testEntity.memberByName("matches") as EntityDerivedDeclaration
		val likeField = testEntity.memberByName("like") as EntityDerivedDeclaration
		val ilikeField = testEntity.memberByName("ilike") as EntityDerivedDeclaration
		val replaceField = testEntity.memberByName("replace") as EntityDerivedDeclaration
		val trimField = testEntity.memberByName("trim") as EntityDerivedDeclaration
		val ltrimField = testEntity.memberByName("ltrim") as EntityDerivedDeclaration
		val rtrimField = testEntity.memberByName("rtrim") as EntityDerivedDeclaration
		val lpadField = testEntity.memberByName("lpad") as EntityDerivedDeclaration
		val rpadField = testEntity.memberByName("rpad") as EntityDerivedDeclaration
		val sizeField = testEntity.memberByName("size") as EntityDerivedDeclaration


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
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(sizeField.expression).getPrimitive);

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
	def void testNowFunction() {
		val m = '''
			model TestModel;
			
			type date Date;
			type timestamp Timestamp;
			type time Time;
			
			entity Test {
				derived Date date => Date!now();
				derived Timestamp timestamp => Timestamp!now();
				derived Time time => Time!now();
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test") 
		val dateField = testEntity.memberByName("date") as EntityDerivedDeclaration
		val timestampField = testEntity.memberByName("timestamp") as EntityDerivedDeclaration
		val timeField = testEntity.memberByName("time") as EntityDerivedDeclaration

		assertEquals(TypeInfo.PrimitiveType.DATE, TypeInfo.getTargetType(dateField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.TIMESTAMP, TypeInfo.getTargetType(timestampField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.TIME, TypeInfo.getTargetType(timeField.expression).getPrimitive);
	}

	@Test
	def void testDefinedFunction() {
		val m = '''
			model TestModel;
			
			type numeric Integer(precision = 9, scale = 0);
			type date Date;
			type timestamp Timestamp;
			type time Time;
			type string String(min-size = 0, max-size = 32);
			type boolean Boolean;
			
			entity Test {
				derived Boolean numeric => Integer!getVariable(category = "ENV", key = "NUMERIC")!isDefined();
				derived Boolean date => Date!getVariable(category = "ENV", key = "DATE")!isDefined();
				derived Boolean timestamp => Timestamp!getVariable(category = "ENV", key = "TIMESTAMP")!isDefined();
				derived Boolean time => Time!getVariable(category = "ENV", key = "TIME")!isDefined();
				derived Boolean string => String!getVariable(category = "ENV", key = "STRING")!isDefined();
				derived Boolean boolean => Boolean!getVariable(category = "ENV", key = "BOOLEAN")!isDefined();
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test") 
		val numericField = testEntity.memberByName("numeric") as EntityDerivedDeclaration
		val dateField = testEntity.memberByName("date") as EntityDerivedDeclaration
		val timestampField = testEntity.memberByName("timestamp") as EntityDerivedDeclaration
		val timeField = testEntity.memberByName("time") as EntityDerivedDeclaration
		val stringField = testEntity.memberByName("string") as EntityDerivedDeclaration
		val booleanField = testEntity.memberByName("boolean") as EntityDerivedDeclaration

		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(numericField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(dateField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(timestampField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(timeField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(stringField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(booleanField.expression).getPrimitive);
	}

	@Test
	def void testUndefinedFunction() {
		val m = '''
			model TestModel;
			
			type numeric Integer(precision = 9, scale = 0);
			type date Date;
			type timestamp Timestamp;
			type time Time;
			type string String(min-size = 0, max-size = 32);
			type boolean Boolean;
			
			entity Test {
				derived Integer numeric => 12!isUndefined();
				derived Date date => `2022-01-01`!isUndefined();
				derived Timestamp timestamp => `2022-01-01T12:00:00Z`!isUndefined();
				derived Time time => `12:00:00`!isUndefined();
				derived String string => "Test"!isUndefined();
				derived Boolean boolean => true!isUndefined();

			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test") 
		val numericField = testEntity.memberByName("numeric") as EntityDerivedDeclaration
		val dateField = testEntity.memberByName("date") as EntityDerivedDeclaration
		val timestampField = testEntity.memberByName("timestamp") as EntityDerivedDeclaration
		val timeField = testEntity.memberByName("time") as EntityDerivedDeclaration
		val stringField = testEntity.memberByName("string") as EntityDerivedDeclaration
		val booleanField = testEntity.memberByName("boolean") as EntityDerivedDeclaration

		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(numericField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(dateField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(timestampField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(timeField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(stringField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(booleanField.expression).getPrimitive);
	}
	
	@Test
	def void testCollectionSizeFunction() {
		val m = '''
			model TestModel;
			
			type numeric Integer(precision = 9, scale = 0);
			type date Date;
			type timestamp Timestamp;
			type time Time;
			type string String(min-size = 0, max-size = 32);
			type boolean Boolean;

			entity T1 {				
			}
			
			entity Test {
				relation T1[] t1s;
				derived Integer size => self.t1s!size();

			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test") 
		val sizeField = testEntity.memberByName("size") as EntityDerivedDeclaration

		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(sizeField.expression).getPrimitive);
	}

	@Test
	def void testOrElseFunction() {
		val m = '''
			model TestModel;
			
			type numeric Integer(precision = 9, scale = 0);
			type date Date;
			type timestamp Timestamp;
			type time Time;
			type string String(min-size = 0, max-size = 32);
			type boolean Boolean;

			entity Test {
				relation T1[] t1s;
				derived Integer numeric => 12!orElse(value = 11);
				derived Date date => `2022-01-01`!orElse(value = `2022-01-01`);
				derived Timestamp timestamp => `2022-01-01T12:00:00Z`!orElse(value = `2023-01-01T12:00:00Z`);
				derived Time time => `12:00:00`!orElse(value = `13:00:00`);
				derived String string => "Test"!orElse(value = "Test2");
				derived Boolean boolean => true!orElse(value = false);
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
	def void testNumericFunction() {
		val m = '''
			model TestModel;
			
			type numeric Decimal(precision = 9, scale = 2);
			
			entity Test {
				derived Integer floor => 12!floor();
				derived Integer ceil => 12!ceil();
				derived Integer abs => 12!abs();
				derived Integer round => 12!round(scale = 2);
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test") 
		val floorField = testEntity.memberByName("floor") as EntityDerivedDeclaration
		val ceilField = testEntity.memberByName("ceil") as EntityDerivedDeclaration
		val absField = testEntity.memberByName("abs") as EntityDerivedDeclaration
		val roundField = testEntity.memberByName("round") as EntityDerivedDeclaration

		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(floorField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(ceilField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(absField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(roundField.expression).getPrimitive);
	}
	
	
	@Test
	def void testAsStringFunction() {
		val m = '''
			model TestModel;
			
			type numeric Integer(precision = 9, scale = 0);
			type date Date;
			type timestamp Timestamp;
			type time Time;
			type string String(min-size = 0, max-size = 32);
			type boolean Boolean;

			entity Test {
				derived String numeric => 12!asString();
				derived String date => `2022-01-01`!asString();
				derived String timestamp => `2022-01-01T12:00:00Z`!asString();
				derived String time => `12:00:00`!asString();
				derived String boolean => true!asString();
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test") 
		val numericField = testEntity.memberByName("numeric") as EntityDerivedDeclaration
		val dateField = testEntity.memberByName("date") as EntityDerivedDeclaration
		val timestampField = testEntity.memberByName("timestamp") as EntityDerivedDeclaration
		val timeField = testEntity.memberByName("time") as EntityDerivedDeclaration
		val booleanField = testEntity.memberByName("boolean") as EntityDerivedDeclaration

		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(numericField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(dateField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(timestampField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(timeField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(booleanField.expression).getPrimitive);
	}

	@Test
	def void testDateFunctions() {
		val m = '''
			model TestModel;
			
			type date Date;

			entity Test {
				derived Integer year => `2022-01-01`!year();
				derived Integer month => `2022-01-01`!month();
				derived Integer day => `2022-01-01`!day();
				derived Integer dayOfWeek => `2022-01-01`!dayOfWeek();
				derived Integer dayOfYear => `2022-01-01`!dayOfYear();
				derived Date date => Date!of(year = 2022, month = 1, day = 1);
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test") 
		val yearField = testEntity.memberByName("year") as EntityDerivedDeclaration
		val monthField = testEntity.memberByName("month") as EntityDerivedDeclaration
		val dayField = testEntity.memberByName("day") as EntityDerivedDeclaration
		val dayOfWeekField = testEntity.memberByName("dayOfWeek") as EntityDerivedDeclaration
		val dayOfYearField = testEntity.memberByName("dayOfYear") as EntityDerivedDeclaration
		val dateField = testEntity.memberByName("date") as EntityDerivedDeclaration

		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(yearField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(monthField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(dayField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(dayOfWeekField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(dayOfYearField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.DATE, TypeInfo.getTargetType(dateField.expression).getPrimitive);

	}

	@Test
	def void testTimeFunctions() {
		val m = '''
			model TestModel;
			
			type time Time;

			entity Test {
				derived Integer hour => `12:00:00`!hour();
				derived Integer minute => `12:00:00`!minute();
				derived Integer second => `12:00:00`!second();
				derived Time time => Time!of(hour = 12, minute = 2, second = 23);
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test") 
		val hourField = testEntity.memberByName("hour") as EntityDerivedDeclaration
		val minuteField = testEntity.memberByName("minute") as EntityDerivedDeclaration
		val secondField = testEntity.memberByName("second") as EntityDerivedDeclaration
		val timeField = testEntity.memberByName("time") as EntityDerivedDeclaration

		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(hourField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(minuteField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(secondField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.TIME, TypeInfo.getTargetType(timeField.expression).getPrimitive);
	}

	@Test
	def void testTimestampFunctions() {
		val m = '''
			model TestModel;
			
			type timestamp Timestamp;
			type date Date;
			type time Time;
			type numeric Integer(precision = 10, scale = 0);

			entity Test {
				derived Date date => `2022-01-01T12:00:00Z`!date();
				derived Time time => `2022-01-01T12:00:00Z`!time();
				derived Integer asMilliseconds => `2022-01-01T12:00:00Z`!asMilliseconds();
				derived Timestamp fromMilliseconds => Timestamp!fromMilliseconds(milliseconds = 12);
				derived Timestamp timestamp => Timestamp!of(date = Date!of(year = 2022, month = 1, day = 1), time = Time!of(hour = 12, minute = 2, second = 23));
				derived Timestamp plus => `2022-01-01T12:00:00Z`!plus(years = 1, months = -1, days = 0, hours = 12, minutes = 11, seconds = 1, milliseconds = 12);

			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test") 
		val dateField = testEntity.memberByName("date") as EntityDerivedDeclaration
		val timeField = testEntity.memberByName("time") as EntityDerivedDeclaration
		val asMillisecondsField = testEntity.memberByName("asMilliseconds") as EntityDerivedDeclaration
		val fromMillisecondsField = testEntity.memberByName("fromMilliseconds") as EntityDerivedDeclaration
		val timestampField = testEntity.memberByName("timestamp") as EntityDerivedDeclaration
		val plusField = testEntity.memberByName("plus") as EntityDerivedDeclaration

		assertEquals(TypeInfo.PrimitiveType.DATE, TypeInfo.getTargetType(dateField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.TIME, TypeInfo.getTargetType(timeField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(asMillisecondsField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.TIMESTAMP, TypeInfo.getTargetType(fromMillisecondsField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.TIMESTAMP, TypeInfo.getTargetType(timestampField.expression).getPrimitive);
		assertEquals(TypeInfo.PrimitiveType.TIMESTAMP, TypeInfo.getTargetType(plusField.expression).getPrimitive);

	}

	@Test
	def void testEntityInstanceFunctions() {
		val m = '''
			model TestModel;
			
			type boolean Boolean;

			entity T1 {
			}

			entity T2 extends T1 {
			}

			entity Test {
				field T1 t1;
				field T2 t2;
				field T2[] t2s;

				derived Boolean typeOf => self.t1!typeOf(entityType = T1);
				derived Boolean kindOf => self.t1!kindOf(entityType = T1);
				derived Test container => self.t1!container(entityType = Test);
				derived T1 asType => self.t2!asType(entityType = T1);
				derived Boolean memberOf => self.t2!memberOf(instances = self.t2s);

			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test") 
		val t1Field = testEntity.memberByName("t1") as EntityFieldDeclaration		

		val typeOfField = testEntity.memberByName("typeOf") as EntityDerivedDeclaration
		val kindOfField = testEntity.memberByName("kindOf") as EntityDerivedDeclaration
		val containerField = testEntity.memberByName("container") as EntityDerivedDeclaration
		val asTypeField = testEntity.memberByName("asType") as EntityDerivedDeclaration

		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(typeOfField.expression).getPrimitive)
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(kindOfField.expression).getPrimitive)
		
		val TypeInfo containerTypeInfo = TypeInfo.getTargetType(containerField.expression)
		assertEquals(testEntity, containerTypeInfo.getEntity)
		//assertEquals(true, containerTypeInfo.isInstance)
		assertEquals(false, containerTypeInfo.isCollection)		

		val TypeInfo asTypeTypeInfo = TypeInfo.getTargetType(asTypeField.expression)
		assertEquals(t1Field.referenceType, asTypeTypeInfo.getEntity)
		//assertEquals(true, containerTypeInfo.isInstance)
		assertEquals(false, containerTypeInfo.isCollection)		

		val memberOfField = testEntity.memberByName("memberOf") as EntityDerivedDeclaration
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(memberOfField.expression).getPrimitive)

	}

	@Test
	def void testSelectorFunctions() {
		val m = '''
			model TestModel;
			
			type string String(min-size = 0, max-size = 32);

			entity T1 {
				field String name;
			}

			entity Test {
				field T1[] t1s;
				field T1 t1;

				// derived T1[] head => self.t1s!head(name = ASC);
				// derived T1[] tail => self.t1s!tail(name = ASC);
				derived T1 any => self.t1s!any();
				derived Integer size => self.t1s!size();
				derived T1[] asCollection => self.t1!asCollection(entityType = T1);
				derived Boolean contains => self.t1s!contains(instance = self.t1);

			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test") 
		val t1sField = testEntity.memberByName("t1s") as EntityFieldDeclaration		
		val t1Field = testEntity.memberByName("t1") as EntityFieldDeclaration		

		// val headField = testEntity.memberByName("head") as EntityDerivedDeclaration		
		// val tailField = testEntity.memberByName("tail") as EntityDerivedDeclaration		
		val anyField = testEntity.memberByName("any") as EntityDerivedDeclaration		
		val sizeField = testEntity.memberByName("size") as EntityDerivedDeclaration		
		val asCollectionField = testEntity.memberByName("asCollection") as EntityDerivedDeclaration		
		val containsField = testEntity.memberByName("contains") as EntityDerivedDeclaration		
		
		// val TypeInfo headTypeInfo = TypeInfo.getTargetType(headField.expression)
		// assertEquals(t1sField.referenceType, headTypeInfo.getEntity)
		// assertEquals(true, headTypeInfo.isInstance)
		// assertEquals(true, headTypeInfo.isCollection)		

		// val TypeInfo tailTypeInfo = TypeInfo.getTargetType(tailField.expression)
		// assertEquals(t1sField.referenceType, tailTypeInfo.getEntity)
		// assertEquals(true, tailTypeInfo.isInstance)
		// assertEquals(true, tailTypeInfo.isCollection)		

		val TypeInfo anyTypeInfo = TypeInfo.getTargetType(anyField.expression)
		assertEquals(anyField.referenceType, anyTypeInfo.getEntity)
		//assertEquals(true, anyTypeInfo.isInstance)
		assertEquals(false, anyTypeInfo.isCollection)		

		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(sizeField.expression).getPrimitive)

		val TypeInfo asCollectionTypeInfo = TypeInfo.getTargetType(anyField.expression)
		assertEquals(asCollectionField.referenceType, asCollectionTypeInfo.getEntity)
		//assertEquals(true, anyTypeInfo.isInstance)
		assertEquals(false, anyTypeInfo.isCollection)
		
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(containsField.expression).getPrimitive)
		
	}

	@Test
	def void testLambdaFunctions() {
		val m = '''
			model TestModel;
			
			type string String(min-size = 0, max-size = 32);
			type numeric Decimal(precision = 9, scale = 2);
			
			entity T1 {
				field String name;
				field Decimal price;
			}

			entity Test {
				field T1[] t1s;
				field T1 t1;

				derived T1[] filter => self.t1s!filter(t | t.name = "Test");
				derived Boolean anyTrue => self.t1s!anyTrue(t | t.name = "Test");
				derived Boolean allTrue => self.t1s!allTrue(t | t.name = "Test");
				derived Boolean anyFalse => self.t1s!anyFalse(t | t.name = "Test");
				derived Boolean allFalse => self.t1s!allFalse(t | t.name = "Test");

				derived Decimal min => self.t1s!min(t | t.price);
				derived Decimal max => self.t1s!max(t | t.price);
				derived Decimal avg => self.t1s!avg(t | t.price);
				derived Decimal sum => self.t1s!sum(t | t.price);

			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("Test") 
		val t1sField = testEntity.memberByName("t1s") as EntityFieldDeclaration		
		val t1Field = testEntity.memberByName("t1") as EntityFieldDeclaration		

		val filterField = testEntity.memberByName("filter") as EntityDerivedDeclaration		
		val anyTrueField = testEntity.memberByName("anyTrue") as EntityDerivedDeclaration		
		val allTrueField = testEntity.memberByName("allTrue") as EntityDerivedDeclaration		
		val anyFalseField = testEntity.memberByName("anyFalse") as EntityDerivedDeclaration		
		val allFalseField = testEntity.memberByName("allFalse") as EntityDerivedDeclaration		
		val minField = testEntity.memberByName("min") as EntityDerivedDeclaration		
		val maxField = testEntity.memberByName("max") as EntityDerivedDeclaration		
		val avgField = testEntity.memberByName("avg") as EntityDerivedDeclaration		
		val sumField = testEntity.memberByName("sum") as EntityDerivedDeclaration		
		
		val TypeInfo filterTypeInfo = TypeInfo.getTargetType(filterField.expression)
		assertEquals(filterField.referenceType, filterTypeInfo.getEntity)
		//assertEquals(true, filterTypeInfo.isInstance)
		assertEquals(true, filterTypeInfo.isCollection)

		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(anyTrueField.expression).getPrimitive)
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(allTrueField.expression).getPrimitive)
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(anyFalseField.expression).getPrimitive)
		assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(allFalseField.expression).getPrimitive)

		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(minField.expression).getPrimitive)
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(maxField.expression).getPrimitive)
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(avgField.expression).getPrimitive)
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(sumField.expression).getPrimitive)

	}

	@Test
	def void testQueryFunctions() {
		val m = '''
			model TestModel;
			
			type numeric Integer(precision = 9, scale = 0);
			type string String(min-size = 0, max-size = 128);
			
			query Lead[] staticLeadsBetween(Integer minLeadsBetween = 1, Integer maxLeadsBetween = 50) => Lead!filter(lead | lead.value > minLeadsBetween and lead.value < maxLeadsBetween);
			query Lead[] staticLeadsOverWithMin(Integer minLeadsOverMin = 5) => staticLeadsBetween(minLeadsBetween = minLeadsOverMin , maxLeadsBetween = 100);
			query Integer staticLeadsBetweenCount(Integer minLeadsBetween = 1, Integer maxLeadsBetween = 50) => Lead!filter(lead | lead.value > minLeadsBetween and lead.value < maxLeadsBetween)!size();
			query Integer staticLeadsOverWithMinCount(Integer minLeadsOverMin = 5) => staticLeadsBetweenCount(minLeadsBetween = minLeadsOverMin, maxLeadsBetween = 100);
			query Lead[] staticLeadsBetweenAndSalesPersonLeads(Integer minLeadsBetween = 1, Integer maxLeadsBetween = 50) =>
				Lead!filter(lead | lead.value > minLeadsBetween and lead.value < maxLeadsBetween).salesPerson.leadsBetween(minLeadsBetween = minLeadsBetween, maxLeadsBetween = maxLeadsBetween);
			
			entity SalesPerson {
			    relation Lead[] leads opposite salesPerson;
			
			    query Lead[] leadsBetween(Integer minLeadsBetween = 1, Integer maxLeadsBetween = 50) => self.leads!filter(lead | lead.value > minLeadsBetween and lead.value < maxLeadsBetween);
			    query Lead[] leadsOverWithMin(Integer minLeadsOverMin = 5) => self.leadsBetween(minLeadsBetween = minLeadsOverMin , maxLeadsBetween = 100);
			    query Lead[] leadsOverWithMinStatic(Integer minLeadsOverMin = 5) => staticLeadsBetween(minLeadsBetween = minLeadsOverMin, maxLeadsBetween = 100);
			    
			    derived Lead[] leadsOver10 => self.leadsOverWithMin(minLeadsOverMin = 10);			
			    derived Lead[] leadsOver20 => self.leadsBetween(minLeadsBetween = 20);			
			    derived Lead[] leadsOver10Static => staticLeadsOverWithMin(minLeadsOverMin = 10);			
			    derived Lead[] leadsOver20Static => staticLeadsBetween(minLeadsBetween = 20);
			    
			    query Integer leadsBetweenCount(Integer minLeadsBetween = 1, Integer maxLeadsBetween = 50) => self.leads!filter(lead | lead.value > minLeadsBetween and lead.value < maxLeadsBetween)!size();
			    query Integer leadsOverWithMinCount(Integer minLeadsOverMin = 5) => self.leadsBetweenCount(minLeadsBetween = minLeadsOverMin, maxLeadsBetween = 100);

			    derived Integer leadsOver10Count => self.leadsOverWithMinCount(minLeadsOverMin = 10);			
			    derived Integer leadsOver20Count => self.leadsBetweenCount(minLeadsBetween = 20);
			    derived Integer leadsOver10CountStatic => staticLeadsOverWithMinCount(minLeadsOverMin = 10);
				derived Integer leadsOver20CountStatic => staticLeadsBetweenCount(minLeadsBetween = 20);
			}
			
			entity Lead {
			    field Integer value = 100000;
			    relation required SalesPerson salesPerson opposite leads;
			}
		'''.parse.fromModel
	
		val testEntity = m.entityByName("SalesPerson") 
		
		val staticLeadsBetweenQuery = m.queryByName("staticLeadsBetween")
		val staticLeadsOverWithMinQuery = m.queryByName("staticLeadsOverWithMin")
		val staticLeadsBetweenCountQuery = m.queryByName("staticLeadsBetweenCount")
		val staticLeadsOverWithMinCountQuery = m.queryByName("staticLeadsOverWithMinCount")
		val staticLeadsBetweenAndSalesPersonLeadsQuery = m.queryByName("staticLeadsBetweenAndSalesPersonLeads")

		val leadsRelation = testEntity.memberByName("leads") as EntityRelationDeclaration		

		val leadsBetweenQuery = testEntity.memberByName("leadsBetween") as EntityQueryDeclaration

		val leadsOverWithMinQuery = testEntity.memberByName("leadsOverWithMin") as EntityQueryDeclaration
		val leadsOverWithMinStaticQuery = testEntity.memberByName("leadsOverWithMinStatic") as EntityQueryDeclaration

		val leadsOver10Field = testEntity.memberByName("leadsOver10") as EntityDerivedDeclaration		
		val leadsOver20Field = testEntity.memberByName("leadsOver20") as EntityDerivedDeclaration		
		val leadsOver10StaticField = testEntity.memberByName("leadsOver10Static") as EntityDerivedDeclaration		
		val leadsOver20StaticField = testEntity.memberByName("leadsOver20Static") as EntityDerivedDeclaration		

		val leadsBetweenCountQuery = testEntity.memberByName("leadsBetweenCount") as EntityQueryDeclaration
		val leadsOverWithMinCountQuery = testEntity.memberByName("leadsOverWithMinCount") as EntityQueryDeclaration

		val leadsOver10CountField = testEntity.memberByName("leadsOver10Count") as EntityDerivedDeclaration		
		val leadsOver20CountField = testEntity.memberByName("leadsOver20Count") as EntityDerivedDeclaration		
		val leadsOver10CountStaticField = testEntity.memberByName("leadsOver10CountStatic") as EntityDerivedDeclaration		
		val leadsOver20CountStaticField = testEntity.memberByName("leadsOver20CountStatic") as EntityDerivedDeclaration		


		val TypeInfo staticLeadsBetweenTypeInfo = TypeInfo.getTargetType(staticLeadsBetweenQuery.expression)
		assertEquals(staticLeadsBetweenQuery.referenceType, staticLeadsBetweenTypeInfo.getEntity)
		//assertEquals(true, staticLeadsBetweenTypeInfo.isInstance)
		assertEquals(true, staticLeadsBetweenTypeInfo.isCollection)

		val TypeInfo staticLeadsOverWithMinTypeInfo = TypeInfo.getTargetType(staticLeadsOverWithMinQuery.expression)
		assertEquals(staticLeadsOverWithMinQuery.referenceType, staticLeadsOverWithMinTypeInfo.getEntity)
		//assertEquals(true, staticLeadsBetweenTypeInfo.isInstance)
		assertEquals(true, staticLeadsBetweenTypeInfo.isCollection)

		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(staticLeadsBetweenCountQuery.expression).getPrimitive)
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(staticLeadsOverWithMinCountQuery.expression).getPrimitive)

		val TypeInfo staticLeadsBetweenAndSalesPersonLeadsTypeInfo = TypeInfo.getTargetType(staticLeadsBetweenAndSalesPersonLeadsQuery.expression)
		assertEquals(staticLeadsBetweenAndSalesPersonLeadsQuery.referenceType, staticLeadsBetweenAndSalesPersonLeadsTypeInfo.getEntity)
		//assertEquals(true, staticLeadsBetweenAndSalesPersonLeadsTypeInfo.isInstance)
		assertEquals(true, staticLeadsBetweenAndSalesPersonLeadsTypeInfo.isCollection)

		val TypeInfo leadsBetweenTypeInfo = TypeInfo.getTargetType(leadsBetweenQuery.expression)
		assertEquals(leadsBetweenQuery.referenceType, leadsBetweenTypeInfo.getEntity)
		//assertEquals(true, staticLeadsBetweenAndSalesPersonLeadsTypeInfo.isInstance)
		assertEquals(true, staticLeadsBetweenAndSalesPersonLeadsTypeInfo.isCollection)

		val TypeInfo leadsOverWithMinTypeInfo = TypeInfo.getTargetType(leadsOverWithMinQuery.expression)
		assertEquals(leadsOverWithMinQuery.referenceType, leadsOverWithMinTypeInfo.getEntity)
		//assertEquals(true, leadsOverWithMinTypeInfo.isInstance)
		assertEquals(true, leadsOverWithMinTypeInfo.isCollection)

		val TypeInfo leadsOverWithMinStaticTypeInfo = TypeInfo.getTargetType(leadsOverWithMinStaticQuery.expression)
		assertEquals(leadsOverWithMinStaticQuery.referenceType, leadsOverWithMinStaticTypeInfo.getEntity)
		//assertEquals(true, leadsOverWithMinStaticTypeInfo.isInstance)
		assertEquals(true, leadsOverWithMinStaticTypeInfo.isCollection)

		val TypeInfo leadsOver10TypeInfo = TypeInfo.getTargetType(leadsOver10Field.expression)
		assertEquals(leadsOver10Field.referenceType, leadsOver10TypeInfo.getEntity)
		//assertEquals(true, leadsOver10TypeInfo.isInstance)
		assertEquals(true, leadsOver10TypeInfo.isCollection)

		val TypeInfo leadsOver20TypeInfo = TypeInfo.getTargetType(leadsOver20Field.expression)
		assertEquals(leadsOver20Field.referenceType, leadsOver20TypeInfo.getEntity)
		//assertEquals(true, leadsOver20TypeInfo.isInstance)
		assertEquals(true, leadsOver20TypeInfo.isCollection)

		val TypeInfo leadsOver10StaticTypeInfo = TypeInfo.getTargetType(leadsOver10StaticField.expression)
		assertEquals(leadsOver10StaticField.referenceType, leadsOver10StaticTypeInfo.getEntity)
		//assertEquals(true, leadsOver10StaticTypeInfo.isInstance)
		assertEquals(true, leadsOver10StaticTypeInfo.isCollection)

		val TypeInfo leadsOver20StaticTypeInfo = TypeInfo.getTargetType(leadsOver20StaticField.expression)
		assertEquals(leadsOver20StaticField.referenceType, leadsOver20StaticTypeInfo.getEntity)
		//assertEquals(true, leadsOver20StaticTypeInfo.isInstance)
		assertEquals(true, leadsOver20StaticTypeInfo.isCollection)
				
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(leadsBetweenCountQuery.expression).getPrimitive)
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(leadsOverWithMinCountQuery.expression).getPrimitive)
		
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(leadsOver10CountField.expression).getPrimitive)
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(leadsOver20CountField.expression).getPrimitive)
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(leadsOver10CountStaticField.expression).getPrimitive)
		assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(leadsOver20CountStaticField.expression).getPrimitive)

	}


}
