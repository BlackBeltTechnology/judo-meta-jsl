package hu.blackbelt.judo.meta.jsl.runtime

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.junit.jupiter.api.^extension.ExtendWith
import org.junit.jupiter.api.Test
import hu.blackbelt.judo.requirement.report.annotation.Requirement
import hu.blackbelt.judo.requirement.report.annotation.TestCase
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension
import static org.junit.Assert.assertTrue
import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertFalse

@ExtendWith(InjectionExtension)
@InjectWith(JslDslInjectorProvider)

class CommentTests {
    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper
    @Inject extension JslDslModelExtension

    /**
     * Testing the multiline comment in the beginning of the model file with model keyword.
     *
     * @prerequisites Nothing
     * @type Static
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is successful.
     *
     *  . The "xxx" model is not available. The "m1" is the only one model that is available.
     */
    @Test
    @TestCase("TC005")
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-SYNT-005",
        "REQ-MDL-001"
    ])
    def void testMultilineComments() {
        val p = '''/*
        model xxx;
        */
        model modelTC005;
        '''.parse
        p.assertNoErrors

        val m1 = p.fromModel

        assertFalse(m1.streamOfJsldslModelDeclaration.anyMatch[e | "xxx".equals(e.name) ])
        assertTrue(m1.streamOfJsldslModelDeclaration.allMatch[e |  "modelTC005".equals(e.name) ])

    }

    /**
     * Testing the singleline and multiline comments where the commented section contains valid JSL statements.
     *
     * @prerequisites Nothing
     * @type Static
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is successful.
     *
     *  . The "xxx" model is not available. The "m1" is the only one model that is available.
     */
    @Test
    @TestCase("TC006")
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-SYNT-005",
        "REQ-MDL-001"
    ])
    def void testMultilineCommentWhereCommentStartsAndEndsInTheSameLine() {
        val p = '''/* model xxx; */
        model modelTC006;
        '''.parse
        p.assertNoErrors

        val m1 = p.fromModel

        assertFalse(m1.streamOfJsldslModelDeclaration.anyMatch[e | "xxx".equals(e.name) ])
        assertTrue(m1.streamOfJsldslModelDeclaration.allMatch[e |  "modelTC006".equals(e.name) ])

    }

    /**
     * Testing the singleline comment in the beginning of the model file with model keyword.
     *
     * @prerequisites Nothing
     * @type Static
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is successful.
     *
     *  . The "blabla" model is not available. The "m1" is the only one model that is available.
     */
    @Test
    @TestCase("TC007")
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-SYNT-005",
        "REQ-MDL-001"
    ])
    def void testSingleLineCommentWithoutSpaceBeforeCommentedCode() {
        val p = '''//model blabla;
        model modelTC007;
        '''.parse
        p.assertNoErrors

        val m1 = p.fromModel

        assertFalse(m1.streamOfJsldslModelDeclaration.anyMatch[e | "blabla".equals(e.name) ])
        assertTrue(m1.streamOfJsldslModelDeclaration.allMatch[e |  "modelTC007".equals(e.name) ])

    }

    /**
     * Testing the singleline comment in the beginning of the model file with model keyword.
     *
     * @prerequisites Nothing
     * @type Static
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is successful.
     *
     *  . The "blabla" model is not available. The "m1" is the only one model that is available.
     */
    @Test
    @TestCase("TC008")
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-SYNT-005",
        "REQ-MDL-001"
    ])
    def void testSingleLineCommentWithSpaceBeforeCommentedCode() {
        val p = '''// model blabla;
        model modelTC008;
        '''.parse
        p.assertNoErrors

        val m1 = p.fromModel

        assertFalse(m1.streamOfJsldslModelDeclaration.anyMatch[e | "blabla".equals(e.name) ])
        assertTrue(m1.streamOfJsldslModelDeclaration.allMatch[e |  "modelTC008".equals(e.name) ])

    }

    /**
     * Testing the singleline and multiline comments where the commented section contains valid JSL statements.
     *
     * @prerequisites Nothing
     * @type Static
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is successful.
     *
     *  . The "m1" is the only one model that is available, and
     *
     *  . the model has only one entity ("e4") and one type ("Bool") definitions.
     *
     *  . Moreover, the "e4" entity type has only one field that name is "bb" and its type is "Bool".
     */
    @Test
    @TestCase("TC009")
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-SYNT-005",
        "REQ-TYPE-001",
        "REQ-TYPE-006",
        "REQ-MDL-001",
        "REQ-ENT-001",
        "REQ-ENT-002"
    ])
    def void testCommentsThatContainValidStatements() {
        val p = '''model modelTC009;
        /*entity e1 {
          field Bool bb;
        }*/
        type boolean Bool;

        /*
        entity e2 {
        field Bool bb;
        }
        */

        //entity e3 {
        //  field Bool bb;
        //}


        entity e4 {
            field Bool bb;
            // field Bool cc;
        }
        '''.parse
        p.assertNoErrors

        val m1 = p.fromModel

        assertTrue(m1.streamOfJsldslModelDeclaration.allMatch[e |  "modelTC009".equals(e.name) ])
        assertTrue(m1.streamOfJsldslEntityDeclaration.allMatch[e | "e4".equals(e.name) ])
        assertTrue(m1.streamOfJsldslDataTypeDeclaration.allMatch[e | "boolean".equals(e.primitive) && "Bool".equals(e.name)])

        val e4 = m1.entityByName("e4")
        assertTrue(e4.allFields.stream.allMatch[e | "bb".equals(e.name) && "Bool".equals(e.referenceType.name)])

    }
}
