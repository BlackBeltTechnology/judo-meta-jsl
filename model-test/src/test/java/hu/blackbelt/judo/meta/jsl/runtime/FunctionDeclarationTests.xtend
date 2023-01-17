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
import hu.blackbelt.judo.requirement.report.annotation.Requirement

@ExtendWith(InjectionExtension) 
@InjectWith(JslDslInjectorProvider)
class FunctionDeclarationTests {
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension ValidationTestHelper
	
	@Test
    @Requirement(reqs =#[
        
    ])
	def void testInvalidFunctionDeclaration() {
		'''
			model FunctionModel;
						
			function number test() on number;
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.named, JslDslValidator.INVALID_DECLARATION)
		]
	}

	@Test
    @Requirement(reqs =#[
        
    ])
	def void testInvalidLambdaDeclaration() {
		'''
			model FunctionModel;
						
			lambda number test();
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.named, JslDslValidator.INVALID_DECLARATION)
		]
	}
}
