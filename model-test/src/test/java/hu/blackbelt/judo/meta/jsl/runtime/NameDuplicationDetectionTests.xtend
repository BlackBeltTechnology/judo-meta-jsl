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
class NameDuplicationDetectionTests {
	
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension ValidationTestHelper
	
	@Test 
	def void testDuplicateMemberNameValid() {
		'''
			model Test
			type string String max-length 128

			entity A {
				relation B b opposite a
				field String b
			}

			entity B {
				relation A a opposite b
			}
			
		'''.parse => [
			assertDuplicateMemberName("Duplicate name: 'b'", JsldslPackage::eINSTANCE.entityFieldDeclaration)
			assertDuplicateMemberName("Duplicate name: 'b'", JsldslPackage::eINSTANCE.entityRelationDeclaration)
		]
	}

	@Test 
	def void testInheritedDuplicateMemberNameValid() {
		'''
			model Inheritence
			
			type string String max-length 100
			
			entity A {
				field String name
			}
			
			entity A1 extends A {
				field String name
			}
		'''.parse => [
			assertOppositeMismatchError("Duplicate name: 'name'", JsldslPackage::eINSTANCE.entityFieldDeclaration)
		]
	}

	@Test 
	def void testDuplicateDeclarationName() {
		'''
			model DuplicatedEntityName
			
			type string String max-length 100
			
			entity A {
			}
			
			entity A {
			}
		'''.parse => [
			assertDuplicateDeclarationName("Duplicate name: 'A'", JsldslPackage::eINSTANCE.entityDeclaration)
		]
	}

	@Test 
	def void testDuplicateDeclarationWithCaseName() {
		'''
			model DuplicatedEntityName
			
			type string String max-length 100
			
			entity A {
			}
			
			entity a {
			}
		'''.parse => [
			assertDuplicateDeclarationName("Duplicate name: 'A'", JsldslPackage::eINSTANCE.entityDeclaration)
			assertDuplicateDeclarationName("Duplicate name: 'a'", JsldslPackage::eINSTANCE.entityDeclaration)

		]
	}

	@Test 
	def void testDuplicateDeclarationEntityWithErrorCollosion() {
		'''
			model DuplicatedEntityName
			
			type string String max-length 100
			
			entity A {
			}
			
			error a {
			}
		'''.parse => [
			assertDuplicateDeclarationName("Duplicate name: 'A'", JsldslPackage::eINSTANCE.entityDeclaration)
			assertDuplicateDeclarationName("Duplicate name: 'a'", JsldslPackage::eINSTANCE.errorDeclaration)
		]
	}

	def private void assertOppositeMismatchError(ModelDeclaration modelDeclaration, String error, EClass target) {
		modelDeclaration.assertError(
			target, 
			JslDslValidator.DUPLICATE_MEMBER_NAME, 
			error
		)
	}


	def private void assertDuplicateDeclarationName(ModelDeclaration modelDeclaration, String error, EClass target) {
		modelDeclaration.assertError(
			target, 
			JslDslValidator.DUPLICATE_DECLARATION_NAME, 
			error
		)
	}


	def private void assertDuplicateMemberName(ModelDeclaration modelDeclaration, String error, EClass target) {
		modelDeclaration.assertError(
			target, 
			JslDslValidator.DUPLICATE_MEMBER_NAME, 
			error
		)
	}

}	
