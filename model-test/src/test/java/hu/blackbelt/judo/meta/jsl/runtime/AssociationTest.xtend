package hu.blackbelt.judo.meta.jsl.runtime

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.^extension.ExtendWith
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelImport
import hu.blackbelt.judo.meta.jsl.validation.JslDslValidator
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import static extension org.junit.jupiter.api.Assertions.*
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.junit.jupiter.api.Test
import com.google.inject.Provider
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.diagnostics.Severity
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOpposite

@ExtendWith(InjectionExtension) 
@InjectWith(JslDslInjectorProvider)
class AssociationTest {
	
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension ValidationTestHelper
	@Inject Provider<ResourceSet> resourceSetProvider;
	
	@Test 
	def void testOppositeNameValid() {
		'''
			model Test
			entity A {
				relation B b
			}
			
			entity B {
				relation A a opposite-name b
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
				relation A a opposite-name b2
			}
			
		'''.parse => [
			assertOppositeLinkingError("Couldn't resolve reference to EntityRelationDeclaration 'b2'")
		]
	}

	def private void assertOppositeLinkingError(ModelDeclaration modelDeclaration, String error) {
		modelDeclaration.assertError(
			JsldslPackage::eINSTANCE.entityRelationOpposite, 
			"org.eclipse.xtext.diagnostics.Diagnostic.Linking", 
			error
		)
	}

}	
