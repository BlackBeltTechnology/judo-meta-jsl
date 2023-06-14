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
class ModifiersTests {
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
        "REQ-ENT-002"
    ])
    def void testMinSizeModifierTooLarge() {
        '''
            model test;

            type string String min-size:129 max-size:128;

            entity Person{
                field String fullName;
            }

        '''.parse => [
            assertMinSizeTooLargeError("min-size must be less than/equal to max-size", JsldslPackage::eINSTANCE.modifierMinSize)
        ]
    }

    def private void assertMinSizeTooLargeError(ModelDeclaration modelDeclaration, String error, EClass target) {
        modelDeclaration.assertError(
            target,
            JslDslValidator.MIN_SIZE_MODIFIER_IS_TOO_LARGE,
            error
        )
    }

    def private void assertMinSizeNegativeError(ModelDeclaration modelDeclaration, String error, EClass target) {
        modelDeclaration.assertError(
            target,
            JslDslValidator.MIN_SIZE_MODIFIER_IS_NEGATIVE,
            error
        )
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
        "REQ-ENT-002"
    ])
    def void testMaxSizeModifierZero() {
        '''
            model test;

            type string String min-size:0 max-size:0;

            entity Person{
                field String fullName;
            }

        '''.parse => [
            assertMaxSizeNegativeError("max-size must be greater than 0", JsldslPackage::eINSTANCE.modifierMaxSize)
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
        "REQ-ENT-002"
    ])
    def void testMaxSizeModifierTooLarge() {
        '''
            model test;

            type string String min-size:0 max-size:4001;

            entity Person{
                field String fullName;
            }

        '''.parse => [
            assertMaxSizeTooLargeError("max-size must be less than/equal to " + JslDslValidator.MODIFIER_MAX_SIZE_MAX_VALUE, JsldslPackage::eINSTANCE.modifierMaxSize)
        ]
    }

    def private void assertMaxSizeNegativeError(ModelDeclaration modelDeclaration, String error, EClass target) {
        modelDeclaration.assertError(
            target,
            JslDslValidator.MAX_SIZE_MODIFIER_IS_NEGATIVE,
            error
        )
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-005",
        "REQ-ENT-001",
        "REQ-ENT-002"
    ])
    def void testPrecisionModifierTooLow() {
        '''
            model test;

            type numeric Number1 precision:0 scale:0;

            entity Entity {
                field Number1 number;
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.modifierPrecision, JslDslValidator.PRECISION_MODIFIER_IS_NEGATIVE, "Precision must be greater than 0")
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
        "REQ-TYPE-005",
        "REQ-ENT-001",
        "REQ-ENT-002"
        //TODO: JNG-4396
    ])
    def void testPrecisionModifierTooLarge() {
        '''
            model test;

            type numeric Number1 precision:16 scale:0;

            entity Entity {
                field Number1 number;
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.modifierPrecision, JslDslValidator.PRECISION_MODIFIER_IS_TOO_LARGE)
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
        "REQ-TYPE-005",
        "REQ-ENT-001",
        "REQ-ENT-002"
        //TODO: JNG-4397
    ])
    def void testScaleModifierTooLarge() {
        '''
            model test;

            type numeric Number1 precision:15 scale:15;

            entity Entity {
                field Number1 number;
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.modifierScale, JslDslValidator.SCALE_MODIFIER_IS_TOO_LARGE, "Scale must be less than the defined precision: 15")
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
        "REQ-TYPE-006",
        "REQ-ENT-001",
        "REQ-ENT-007"
    ])
    def void testAbstarctField() {
        '''
            model test;

            entity abstract T1 {
            }
            
            entity Test {
                field T1 ent;
            }
        '''.parse => [
        	m | m.assertError(JsldslPackage::eINSTANCE.entityStoredFieldDeclaration, JslDslValidator.FIELD_TYPE_IS_ABSRTACT_ENTITY, "You cannot use entity named 'T1' as a field type, because it is abstract")
        ]
    }

    def private void assertMaxSizeTooLargeError(ModelDeclaration modelDeclaration, String error, EClass target) {
        modelDeclaration.assertError(
            target,
            JslDslValidator.MAX_SIZE_MODIFIER_IS_TOO_LARGE,
            error
        )
    }
}
