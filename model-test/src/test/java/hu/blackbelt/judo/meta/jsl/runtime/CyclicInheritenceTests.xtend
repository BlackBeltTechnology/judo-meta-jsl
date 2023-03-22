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
class CyclicInheritenceTests {

    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-ENT-001",
        "REQ-ENT-012"
    ])
    def void testInheritedSame() {
        '''
            model Test;

            entity A extends A {
            }

        '''.parse => [
            assertInheritenceCycleError("Cycle in the inheritance tree of entity 'A'.")
        ]
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-ENT-001",
        "REQ-ENT-012"
    ])
    def void testInheritedDuplicateMemberNameValid() {
        '''
            model Inheritence;

            entity A extends C {
            }

            entity B extends A {
            }

            entity C extends B {
            }

        '''.parse => [
            assertInheritenceCycleError("Cycle in the inheritance tree of entity 'A'.")
            assertInheritenceCycleError("Cycle in the inheritance tree of entity 'B'.")
            assertInheritenceCycleError("Cycle in the inheritance tree of entity 'C'.")
        ]
    }

    def private void assertInheritenceCycleError(ModelDeclaration modelDeclaration, String error) {
        modelDeclaration.assertError(
            JsldslPackage::eINSTANCE.entityDeclaration,
            JslDslValidator.INHERITENCE_CYCLE,
            error
        )
    }
}
