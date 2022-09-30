package hu.blackbelt.judo.meta.jsl.runtime

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.^extension.ExtendWith
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.junit.jupiter.api.Test
import hu.blackbelt.judo.meta.jsl.validation.JslDslValidator

@ExtendWith(InjectionExtension) 
@InjectWith(JslDslInjectorProvider)
class PrimitiveDefaultValuesTests {
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension ValidationTestHelper
	
	@Test
	def void testBoolDefaultTypeMismatch() {
		'''
			model PrimitiveDefaultsModel;
			
			type boolean Bool;
			
			entity Test {
				field Bool boolAttr = "hello";
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.defaultExpressionType, JslDslValidator.DEFAULT_TYPE_MISMATCH, "Default value type: 'EscapedStringLiteral' does not match member type: 'Bool'")
		]
	}
	
	@Test
	def void testStringLiteralDefaultTypeMismatch() {
		'''
			model PrimitiveDefaultsModel;
			
			type string String(min-size = 0, max-size = 128);			
			
			entity Test {
				field String stringAttr = 123;
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.defaultExpressionType, JslDslValidator.DEFAULT_TYPE_MISMATCH, "Default value type: 'IntegerLiteral' does not match member type: 'String'")
		]
	}
	
	@Test
	def void testIntegerDefaultTypeMismatch() {
		'''
			model PrimitiveDefaultsModel;
			
			type numeric Integer(precision = 9,  scale = 0);
			
			entity Test {
				field Integer intAttr = "hello";
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.defaultExpressionType, JslDslValidator.DEFAULT_TYPE_MISMATCH, "Default value type: 'EscapedStringLiteral' does not match member type: 'Integer'")
		]
	}
	
	@Test
	def void testDecimalDefaultTypeMismatch() {
		'''
			model PrimitiveDefaultsModel;
			
			type numeric Decimal(precision = 9, scale = 3);
			
			entity Test {
				field Decimal decimalAttr = "hello";
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.defaultExpressionType, JslDslValidator.DEFAULT_TYPE_MISMATCH, "Default value type: 'EscapedStringLiteral' does not match member type: 'Decimal'")
		]
	}
	
	@Test
	def void testDateDefaultTypeMismatch() {
		'''
			model PrimitiveDefaultsModel;
			
			type date Date;
			
			entity Test {
				field Date dateAttr = "hello";
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.defaultExpressionType, JslDslValidator.DEFAULT_TYPE_MISMATCH, "Default value type: 'EscapedStringLiteral' does not match member type: 'Date'")
		]
	}
	
	@Test
	def void testTimeDefaultTypeMismatch() {
		'''
			model PrimitiveDefaultsModel;
			
			type time Time;
			
			entity Test {
				field Time timeAttr = "hello";
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.defaultExpressionType, JslDslValidator.DEFAULT_TYPE_MISMATCH, "Default value type: 'EscapedStringLiteral' does not match member type: 'Time'")
		]
	}
	
	@Test
	def void testTimestampDefaultTypeMismatch() {
		'''
			model PrimitiveDefaultsModel;
			
			type timestamp Timestamp;
			
			entity Test {
				field Timestamp timestampAttr = "hello";
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.defaultExpressionType, JslDslValidator.DEFAULT_TYPE_MISMATCH, "Default value type: 'EscapedStringLiteral' does not match member type: 'Timestamp'")
		]
	}

	@Test
    def void testPrimitivesPassingForFieldsAndIdentifiers() {
        '''
			model PrimitiveDefaultsModel;
			
			type numeric Integer(precision = 9,  scale = 0);
			type numeric Decimal(precision = 5,  scale = 3);
			type string String(min-size = 0, max-size = 128);			
			type boolean Bool;
			type date Date;
			type time Time;
			type timestamp Timestamp;
			type string PhoneNumber(min-size = 0, max-size = 32, regex = "^(\\+\\d{1,2}\\s)?\\(?\\d{3}\\)?[\\s.-]\\d{3}[\\s.-]\\d{4}$");   // escape sequencing does not work in regexp!!!!
			
			entity TestIdentifiers {
				identifier Bool a = true;
				identifier Integer b = 3223;
				identifier Decimal b2 = 3223.123;
				identifier String c = "123";
				identifier String c2 = r"123";
				identifier Date d = `2020-01-12`;
				identifier Time e = `22:45:22`;
				identifier Timestamp f = `2020-01-12T12:12:12.000Z`;
			}
			
			entity TestFields {
				field Bool a = true;
				field Integer b = 3223;
				field Decimal b2 = 3223.123;
				field String c = "123";
				field String c2 = r"123";
				field Date d = `2020-01-12`;
				field Time e = `22:45:22`;
				field Timestamp f = `2020-01-12T12:12:12.000Z`;
			}
			
			error ErrorFields {
			    field Bool a = true;
			    field Integer b = 3223;
			    field Decimal b2 = 3223.123;
			    field String c = "123";
			    field String c2 = r"123";
			    field Date d = `2020-01-12`;
			    field Time e = `22:45:22`;
			    field Timestamp f = `2020-01-12T12:12:12.000Z`;
			}
			
			entity EntityWithPrimitiveDefaultExpressions {
			    field Integer integerAttr = 1.23!round();
			    field Decimal scaledAttr = 2.9!abs();
			    field String stringAttr = true!asString();
			    field PhoneNumber regexAttr = "+36-1-123-123";
			    field Bool boolAttr = 2 > -1;
			    field Date dateAttr = Date!now();
			    field Timestamp timestampAttr = Timestamp!now();
			    field Time timeAttr = Time!of(hour = 23, minute = 59, second = 59);
			}

        '''.parse => [
            assertNoErrors
        ]
    }
}
