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
			model ErrorTypeCreateModel
			
			type numeric Integer precision 9  scale 0
			type string String max-length 128
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
			model ErrorTypeCreateModel
			
			type numeric Integer precision 9  scale 0
			type string String max-length 128
			type boolean Bool
			
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
			model ErrorTypeCreateModel
			
			type numeric Integer precision 9  scale 0
			type string String max-length 128
			type boolean Bool
			
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
			model ErrorTypeCreateModel
			
			type numeric Decimal precision 9  scale 3
			type string String max-length 128
			type boolean Bool
			
			entity Test {
				field Decimal decimalAttr = "hello"
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.defaultExpressionType, JslDslValidator.DEFAULT_TYPE_MISMATCH, "Default value type: 'EscapedStringLiteral' does not match member type: 'Decimal'")
		]
	}
}
