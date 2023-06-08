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
import hu.blackbelt.judo.requirement.report.annotation.Requirement

@ExtendWith(InjectionExtension)
@InjectWith(JslDslInjectorProvider)
class EntityMemberDeclarationTests {
    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-TYPE-001",
        "REQ-TYPE-006",
        "REQ-EXPR-001",
        "REQ-EXPR-004"
    ])
    def void testSelfInDefaultNotAllowed() {
        '''
            model test;

            type boolean Boolean;

            entity A {
                field Boolean a;
                field Boolean b = self.a;
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.entityStoredFieldDeclaration, JslDslValidator.SELF_NOT_ALLOWED,"Self is not allowed in default expression at 'b'.")
        ]
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-012",
        "REQ-TYPE-001",
        "REQ-TYPE-004"
    ])
    def void testDuplicateInheritedMembersInvalid() {
        '''
            model test;

            type string String(min-size = 0, max-size = 12);

            entity B1 {
                field String name;
            }

            entity B2 {
                field String name;
            }

            entity A extends B1,B2 {
            }

        '''.parse => [
            assertInheritedMemberNameCollisionError("Inherited member name collision for: 'test::B1.name', 'test::B2.name'", JsldslPackage::eINSTANCE.entityDeclaration)
        ]
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-TYPE-001",
        "REQ-TYPE-004",
        "REQ-SYNT-004"
    ])
    def void testMemberNameTooLong() {
        '''
            model test;

            type string String(min-size = 0, max-size = 12);

            entity Person {
                field String tgvkyzidsggsdxxrszoscrljgnnixjzkyztoxpdvvqbmlrpzaakkwcczsarbqrqjnphrlfkfcjgcmgbxdexakswitdmcfjyjblkmiknvdgtyxlunkolxzaneifhyizgureqemldvypsongytiwmfaqrnxuodiunflyduwzerdossywvzgkmvdbfvpumaqzdazqomqwoaqynrixrwirmtbqmihmwkjmdaulwnfoxcmzldaxyjnihbluepwdswz;
            }

        '''.parse => [
            assertInheritedMemberNameLengthError("Member name: 'tgvkyzidsggsdxxrszoscrljgnnixjzkyztoxpdvvqbmlrpzaakkwcczsarbqrqjnphrlfkfcjgcmgbxdexakswitdmcfjyjblkmiknvdgtyxlunkolxzaneifhyizgureqemldvypsongytiwmfaqrnxuodiunflyduwzerdossywvzgkmvdbfvpumaqzdazqomqwoaqynrixrwirmtbqmihmwkjmdaulwnfoxcmzldaxyjnihbluepwdswz' is too long, it must be 128 characters at most.", JsldslPackage::eINSTANCE.entityMemberDeclaration)
        ]
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-007",
        "REQ-TYPE-001",
        "REQ-TYPE-004"
    ])
    def void testFieldIsManyRequired() {
        //TODO: JNG-4381
        '''
            model test;

            type string String min-size:0 max-size:1000;

            entity B1 {
                field required String[] attr;
            }

        '''.parse => [
        	m | m.assertError(JsldslPackage::eINSTANCE.entityDeclaration, "org.eclipse.xtext.diagnostics.Diagnostic.Syntax")
        ]
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-007",
        "REQ-TYPE-001",
        "REQ-TYPE-004"
    ])
    def void testRelationIsManyRequired() {
    	// this test is unnecessary, the new JSL syntax does not allow required keyword for collections
    	
        '''
            model test;

            type string String min-size:0 max-size:1000;

            entity B1 {
                relation required B2[] others;
            }

            entity B2 {
                String name;
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.entityDeclaration, "org.eclipse.xtext.diagnostics.Diagnostic.Syntax")
        ]
    }

    def private void assertInheritedMemberNameCollisionError(ModelDeclaration modelDeclaration, String error, EClass target) {
        modelDeclaration.assertError(
            target,
            JslDslValidator.INHERITED_MEMBER_NAME_COLLISION,
            error
        )
    }

    def private void assertInheritedMemberNameLengthError(ModelDeclaration modelDeclaration, String error, EClass target) {
        modelDeclaration.assertError(
            target,
            JslDslValidator.MEMBER_NAME_TOO_LONG,
            error
        )
    }

    @Test
    @Requirement(reqs = #[
        "REQ-ENT-009",
        "REQ-ENT-010"
    ])
    def void testQueryParameterExpression() {
        '''
            model test;

            import judo::types;

            entity E {
                field Integer e;

                field Integer q(Integer p = 10 + 10) <= E!all()!size();
            }
        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    @Requirement(reqs = #[
        "REQ-ENT-009",
        "REQ-ENT-010"
    ])
    def void testQueryParameterSelf() {
        '''
            model test;

            import judo::types;

            entity E {
                field Integer e;

                query Integer q(Integer p = self.e) => E!all()!size();
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.queryParameterDeclaration, JslDslValidator.SELF_NOT_ALLOWED,"Self is not allowed in parameter default expression at 'p'.")
        ]
    }

    @Test
    @Requirement(reqs = #[
        "REQ-ENT-009",
        "REQ-ENT-010"
    ])
    def void testQueryParameterParameter() {
        '''
            model test;

            import judo::types;

            entity E {
                field Integer e;

                query Integer q(Integer p = 10, Integer q = p) => E!all()!size();
            }
        '''.parse.assertError(
            JsldslPackage::eINSTANCE.navigationBaseDeclarationReference,
            "org.eclipse.xtext.diagnostics.Diagnostic.Linking",
            "Couldn't resolve reference to NavigationBaseDeclaration 'p'."
        )
    }
}
