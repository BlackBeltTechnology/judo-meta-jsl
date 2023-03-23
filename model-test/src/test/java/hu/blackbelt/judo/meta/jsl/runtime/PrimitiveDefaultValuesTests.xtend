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
class PrimitiveDefaultValuesTests {
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
        "REQ-TYPE-006",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-EXPR-001"
    ])
    def void testBoolDefaultTypeMismatch() {
        '''
            model PrimitiveDefaultsModel;

            type boolean Bool;

            entity Test {
                field Bool boolAttr = "hello";
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.entityFieldDeclaration, JslDslValidator.TYPE_MISMATCH, "Type mismatch. Default value expression does not match field type.")
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
        "REQ-EXPR-001"
    ])
    def void testStringLiteralDefaultTypeMismatch() {
        '''
            model PrimitiveDefaultsModel;

            type string String(min-size = 0, max-size = 128);

            entity Test {
                field String stringAttr = 123;
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.entityFieldDeclaration, JslDslValidator.TYPE_MISMATCH, "Type mismatch. Default value expression does not match field type.")
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
        "REQ-ENT-002",
        "REQ-EXPR-001"
    ])
    def void testIntegerDefaultTypeMismatch() {
        '''
            model PrimitiveDefaultsModel;

            type numeric Integer(precision = 9,  scale = 0);

            entity Test {
                field Integer intAttr = "hello";
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.entityFieldDeclaration, JslDslValidator.TYPE_MISMATCH, "Type mismatch. Default value expression does not match field type.")
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
        "REQ-ENT-002",
        "REQ-EXPR-001"
    ])
    def void testDecimalDefaultTypeMismatch() {
        '''
            model PrimitiveDefaultsModel;

            type numeric Decimal(precision = 9, scale = 3);

            entity Test {
                field Decimal decimalAttr = "hello";
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.entityFieldDeclaration, JslDslValidator.TYPE_MISMATCH, "Type mismatch. Default value expression does not match field type.")
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
        "REQ-TYPE-007",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-EXPR-001"
    ])
    def void testDateDefaultTypeMismatch() {
        '''
            model PrimitiveDefaultsModel;

            type date Date;

            entity Test {
                field Date dateAttr = "hello";
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.entityFieldDeclaration, JslDslValidator.TYPE_MISMATCH, "Type mismatch. Default value expression does not match field type.")
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
        "REQ-TYPE-008",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-EXPR-001"
    ])
    def void testTimeDefaultTypeMismatch() {
        '''
            model PrimitiveDefaultsModel;

            type time Time;

            entity Test {
                field Time timeAttr = "hello";
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.entityFieldDeclaration, JslDslValidator.TYPE_MISMATCH, "Type mismatch. Default value expression does not match field type.")
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
        "REQ-TYPE-009",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-EXPR-001"
    ])
    def void testTimestampDefaultTypeMismatch() {
        '''
            model PrimitiveDefaultsModel;

            type timestamp Timestamp;

            entity Test {
                field Timestamp timestampAttr = "hello";
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.entityFieldDeclaration, JslDslValidator.TYPE_MISMATCH, "Type mismatch. Default value expression does not match field type.")
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
        "REQ-TYPE-005",
        "REQ-TYPE-006",
        "REQ-TYPE-007",
        "REQ-TYPE-008",
        "REQ-TYPE-009",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-003",
        "REQ-EXPR-001",
        "REQ-EXPR-002",
        "REQ-EXPR-007",
        "REQ-EXPR-014",
        "REQ-EXPR-015",
        "REQ-EXPR-016",
        "REQ-EXPR-017",
        "REQ-EXPR-018"

    ])
    def void testPrimitivesPassingForFieldsAndIdentifiers() {
        '''
            model PrimitiveDefaultsModel;

            type numeric Integer(precision = 9,  scale = 0);
            type numeric Decimal(precision = 5,  scale = 3);
            type string String(min-size = 0, max-size = 128);
            type boolean Bool;
            type date Date;
            type time Time;
            type timestamp Timestamp;
            type string PhoneNumber(min-size = 0, max-size = 32, regex = "^(\\+\\d{1,2}\\s)?\\(?\\d{3}\\)?[\\s.-]\\d{3}[\\s.-]\\d{4}$");   // escape sequencing does not work in regexp!!!!

            entity TestIdentifiers {
                identifier Bool a = true;
                identifier Integer b = 3223;
                identifier Decimal b2 = 3223.123;
                identifier String c = "123";
                identifier String c2 = r"123";
                identifier Date d = `2020-01-12`;
                identifier Time e = `22:45:22`;
                identifier Timestamp f = `2020-01-12T12:12:12.000Z`;
            }

            entity TestFields {
                field Bool a = true;
                field Integer b = 3223;
                field Decimal b2 = 3223.123;
                field String c = "123";
                field String c2 = r"123";
                field Date d = `2020-01-12`;
                field Time timeHM = `11:11`;
                field Time timeHM1 = Time!of(hour = 11, minute = 11);
                field Time timeHMS = `11:11:11`;
                field Time timeHMS1 = Time!of(hour = 11, minute = 11, second = 11);
                field Time timeHMSF = `11:11:11.111`;
                field Time timeHMSF1 = Time!of(hour = 11, minute = 11, second = 11, millisecond = 111);
                field Time timeFromMillisecond = Time!fromMilliseconds(milliseconds = 999999);
                field Integer timeAsMillisecond = `11:11:11.111`!asMilliseconds();
                field Timestamp timestamp = `2023-03-21T11:11`;
                field Timestamp timestamp1 = `2023-03-21T11:11Z`;
                field Timestamp timestamp2 = `2023-03-21T11:11+05`;
                field Timestamp timestamp3 = `2023-03-21T11:11-05`;
                field Timestamp timestamp4 = `2023-03-21T11:11+05:05`;
                field Timestamp timestamp5 = `2023-03-21T11:11-05:05`;
                field Timestamp timestamp6 = `2023-03-21T11:11:11`;
                field Timestamp timestamp7 = `2023-03-21T11:11:11Z`;
                field Timestamp timestamp8 = `2023-03-21T11:11:11+05`;
                field Timestamp timestamp9 = `2023-03-21T11:11:11-05`;
                field Timestamp timestamp10 = `2023-03-21T11:11:11+05:05`;
                field Timestamp timestamp11 = `2023-03-21T11:11:11-05:05`;
                field Timestamp timestamp12 = `2023-03-21T11:11:11.111`;
                field Timestamp timestamp13 = `2023-03-21T11:11:11.111Z`;
                field Timestamp timestamp14 = `2023-03-21T11:11:11.111+05`;
                field Timestamp timestamp15 = `2023-03-21T11:11:11.111-05`;
                field Timestamp timestamp16 = `2023-03-21T11:11:11.111+05:05`;
                field Timestamp timestamp17 = `2023-03-21T11:11:11.111-05:05`;
                field Timestamp timestamp18 = Timestamp!of(date = `2023-03-21`, time = `11:11`);
                field Timestamp timestamp19 = Timestamp!of(date = `2023-03-21`, time = `11:11:11`);
                field Timestamp timestamp20 = Timestamp!of(date = `2023-03-21`, time = `11:11:11.111`);
            }

            error ErrorFields {
                field Bool a = true;
                field Integer b = 3223;
                field Decimal b2 = 3223.123;
                field String c = "123";
                field String c2 = r"123";
                field Date d = `2020-01-12`;
                field Time e = `22:45:22`;
                field Timestamp f = `2020-01-12T12:12:12.000Z`;
            }

            entity EntityWithPrimitiveDefaultExpressions {
                field Integer integerAttr = 1.23!round();
                field Decimal scaledAttr = 2.9!abs();
                field String stringAttr = true!asString();
                field PhoneNumber regexAttr = "+36-1-123-123";
                field Bool boolAttr = 2 > -1;
                field Date dateAttr = Date!now();
                field Timestamp timestampAttr = Timestamp!now();
                field Time timeAttr = Time!of(hour = 23, minute = 59, second = 59);
            }

        '''.parse => [
            assertNoErrors
        ]
    }
}
