package hu.blackbelt.judo.meta.jsl.runtime

import org.junit.jupiter.api.^extension.ExtendWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.InjectWith
import com.google.inject.Inject
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.junit.jupiter.api.Test
import hu.blackbelt.judo.requirement.report.annotation.TestCase
import hu.blackbelt.judo.requirement.report.annotation.Requirement

@ExtendWith(InjectionExtension)
@InjectWith(JslDslInjectorProvider)
class InstanceQueryTests {
    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper
    
    /**
     * Testing the instance queries with constant default values.
     * 
     * @prerequisites Nothing
     * @type Static
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is successful.
     */
    @Test
    @TestCase("TC024")
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-SYNT-005",
        "REQ-TYPE-001",
        "REQ-TYPE-002",
        "REQ-TYPE-004",
        "REQ-TYPE-005",
        "REQ-TYPE-006",
        "REQ-TYPE-007",
        "REQ-TYPE-008",
        "REQ-TYPE-009",
        "REQ-MDL-001",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-004",
        "REQ-ENT-005",
        "REQ-ENT-009",
        "REQ-ENT-010",
        "REQ-EXPR-001",
        "REQ-EXPR-002",
        "REQ-EXPR-004",
        "REQ-EXPR-006",
        "REQ-EXPR-007",
        "REQ-EXPR-008",
        "REQ-EXPR-022"
    ])
    def void testStaticQueriesWithConstantDefaultValues() {
        //TODO
    }
}