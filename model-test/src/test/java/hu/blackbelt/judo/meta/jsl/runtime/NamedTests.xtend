package hu.blackbelt.judo.meta.jsl.runtime

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.^extension.ExtendWith
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.junit.jupiter.api.Test
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import hu.blackbelt.judo.meta.jsl.validation.JslDslValidator
import hu.blackbelt.judo.requirement.report.annotation.Requirement

@ExtendWith(InjectionExtension)
@InjectWith(JslDslInjectorProvider)
class NamedTests {
    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper

/**
     * Testing the naming rules. In this case check that case when the element name starts
     * a lower case character and follows it an upper case character.
     *
     * @prerequisites "Nothing"
     *
     * @type Behaviour
     *
     * @jslModel
     *  model mModelTC021;
     *
     *  import judo::types;
     *
     *  type string sType(min-size = 0, max-size = 10);
     *
     *  enum xEnum {
     *      xA0 = 0;
     *      xB1 = 1;
     *  }
     *
     *  entity aEnt1 {
     *      field Boolean fBool = true;
     *      field sType   sS99  = "abc";
     *      field xEnum   zEnum = xEnum#xB1;
     *  }
     *
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is successful.
     *
     *  . Create an aEnt1 entity instance (ae1) with the default values.
     *
     *  . Check the values of the following fields of the new entity instance (ae1).
     *      * fBool == true
     *      * sS99 == "abc"
     *      * zEnum == xEnum#xB1
     *
     *  . The test is passed if all modifications and checks are successful, and there were no exceptions.
     */
    @Test
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
            "REQ-TYPE-006",
            "REQ-ENT-001",
            "REQ-ENT-002",
            "REQ-EXPR-001"
    ])
    def void testNamingOfTypeName() {
        '''
         model mModelTC021;

         import judo::types;

         type string sType(min-size = 0, max-size = 10);

         enum Enum {
             a0 = 0;
             b1 = 1;
         }

         entity Ent1 {
             field Boolean bool = true;
             field Stype   s99  = "abc";
             field Enum   enum = Enum#b1;
         }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.named, JslDslValidator.JAVA_BEAN_NAMING_ISSUE)
        ]
    }

    @Test
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
            "REQ-TYPE-006",
            "REQ-ENT-001",
            "REQ-ENT-002",
            "REQ-EXPR-001"
    ])
    def void testNamingOfEnumTypeName() {
        '''
         model mModelTC021;

         import judo::types;

         type string SType(min-size = 0, max-size = 10);

         enum xEnum {
             a0 = 0;
             b1 = 1;
         }

         entity Ent1 {
             field Boolean bool = true;
             field Stype   s99  = "abc";
             field Enum   enum = xEnum#b1;
         }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.named, JslDslValidator.JAVA_BEAN_NAMING_ISSUE)
        ]
    }

    @Test
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
            "REQ-TYPE-006",
            "REQ-ENT-001",
            "REQ-ENT-002",
            "REQ-EXPR-001"
    ])
    def void testNamingOfEnumFieldName() {
        '''
         model mModelTC021;

         import judo::types;

         type string SType(min-size = 0, max-size = 10);

         enum Enum {
             a0 = 0;
             xB1 = 1;
         }

         entity Ent1 {
             field Boolean bool = true;
             field Stype   s99  = "abc";
             field Enum   enum = Enum#B1;
         }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.named, JslDslValidator.JAVA_BEAN_NAMING_ISSUE)
        ]
    }

    @Test
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
            "REQ-TYPE-006",
            "REQ-ENT-001",
            "REQ-ENT-002",
            "REQ-EXPR-001"
    ])
    def void testNamingOfEntityTypeName() {
        '''
         model mModelTC021;

         import judo::types;

         type string SType(min-size = 0, max-size = 10);

         enum Enum {
             a0 = 0;
             b1 = 1;
         }

         entity xEnt1 {
             field Boolean bool = true;
             field Stype   s99  = "abc";
             field Enum   enum = Enum#b1;
         }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.named, JslDslValidator.JAVA_BEAN_NAMING_ISSUE)
        ]
    }

    @Test
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
            "REQ-TYPE-006",
            "REQ-ENT-001",
            "REQ-ENT-002",
            "REQ-EXPR-001"
    ])
    def void testNamingOfEntityFieldName() {
        '''
         model mModelTC021;

         import judo::types;

         type string SType(min-size = 0, max-size = 10);

         enum Enum {
             a0 = 0;
             b1 = 1;
         }

         entity Ent1 {
             field Boolean xBool = true;
             field Stype   s99  = "abc";
             field Enum   enum = Enum#b1;
         }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.named, JslDslValidator.JAVA_BEAN_NAMING_ISSUE)
        ]
    }
 }
