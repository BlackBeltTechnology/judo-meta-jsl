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
class CyclicExpressionTests {

    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-ENT-001",
        "REQ-ENT-008",
        "REQ-TYPE-001",
        "REQ-TYPE-006",
        "REQ-EXPR-001",
        "REQ-EXPR-004"
    ])
    def void testSelfDerived() {
        '''
            model Test;

            type boolean Boolean;

            entity Test {
                field Boolean b <= self.b;
            }

        '''.parse.assertError(JsldslPackage::eINSTANCE.entityCalculatedMemberDeclaration, JslDslValidator.EXPRESSION_CYCLE,"Cyclic expression at 'b'.")
    }


    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-ENT-001",
        "REQ-ENT-008",
        "REQ-TYPE-001",
        "REQ-TYPE-006",
        "REQ-EXPR-001",
        "REQ-EXPR-004",
        "REQ-EXPR-005",
        "REQ-EXPR-006",
        "REQ-EXPR-007",
        "REQ-EXPR-022",
        "REQ-ENT-009",
        "REQ-ENT-010",
        "REQ-ENT-011"
    ])
    def void testComplexCycle() {
        '''
            model test;

            type boolean Boolean;

            query Boolean staticQuery() <= A!any().c;

            entity A {
                field Boolean q <= staticQuery();
                field Boolean a <= self.q();
                field Boolean b <= self.a;
                field Boolean c <= self.b;
            }
        '''.parse => [
            assertError(JsldslPackage::eINSTANCE.entityCalculatedMemberDeclaration, JslDslValidator.EXPRESSION_CYCLE,"Cyclic expression at 'q'.")
            assertError(JsldslPackage::eINSTANCE.entityCalculatedMemberDeclaration, JslDslValidator.EXPRESSION_CYCLE,"Cyclic expression at 'a'.")
            assertError(JsldslPackage::eINSTANCE.entityCalculatedMemberDeclaration, JslDslValidator.EXPRESSION_CYCLE,"Cyclic expression at 'b'.")
            assertError(JsldslPackage::eINSTANCE.entityCalculatedMemberDeclaration, JslDslValidator.EXPRESSION_CYCLE,"Cyclic expression at 'c'.")
            assertError(JsldslPackage::eINSTANCE.queryDeclaration, JslDslValidator.EXPRESSION_CYCLE,"Cyclic expression at 'staticQuery'.")
        ]
    }
}
