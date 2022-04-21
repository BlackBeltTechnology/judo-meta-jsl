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
class EntityMemberDeclarationTests {
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension ValidationTestHelper
	
	@Test 
	def void testDuplicateInheritedMembersInvalid() {
		'''
			model test
			
			type string String max-length 12
			
			entity B1 {
			    String name
			}
			
			entity B2 {
			    String name
			}
			
			entity A extends B1,B2 {
			}

		'''.parse => [
			assertInheritedMemberNameCollisionError("Inherited member name collision for: 'test::B1#name', 'test::B2#name'", JsldslPackage::eINSTANCE.entityDeclaration)
		]
	}

	def private void assertInheritedMemberNameCollisionError(ModelDeclaration modelDeclaration, String error, EClass target) {
		modelDeclaration.assertError(
			target, 
			JslDslValidator.INHERITED_MEMBER_NAME_COLLISION, 
			error
		)
	}
}
