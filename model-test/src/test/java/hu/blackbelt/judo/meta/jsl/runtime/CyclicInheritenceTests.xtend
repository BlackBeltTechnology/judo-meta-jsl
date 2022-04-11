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
class CyclicInheritenceTests {
	
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension ValidationTestHelper
	
	@Test 
	def void testInheritedSame() {
		'''
			model Test

			entity A extends A {
			}
			
		'''.parse => [
			assertInheritenceCycleError("Cycle in inheritence of entity 'A'")
		]
	}

	@Test 
	def void testInheritedDuplicateMemberNameValid() {
		'''
			model Inheritence
			
			entity A extends C {
			}
			
			entity B extends A {
			}

			entity C extends B {
			}

		'''.parse => [
			assertInheritenceCycleError("Cycle in inheritence of entity 'A'")
			assertInheritenceCycleError("Cycle in inheritence of entity 'B'")
			assertInheritenceCycleError("Cycle in inheritence of entity 'C'")
		]
	}

	def private void assertInheritenceCycleError(ModelDeclaration modelDeclaration, String error) {
		modelDeclaration.assertError(
			JsldslPackage::eINSTANCE.entityDeclaration, 
			JslDslValidator.INHERITENCE_CYCLE, 
			error
		)
	}
}	
