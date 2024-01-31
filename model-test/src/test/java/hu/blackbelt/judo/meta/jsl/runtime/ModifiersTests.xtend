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
            assertMinSizeTooLargeError("min-size must be less than/equal to max-size", JsldslPackage::eINSTANCE.minSizeModifier)
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
            assertMaxSizeNegativeError("max-size must be greater than 0", JsldslPackage::eINSTANCE.maxSizeModifier)
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
            assertMaxSizeTooLargeError("max-size must be less than/equal to " + JslDslValidator.MODIFIER_MAX_SIZE_MAX_VALUE, JsldslPackage::eINSTANCE.maxSizeModifier)
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
            m | m.assertError(JsldslPackage::eINSTANCE.precisionModifier, JslDslValidator.PRECISION_MODIFIER_IS_NEGATIVE, "Precision must be greater than 0")
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
            m | m.assertError(JsldslPackage::eINSTANCE.precisionModifier, JslDslValidator.PRECISION_MODIFIER_IS_TOO_LARGE)
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
            m | m.assertError(JsldslPackage::eINSTANCE.scaleModifier, JslDslValidator.SCALE_MODIFIER_IS_TOO_LARGE, "Scale must be less than the defined precision: 15")
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

            entity T1 abstract {
            }
            
            entity Test {
                field T1 ent;
            }
        '''.parse => [
        	m | m.assertError(JsldslPackage::eINSTANCE.entityFieldDeclaration, JslDslValidator.FIELD_TYPE_IS_ABSRTACT_ENTITY, "You cannot use entity named 'T1' as a field type, because it is abstract")
        ]
    }

    @Test
    def void testChoiceFieldWithContainment() {
        '''
			model test;

			entity A {
				field B b;
				relation B b1;
			}
			
			entity B {}
			
			transfer TA maps A as a {
				relation TB tbs <= a.b choices:B.all();
			}
			
			transfer TB(B b) {}
        '''.parse => [
        	m | m.assertError(JsldslPackage::eINSTANCE.choiceModifier, JslDslValidator.INVALID_CHOICES)
        ]
    }

    @Test
    def void testTransferActionChoice() {
        '''
			model test;

			entity A {
			}
			
			entity B {}

			transfer TB(B b) {
			}
			
			transfer TA maps A as a {
				action void myaction(TB input choices:B.all());
			}
        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    def void testTransferActionChoiceWithUnmappedInput() {
        '''
			model test;

			entity A {
			}
			
			entity B {}

			transfer TB {
			}
			
			transfer TA maps A as a {
				action void myaction(TB input choices:B.all());
			}
        '''.parse => [
        	m | m.assertError(JsldslPackage::eINSTANCE.choiceModifier, JslDslValidator.INVALID_CHOICES)
        ]
    }

    @Test
    def void testTransferActionChoiceMissing() {
        '''
			model test;

			entity A {
			}
			
			entity B {}

			transfer TB(B b) {
			}
			
			transfer TA maps A as a {
				action void myaction(TB input);
			}
        '''.parse => [
        	m | m.assertError(JsldslPackage::eINSTANCE.transferActionDeclaration, JslDslValidator.INVALID_DECLARATION)
        ]
    }

    @Test
    def void testTransferActionUpdateDelete() {
        '''
			model test;

			entity A {
			}
			
			entity B {}

			transfer TB(B b) {
				event update `update`();
				event delete `delete`();
			}
			
			transfer TA maps A as a {
				action TB myaction() update:true delete:true;
			}
        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    def void testTransferActionUpdateEventMissing() {
        '''
			model test;

			entity A {
			}
			
			entity B {}

			transfer TB(B b) {
			}
			
			transfer TA maps A as a {
				action TB myaction() update:true;
			}
        '''.parse => [
        	m | m.assertError(JsldslPackage::eINSTANCE.updateModifier, JslDslValidator.INVALID_DECLARATION)
        ]
    }

    @Test
    def void testTransferActionDeleteEventMissing() {
        '''
			model test;

			entity A {
			}
			
			entity B {}

			transfer TB(B b) {
			}
			
			transfer TA maps A as a {
				action TB myaction() delete:true;
			}
        '''.parse => [
        	m | m.assertError(JsldslPackage::eINSTANCE.deleteModifier, JslDslValidator.INVALID_DECLARATION)
        ]
    }

    @Test
    def void testViewChoiceRow() {
        '''
			model test;

			entity A {
			}
			
			entity B {}

			row RB(B b) {
			}

			view VB(B b) {
			}
			
			view VA maps A as a {
				action void myaction(RB input choices:B.all());
			}
        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    def void testViewChoiceRowMissing() {
        '''
			model test;

			entity A {
			}
			
			entity B {}

			row RB(B b) {
			}

			view VB(B b) {
			}
			
			view VA maps A as a {
				action void myaction(VB input);
			}
        '''.parse => [
        	m | m.assertError(JsldslPackage::eINSTANCE.viewActionDeclaration, JslDslValidator.INVALID_DECLARATION)
        ]
    }

    @Test
    def void testViewChoiceRowUnmapped() {
        '''
			model test;

			entity A {
			}
			
			entity B {}

			row RB {
			}

			view VB(B b) {
			}
			
			view VA maps A as a {
				action void myaction(VB input choices:RB[](B.all()));
			}
        '''.parse => [
        	m | m.assertError(JsldslPackage::eINSTANCE.choiceModifier, JslDslValidator.INVALID_CHOICES)
        ]
    }

    @Test
    def void testViewChoiceRowUnmatching() {
        '''
			model test;

			entity A {
			}
			
			entity B {}

			row RB(A a) {
			}

			view VB(B b) {
			}
			
			view VA maps A as a {
				action void myaction(VB input choices:A.all());
			}
        '''.parse => [
        	m | m.assertError(JsldslPackage::eINSTANCE.choiceModifier, JslDslValidator.INVALID_CHOICES)
        ]
    }

    @Test
    def void testTransferRelationCRUD() {
        '''
			model test;

			entity A {
			}
			
			entity B {
				relation A[] alist;
			}

			transfer TA maps A as a {
				event create `create`();
				event delete `delete`();
				event update `update`();
			}

			transfer TB(B b) {
				relation TA[] talist <= b.alist create:true delete:true update:true;
			}
        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    def void testTransferRelationCRUDCreateEventMissing() {
        '''
			model test;

			entity A {
			}
			
			entity B {
				relation A[] alist;
			}

			transfer TA maps A as a {
				event delete edelete();
				event update eupdate();
			}

			transfer TB(B b) {
				relation TA[] talist <= b.alist create:true delete:true update:true;
			}
        '''.parse => [
        	m | m.assertError(JsldslPackage::eINSTANCE.createModifier, JslDslValidator.INVALID_DECLARATION)
        ]
    }

    @Test
    def void testTransferRelationCRUDDeleteEventMissing() {
        '''
			model test;

			entity A {
			}
			
			entity B {
				relation A[] alist;
			}

			transfer TA maps A as a {
				event instead ecreate();
				event instead eupdate();
			}

			transfer TB(B b) {
				relation TA[] talist <= b.alist create:true delete:true update:true;
			}
        '''.parse => [
        	m | m.assertError(JsldslPackage::eINSTANCE.deleteModifier, JslDslValidator.INVALID_DECLARATION)
        ]
    }

    @Test
    def void testTransferRelationCRUDUpdateEventMissing() {
        '''
			model test;

			entity A {
			}
			
			entity B {
				relation A[] alist;
			}

			transfer TA maps A as a {
				event instead ecreate();
				event instead edelete();
			}

			transfer TB(B b) {
				relation TA[] talist <= b.alist create:true delete:true update:true;
			}
        '''.parse => [
        	m | m.assertError(JsldslPackage::eINSTANCE.updateModifier, JslDslValidator.INVALID_DECLARATION)
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
