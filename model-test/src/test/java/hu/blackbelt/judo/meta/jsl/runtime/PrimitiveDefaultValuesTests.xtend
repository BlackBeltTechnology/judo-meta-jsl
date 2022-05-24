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
			model PrimitiveDefaultsModel
			
			type boolean Bool
			
			entity Test {
				field Bool boolAttr = "hello"
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.defaultExpressionType, JslDslValidator.DEFAULT_TYPE_MISMATCH, "Default value type: 'EscapedStringLiteral' does not match member type: 'Bool'")
		]
	}
	
	@Test
	def void testStringLiteralDefaultTypeMismatch() {
		'''
			model PrimitiveDefaultsModel
			
			type string String max-length 128
			
			entity Test {
				field String stringAttr = 123
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.defaultExpressionType, JslDslValidator.DEFAULT_TYPE_MISMATCH, "Default value type: 'IntegerLiteral' does not match member type: 'String'")
		]
	}
	
	@Test
	def void testIntegerDefaultTypeMismatch() {
		'''
			model PrimitiveDefaultsModel
			
			type numeric Integer precision 9  scale 0
			
			entity Test {
				field Integer intAttr = "hello"
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.defaultExpressionType, JslDslValidator.DEFAULT_TYPE_MISMATCH, "Default value type: 'EscapedStringLiteral' does not match member type: 'Integer'")
		]
	}
	
	@Test
	def void testDecimalDefaultTypeMismatch() {
		'''
			model PrimitiveDefaultsModel
			
			type numeric Decimal precision 9  scale 3
			
			entity Test {
				field Decimal decimalAttr = "hello"
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.defaultExpressionType, JslDslValidator.DEFAULT_TYPE_MISMATCH, "Default value type: 'EscapedStringLiteral' does not match member type: 'Decimal'")
		]
	}
	
	@Test
	def void testDateDefaultTypeMismatch() {
		'''
			model PrimitiveDefaultsModel
			
			type date Date
			
			entity Test {
				field Date dateAttr = "hello"
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.defaultExpressionType, JslDslValidator.DEFAULT_TYPE_MISMATCH, "Default value type: 'EscapedStringLiteral' does not match member type: 'Date'")
		]
	}
	
	@Test
	def void testTimeDefaultTypeMismatch() {
		'''
			model PrimitiveDefaultsModel
			
			type time Time
			
			entity Test {
				field Time timeAttr = "hello"
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.defaultExpressionType, JslDslValidator.DEFAULT_TYPE_MISMATCH, "Default value type: 'EscapedStringLiteral' does not match member type: 'Time'")
		]
	}
	
	@Test
	def void testTimestampDefaultTypeMismatch() {
		'''
			model PrimitiveDefaultsModel
			
			type timestamp Timestamp
			
			entity Test {
				field Timestamp timestampAttr = "hello"
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.defaultExpressionType, JslDslValidator.DEFAULT_TYPE_MISMATCH, "Default value type: 'EscapedStringLiteral' does not match member type: 'Timestamp'")
		]
	}
}
