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
class AssociationTests {
	
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension ValidationTestHelper
	
	@Test 
	def void testOppositeNameValid() {
		'''
			model Test
			entity A {
				relation B b opposite a
			}
			
			entity B {
				relation A a opposite b
			}
			
		'''.parse => [
			assertNoErrors
		]
	}

	@Test 
	def void testOppositeNameInvalid() {
		'''
			model Test
			entity A {
				relation B b
			}
			
			entity B {
				relation A a opposite b2
			}
			
		'''.parse => [
			assertOppositeLinkingError("Couldn't resolve reference to EntityRelationDeclaration 'b2'")
		]
	}


	@Test 
	def void testOppositeMissingBackReference() {
		'''
			model Test
			entity A {
				relation B b
			}
			
			entity B {
				relation A a opposite b
			}
			
		'''.parse => [
			assertOppositeMismatchError(
				"The relation does not reference to a relation, while  the following relations referencing this relation as opposite: 'Test::B#a'"
			)

			assertOppositeMismatchError(
				"The opposite relation's opposite relation does not match 'b'"
			)

		]
	}

	def private void assertOppositeLinkingError(ModelDeclaration modelDeclaration, String error) {
		modelDeclaration.assertError(
			JsldslPackage::eINSTANCE.entityRelationOpposite, 
			"org.eclipse.xtext.diagnostics.Diagnostic.Linking", 
			error
		)
	}

	def private void assertOppositeMismatchError(ModelDeclaration modelDeclaration, String error) {
		modelDeclaration.assertError(
			JsldslPackage::eINSTANCE.entityRelationDeclaration, 
			JslDslValidator.OPPOSITE_TYPE_MISMATH, 
			error
		)
	}

}	
