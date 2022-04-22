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
class EnumDeclarationTests {
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension ValidationTestHelper
	
	@Test
	def void testEnumLiteralCaseInsensitiveNameCollision() {
		'''
			model test
			
			enum Genre {
				CLASSIC = 0
				POP = 1
				pop = 2
			}
			
			entity Person {
				field Genre favoredGenre
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.enumLiteral, JslDslValidator.ENUM_LITERAL_NAME_COLLISION, "Enumeration Literal name collision for: 'test.Genre.POP', 'test.Genre.pop'")
		]
	}
	
	@Test
	def void testEnumLiteralOrdinalCollision() {
		'''
			model test
			
			enum Genre {
				CLASSIC = 0
				POP = 1
				METAL = 1
			}
			
			entity Person {
				field Genre favoredGenre
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.enumLiteral, JslDslValidator.ENUM_LITERAL_ORDINAL_COLLISION, "Enumeration Literal ordinal collision for: 'test.Genre.POP': '1', 'test.Genre.METAL': '1'")
		]
	}
}
