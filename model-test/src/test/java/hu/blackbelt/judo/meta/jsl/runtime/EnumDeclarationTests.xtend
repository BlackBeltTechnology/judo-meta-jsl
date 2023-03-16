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
import hu.blackbelt.judo.requirement.report.annotation.TestCase
import org.junit.jupiter.api.Disabled

@ExtendWith(InjectionExtension)
@InjectWith(JslDslInjectorProvider)
class EnumDeclarationTests {
    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper

    /**
     * Testing the naming of enum literals.
     *
     * @prerequisites Nothing
     * @type Static
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is successful.
     */
    @Test
    @TestCase("TC001")
    @Requirement(reqs = #[
         "REQ-SYNT-001",
         "REQ-SYNT-002",
         "REQ-SYNT-003",
         "REQ-SYNT-004",
         "REQ-MDL-001",
         "REQ-TYPE-002",
         "REQ-ENT-001",
         "REQ-ENT-002"
    ])
    def void testNamingOfEnumLiterals() {
        '''
            model modelTC001;

            enum TestLiteral {
                AAA   = 1;
                bbb   = 2;
                Abc09 = 3;
            }

            entity E1 {
                field TestLiteral f1;
            }
        '''.parse => [
            assertNoErrors
        ]
    }

    /**
     * Testing the naming of enum literals. Bad literal name.
     *
     * @prerequisites Nothing
     * @type Static
     * @negativeRequirements REQ-SYNT-004
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is ended with an exception because the
     *    _"11aaa"_ isn't a valid enum literal name.
     */
    @Test
    @TestCase("TC002")
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-002",
        "REQ-ENT-001",
        "REQ-ENT-002"
    ])
    def void testNamingOfEnumLiteralsBadLiteralName() {
        '''
            model modelTC002;

            enum TestLiteral {
                AAA   = 1;
                bbb   = 2;
                11aaa = 3;
            }

            entity E1 {
                field TestLiteral f1;
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.enumDeclaration, org.eclipse.xtext.diagnostics.Diagnostic.SYNTAX_DIAGNOSTIC, "mismatched input '11' expecting '}'")
        ]
    }

    /**
     * Testing the type of the enumeration's ordinal.
     *
     * @prerequisites Nothing
     * @type Static
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is successful.
     */
    @Test
    @Disabled("JNG-4597")
    @TestCase("TC003")
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-002",
        "REQ-ENT-001",
        "REQ-ENT-002"
    ])
    def void testEnumOrdinals() {
        '''
            model modelTC003;

            enum TestLiteral {
                Aaa01 = 1;
                Bbb02 = 2;
                Ccc03 = 99988899;
                AA00  = 0;
                ZZZ   = -3;
            }

            entity E1 {
                field TestLiteral f1 = TestLiteral#AA00;
            }
        '''.parse => [
            assertNoErrors
        ]
    }

    /**
     * Testing the operators of enum and enum functions.
     *
     * @prerequisites Nothing
     * @type Static
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is successful.
     */
    @Test
    @TestCase("TC020")
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-002",
        "REQ-TYPE-004",
        "REQ-TYPE-006",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-008",
        "REQ-EXPR-020"
    ])
    def void testEnumOrdinalsAndOperatorsAndFunctions() {
        '''
            model modelTC020;

            type boolean Bool;
            type string String(min-size=0, max-size=10);

            enum TestLiteral {
                Aaa01 = 1;
                Bbb02 = 2;
                Ccc03 = 99988899;
                AA00  = 0;
            }

            entity E1 {
                field TestLiteral f1 = TestLiteral#AA00;
                field TestLiteral f2 = TestLiteral#Aaa01;
                derived Bool   f3 => self.f1 < self.f2;
                derived Bool   f4 => self.f1 <= self.f2;
                derived Bool   f5 => self.f1 > self.f2;
                derived Bool   f6 => self.f1 >= self.f2;
                derived Bool   f7 => self.f1 == self.f2;
                derived Bool   f8 => self.f1 != self.f2;
                derived String f9 => self.f1!asString();
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
        "REQ-ENT-002",
        "REQ-TYPE-002"
    ])
    def void testEnumMemberMissing() {
        '''
            model test;

            enum Genre {
            }

            entity Person {
                field Genre favoredGenre;
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.enumDeclaration, JslDslValidator.ENUM_MEMBER_MISSING)
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
        "REQ-TYPE-002"
    ])
    def void testEnumLiteralCaseInsensitiveNameCollision() {
        '''
            model test;

            enum Genre {
                CLASSIC = 0;
                POP = 1;
                pop = 2;
            }

            entity Person {
                field Genre favoredGenre;
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.enumLiteral, JslDslValidator.ENUM_LITERAL_NAME_COLLISION, "Enumeration Literal name collision for: 'test.Genre.POP', 'test.Genre.pop'")
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
        "REQ-TYPE-002"
    ])
    def void testEnumLiteralOrdinalCollision() {
        '''
            model test;

            enum Genre {
                CLASSIC = 0;
                POP = 1;
                METAL = 1;
            }

            entity Person {
                field Genre favoredGenre;
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.enumLiteral, JslDslValidator.ENUM_LITERAL_ORDINAL_COLLISION, "Enumeration Literal ordinal collision for: 'test.Genre.POP': '1', 'test.Genre.METAL': '1'")
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
        "REQ-TYPE-002"
    ])
    def void testEnumDefaultTypeMismatch() {
        '''
            model test;

            enum Genre {
                CLASSIC = 0;
                POP = 1;
                METAL = 2;
            }

            enum GenreOther {
                HOUSE = 0;
            }

            entity Person {
                field Genre favoredGenre = GenreOther#HOUSE;
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.entityFieldDeclaration, JslDslValidator.TYPE_MISMATCH, "Default value does not match field type")
        ]
    }
}
