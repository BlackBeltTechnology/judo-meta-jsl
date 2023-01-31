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
class AssociationTests {

    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-ENT-001",
        "REQ-ENT-004",
        "REQ-ENT-006"
    ])
    def void testOppositeNameValid() {
        '''
            model Test;
            entity A {
                relation B b opposite a;
            }

            entity B {
                relation A a opposite b;
            }

        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-ENT-001",
        "REQ-ENT-004",
        "REQ-ENT-006"
    ])
    def void testOppositeNameInvalid() {
        '''
            model Test;
            entity A {
                relation B b;
            }

            entity B {
                relation A a opposite b2;
            }

        '''.parse => [
            assertOppositeLinkingError("Couldn't resolve reference to EntityRelationDeclaration 'b2'")
        ]
    }


    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-ENT-001",
        "REQ-ENT-004",
        "REQ-ENT-006"
    ])
    def void testOppositeMissingBackReference() {
        '''
            model Test;
            entity A {
                relation B b;
            }

            entity B {
                relation A a opposite b;
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

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-ENT-001",
        "REQ-ENT-004",
        "REQ-ENT-006"
    ])
    def void testOppositeNameIsAlreadyDefined() {
        '''
            model Test;
            entity A {
                relation B b;
            }

            entity B {
                relation A a opposite-add b;
            }

        '''.parse => [
            assertDuplicateNameError("Duplicate name: 'b'")
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

    def private void assertDuplicateNameError(ModelDeclaration modelDeclaration, String error) {
        modelDeclaration.assertError(
            JsldslPackage::eINSTANCE.entityRelationOpposite,
            JslDslValidator.DUPLICATE_MEMBER_NAME,
            error
        )
    }

}
