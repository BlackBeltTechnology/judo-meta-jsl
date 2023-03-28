package hu.blackbelt.judo.meta.jsl.runtime

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.^extension.ExtendWith
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Disabled
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import hu.blackbelt.judo.meta.jsl.validation.JslDslValidator
import hu.blackbelt.judo.requirement.report.annotation.Requirement
import hu.blackbelt.judo.requirement.report.annotation.TestCase

@ExtendWith(InjectionExtension)
@InjectWith(JslDslInjectorProvider)
class NamedTests {
    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper


    @Test
    @Disabled("JNG-4678")
    @TestCase("TC021")
    @Requirement(reqs = #[
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
            "REQ-MDL-001"
    ])
    def void testNamingOfModel() {
        '''
        model mModelTC021;

        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.named, JslDslValidator.JAVA_BEAN_NAMING_ISSUE)
        ]
    }

    @Test
    @TestCase("TC021")
    @Requirement(reqs = #[
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
            "REQ-MDL-001",
            "REQ-MDL-003",
            "REQ-TYPE-001",
            "REQ-TYPE-004"
    ])
    def void testNamingOfType() {
        '''
         model modelTC021;

         import judo::types;

         type string sType(min-size = 0, max-size = 10);

        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.named, JslDslValidator.JAVA_BEAN_NAMING_ISSUE)
        ]
    }

    @Test
    @TestCase("TC021")
    @Requirement(reqs = #[
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
            "REQ-MDL-001",
            "REQ-TYPE-002"
    ])
    def void testNamingOfEnumType() {
        '''
         model modelTC021;

         enum xEnum {
             a0 = 0;
             b1 = 1;
         }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.named, JslDslValidator.JAVA_BEAN_NAMING_ISSUE)
        ]
    }

    @Test
    @TestCase("TC021")
    @Requirement(reqs = #[
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
            "REQ-MDL-001",
            "REQ-TYPE-002"
    ])
    def void testNamingOfEnumFiel() {
        '''
         model modelTC021;

         enum Enum {
             xA0 = 0;
             xB1 = 1;
         }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.named, JslDslValidator.JAVA_BEAN_NAMING_ISSUE)
        ]
    }

    @Test
    @TestCase("TC021")
    @Requirement(reqs = #[
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
            "REQ-MDL-001",
            "REQ-ENT-001"
    ])
    def void testNamingOfEntityType() {
        '''
         model modelTC021;

         entity xEnt1 {
         }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.named, JslDslValidator.JAVA_BEAN_NAMING_ISSUE)
        ]
    }

    @Test
    @TestCase("TC021")
    @Requirement(reqs = #[
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
            "REQ-MDL-001",
            "REQ-ENT-001",
            "REQ-ENT-012"
    ])
    def void testNamingOfEntityTypeWithExtendAndAbstract() {
        '''
         model modelTC021;

         entity Ent {
         }

         entity abstract xEnt1 extends Ent {
         }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.named, JslDslValidator.JAVA_BEAN_NAMING_ISSUE)
        ]
    }

    @Test
    @TestCase("TC021")
    @Requirement(reqs = #[
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
            "REQ-MDL-001",
            "REQ-MDL-003",
            "REQ-TYPE-001",
            "REQ-TYPE-002",
            "REQ-TYPE-003",
            "REQ-TYPE-004",
            "REQ-TYPE-005",
            "REQ-TYPE-006",
            "REQ-TYPE-007",
            "REQ-TYPE-008",
            "REQ-TYPE-009",
            "REQ-ENT-001",
            "REQ-ENT-002"
    ])
    def void testNamingOfEntityField() {
        '''
         model modelTC021;

         import judo::types;

         type string SType(min-size = 0, max-size = 10);
         type numeric Integer(precision = 9, scale = 0);

         enum Enum {
             a0 = 0;
             b1 = 1;
         }

         entity Ent1 {
             field Boolean xBool;
             field SType xString;
             field Integer xNumeric;
             field Enum xEnum;
             field Date xDate;
             field Timestamp xTimestamp;
             field Time xTime;
         }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.named, JslDslValidator.JAVA_BEAN_NAMING_ISSUE)
        ]
    }

    @Test
    @TestCase("TC021")
    @Requirement(reqs = #[
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
            "REQ-MDL-001",
            "REQ-MDL-003",
            "REQ-TYPE-001",
            "REQ-TYPE-002",
            "REQ-TYPE-003",
            "REQ-TYPE-004",
            "REQ-TYPE-005",
            "REQ-TYPE-006",
            "REQ-TYPE-007",
            "REQ-TYPE-008",
            "REQ-TYPE-009",
            "REQ-ENT-001",
            "REQ-ENT-003"
    ])
    def void testNamingOfEntityIdentifier() {
        '''
         model modelTC021;

         import judo::types;

         type string SType(min-size = 0, max-size = 10);
         type numeric Integer(precision = 9, scale = 0);

         enum Enum {
             a0 = 0;
             b1 = 1;
         }
         entity Ent1 {
             identifier Boolean xBool;
             identifier SType xString;
             identifier Integer xNumeric;
             identifier Enum xEnum;
             identifier Date xDate;
             identifier Timestamp xTimestamp;
             identifier Time xTime;
         }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.named, JslDslValidator.JAVA_BEAN_NAMING_ISSUE)
        ]
    }

    @Test
    @TestCase("TC021")
    @Requirement(reqs = #[
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
            "REQ-MDL-001",
            "REQ-MDL-003",
            "REQ-ENT-001",
            "REQ-ENT-003",
            "REQ-ENT-004",
            "REQ-ENT-005",
            "REQ-ENT-006"
    ])
    def void testNamingOfEntityRelation() {
        '''
         model modelTC021;

         entity Ent1 {
            relation Ent3 xEnt3;
            relation Ent2 xEnt2 opposite xEnt1;
            relation Ent4 xEnt4 opposite-add Ent4;

         }
         entity Ent2 {
            relation Ent1 xEnt1 opposite xEnt2;
         }
         entity Ent3 {
         }
         entity Ent4 {
         }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.named, JslDslValidator.JAVA_BEAN_NAMING_ISSUE)
        ]
    }

    @Test
    @TestCase("TC021")
    @Requirement(reqs = #[
            "REQ-SYNT-001",
            "REQ-SYNT-002",
            "REQ-SYNT-003",
            "REQ-SYNT-004",
            "REQ-MDL-001",
            "REQ-MDL-003",
            "REQ-TYPE-001",
            "REQ-TYPE-002",
            "REQ-TYPE-003",
            "REQ-TYPE-004",
            "REQ-TYPE-005",
            "REQ-TYPE-006",
            "REQ-TYPE-007",
            "REQ-TYPE-008",
            "REQ-TYPE-009",
            "REQ-ENT-001",
            "REQ-ENT-008"
    ])
    def void testNamingOfDerived() {
        '''
         model modelTC021;

         import judo::types;

         type string SType(min-size = 0, max-size = 10);
         type numeric Integer(precision = 9, scale = 0);

         enum Enum {
              a0 = 0;
              b1 = 1;
         }

         entity Ent1 {
             derived Boolean xBool => true;
             derived SType xString => "Sting";
             derived Integer xNumeric => 1;
             derived Enum xEnum => Enum#a0;
             derived Date xDate => `2023-11-09`;
             derived Timestamp xTimestamp => `2020-02-18T10:11:12`;
             derived Time xTime => `12:23:56.1`;
         }
         '''.parse => [
             m | m.assertError(JsldslPackage::eINSTANCE.named, JslDslValidator.JAVA_BEAN_NAMING_ISSUE)
         ]
    }

        @Test
        @TestCase("TC021")
        @Requirement(reqs = #[
                "REQ-SYNT-001",
                "REQ-SYNT-002",
                "REQ-SYNT-003",
                "REQ-SYNT-004",
                "REQ-MDL-001",
                "REQ-MDL-003",
                "REQ-TYPE-001",
                "REQ-TYPE-002",
                "REQ-TYPE-004",
                "REQ-TYPE-005",
                "REQ-TYPE-006",
                "REQ-TYPE-007",
                "REQ-TYPE-008",
                "REQ-TYPE-009",
                "REQ-ENT-001",
                "REQ-ENT-009",
                "REQ-ENT-011"
        ])
        def void testNamingOfQuery() {
            '''
             model modelTC021;

             import judo::types;

             type string SType(min-size = 0, max-size = 10);
             type numeric Integer(precision = 9, scale = 0);

             enum Enum {
                  a0 = 0;
                  b1 = 1;
             }

             entity Ent1 {
                 query Boolean xBool() => true;
                 query SType xString() => "Sting";
                 query Integer xNumeric() => 1;
                 query Enum xEnum() => Enum#a0;
                 query Date xDate() => `2023-11-09`;
                 query Timestamp xTimestamp() => `2020-02-18T10:11:12`;
                 query Time xTime() => `12:23:56.1`;
             }

             query Ent1[] xAllEnt1() => Ent1!all();
             '''.parse => [
                 m | m.assertError(JsldslPackage::eINSTANCE.named, JslDslValidator.JAVA_BEAN_NAMING_ISSUE)
             ]
        }

 }
