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
	
//	@Test
//	def void testMaxLengthModifierNegative() {
//		'''
//			model test
//			
//			type string String max-length -1
//			
//			entity Person{
//				field String fullName
//			}
//
//		'''.parse => [
//			assertMaxLengthNegativeError("MaxLength must be greater than 0", JsldslPackage::eINSTANCE.modifierMaxLength)
//		]
//	}
	
	@Test 
	def void testMaxLengthModifierTooLarge() {
		'''
			model test
			
			type string String max-length 4001
			
			entity Person{
				field String fullName
			}

		'''.parse => [
			assertMaxLengthTooLargeError("MaxLength must be less than/equals to " + JslDslValidator.MODIFIER_MAX_LENGTH_MAX_VALUE, JsldslPackage::eINSTANCE.modifierMaxLength)
		]
	}

//	def private void assertMaxLengthNegativeError(ModelDeclaration modelDeclaration, String error, EClass target) {
//		modelDeclaration.assertError(
//			target, 
//			JslDslValidator.MAX_LENGTH_MODIFIER_IS_NEGATIVE, 
//			error
//		)
//	}
	
	def private void assertMaxLengthTooLargeError(ModelDeclaration modelDeclaration, String error, EClass target) {
		modelDeclaration.assertError(
			target, 
			JslDslValidator.MAX_LENGTH_MODIFIER_IS_TOO_LARGE, 
			error
		)
	}
}
