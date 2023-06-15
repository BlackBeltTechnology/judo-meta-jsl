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
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-004",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-EXPR-002",
        "REQ-EXPR-013"
    ])
    def void testDuplicateParameter() {
        '''
            model ParametersModel;

            type string String min-size:0 max-size:100;

            entity Test {
                field String leftValue = "hello"!left(count = 1, count = 1);
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.functionArgument, JslDslValidator.DUPLICATE_PARAMETER)
        ]
    }


    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-004",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-EXPR-002",
        "REQ-EXPR-013"
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
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-004",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-EXPR-002",
        "REQ-EXPR-013"
    ])
    def void testFunctionParemeterTypeMismatch() {
        '''
            model ParametersModel;

            type string String(min-size = 0, max-size = 100);

            entity Test {
                field String leftValue = "hello"!left(count = "");
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.functionArgument, JslDslValidator.TYPE_MISMATCH,"Type mismatch. Incompatible function argument at 'count'.")
        ]
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-010",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-007",
        "REQ-EXPR-002",
        "REQ-EXPR-008",
        "REQ-EXPR-013",
        "REQ-EXPR-022"
        //TODO: JNG-4392
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
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-010",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-007",
        "REQ-EXPR-002",
        "REQ-EXPR-008",
        "REQ-EXPR-013",
        "REQ-EXPR-022"
    ])
    def void testSelfNotAllowedInLambda() {
        '''
            model ParametersModel;

            type string String min-size:0 max-size:100;

            entity Test {
                field String value;
                relation Test[] tests <= Test!all()!filter(t | t.value == self.value);
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.lambdaCall, JslDslValidator.SELF_NOT_ALLOWED)
        ]
    }

}
