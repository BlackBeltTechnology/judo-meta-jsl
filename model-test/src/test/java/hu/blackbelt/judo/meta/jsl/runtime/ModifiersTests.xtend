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
import org.eclipse.emf.ecore.EClass

@ExtendWith(InjectionExtension) 
@InjectWith(JslDslInjectorProvider)
class ModifiersTests {
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension ValidationTestHelper
	
	@Test
	def void testMaxLengthModifierNegative() {
		'''
			model test
			
			type string String max-length -1
			
			entity Person{
				field String fullName
			}

		'''.parse => [
			assertMaxLengthNegativeError("MaxLength must be greater than 0", JsldslPackage::eINSTANCE.modifierMaxLength)
		]
	}
	
	@Test 
	def void testMaxLengthModifierTooLarge() {
		'''
			model test
			
			type string String max-length 4001
			
			entity Person{
				field String fullName
			}

		'''.parse => [
			assertMaxLengthTooLargeError("MaxLength must be less than/equal to " + JslDslValidator.MODIFIER_MAX_LENGTH_MAX_VALUE, JsldslPackage::eINSTANCE.modifierMaxLength)
		]
	}

	def private void assertMaxLengthNegativeError(ModelDeclaration modelDeclaration, String error, EClass target) {
		modelDeclaration.assertError(
			target, 
			JslDslValidator.MAX_LENGTH_MODIFIER_IS_NEGATIVE, 
			error
		)
	}

	@Test
	def void testPrecisionModifierTooLow() {
		'''
			model test
			
			type numeric Number1 precision 0 scale 0
			
			entity Entity {
				field Number1 number
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.modifierPrecision, JslDslValidator.PRECISION_MODIFIER_IS_NEGATIVE, "Precision must be greater than 0")
		]
	}
	
	@Test
	def void testPrecisionModifierTooLarge() {
		'''
			model test
			
			type numeric Number1 precision 16 scale 0
			
			entity Entity {
				field Number1 number
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.modifierPrecision, JslDslValidator.PRECISION_MODIFIER_IS_TOO_LARGE, "Precision must be less than/equal to " + JslDslValidator.PRECISION_MAX_VALUE)
		]
	}
	
	@Test
	def void testScaleModifierTooLow() {
		'''
			model test
			
			type numeric Number1 precision 15 scale -1
			
			entity Entity {
				field Number1 number
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.modifierScale, JslDslValidator.SCALE_MODIFIER_IS_NEGATIVE, "Scale must be greater than/equal to 0")
		]
	}

	@Test
	def void testScaleModifierTooLarge() {
		'''
			model test
			
			type numeric Number1 precision 15 scale 15
			
			entity Entity {
				field Number1 number
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.modifierScale, JslDslValidator.SCALE_MODIFIER_IS_TOO_LARGE, "Scale must be less than the defined precision: 15")
		]
	}
	
	def private void assertMaxLengthTooLargeError(ModelDeclaration modelDeclaration, String error, EClass target) {
		modelDeclaration.assertError(
			target, 
			JslDslValidator.MAX_LENGTH_MODIFIER_IS_TOO_LARGE, 
			error
		)
	}
}
