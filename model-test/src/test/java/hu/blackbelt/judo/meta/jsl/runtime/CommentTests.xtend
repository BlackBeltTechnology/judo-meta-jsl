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

@ExtendWith(InjectionExtension)
@InjectWith(JslDslInjectorProvider)

class CommentTests {
    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper
    @Inject extension JslDslModelExtension
    
    /**
     * Testing the singleline and multiline comments where the commented section contains valid JSL statements.
     * 
     * @prerequisites Nothing
     * @type Static
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is successful.
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