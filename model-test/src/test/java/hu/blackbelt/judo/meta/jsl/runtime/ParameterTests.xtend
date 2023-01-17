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
class ParameterTests {
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension ValidationTestHelper
	
	@Test
    @Requirement(reqs =#[
        
    ])
	def void testDuplicateParameter() {
		'''
			model ParametersModel;
			
			type string String(min-size = 0, max-size = 100);
			
			entity Test {
				field String leftValue = "hello"!left(count = 1, count = 1);
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.functionArgument, JslDslValidator.DUPLICATE_PARAMETER)
		]
	}


	@Test
    @Requirement(reqs =#[
        
    ])
	def void testMissingRequiredParemeter() {
		'''
			model ParametersModel;
			
			type string String(min-size = 0, max-size = 100);
			
			entity Test {
				field String leftValue = "hello"!left();
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.functionCall, JslDslValidator.MISSING_REQUIRED_PARAMETER)
		]
	}

	@Test
    @Requirement(reqs =#[
        
    ])
	def void testFunctionParemeterTypeMismatch() {
		'''
			model ParametersModel;
			
			type string String(min-size = 0, max-size = 100);
			
			entity Test {
				field String leftValue = "hello"!left(count = "");
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.functionArgument, JslDslValidator.TYPE_MISMATCH)
		]
	}

	@Test
    @Requirement(reqs =#[
        
    ])
	def void testInvalidLambdaExpression() {
		'''
			model ParametersModel;
			
			type binary Binary(mime-types = ["text/plain"], max-file-size=1 GB);
			
			entity Test {
				field Binary binary;
				field Test[] head = Test!all()!first(t | t.binary);
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.lambdaCall, JslDslValidator.INVALID_LAMBDA_EXPRESSION)
		]
	}

	@Test
    @Requirement(reqs =#[
        
    ])
	def void testSelfNotAllowedInLambda() {
		'''
			model ParametersModel;
			
			type string String(min-size = 0, max-size = 100);
			
			entity Test {
				field String value;
				derived Test[] tests => Test!all()!filter(t | t.value == self.value);
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.lambdaCall, JslDslValidator.SELF_NOT_ALLOWED)
		]
	}

}
