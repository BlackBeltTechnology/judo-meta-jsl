package hu.blackbelt.judo.meta.jsl.runtime

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.^extension.ExtendWith
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.junit.jupiter.api.Test
import com.google.inject.Provider
import org.eclipse.emf.ecore.resource.ResourceSet
import hu.blackbelt.judo.requirement.report.annotation.Requirement

@ExtendWith(InjectionExtension)
@InjectWith(JslDslInjectorProvider)
class IdEscapingTests {

    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper
    @Inject Provider<ResourceSet> resourceSetProvider;

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-008",
        "REQ-TYPE-001",
        "REQ-TYPE-004",
        "REQ-EXPR-001",
        "REQ-EXPR-004"
    ])
    def void testFieldNameReservedWord() {
        '''
            model Test;
            type string String min-size:0 max-size:128;

            entity A {
                field String `entity`;
                field String d <= self.`entity`;
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
        "REQ-ENT-008",
        "REQ-TYPE-001",
        "REQ-TYPE-004",
        "REQ-EXPR-001",
        "REQ-EXPR-006",
        "REQ-EXPR-007"
        //TODO: JNG-4392
    ])
    def void testEntityNameReservedWord() {
        '''
            model Test;
            type string String min-size:0 max-size:128;

            entity `entity` {
                field String str;
            }

            entity B {
                relation `entity`[] e <= `entity`.all();
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
        "REQ-MDL-003",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-TYPE-001",
        "REQ-TYPE-004",
        "REQ-EXPR-001",
        "REQ-EXPR-004"
    ])
    def void testTwoModelDefinitionReferencingDatatypeWithoutAliasAndReservedKeywordAsName() {
        val resourceSet = resourceSetProvider.get
        val a =
        '''
            model `entity`;
            type string String min-size:0 max-size:128;
        '''.parse(resourceSet)

        val b =
        '''
            model B;
            import `entity`;

            entity E abstract {
                field String f1;
            }
        '''.parse(resourceSet)

        a.assertNoErrors
        b.assertNoErrors
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-003",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-TYPE-001",
        "REQ-TYPE-004",
        "REQ-EXPR-001",
        "REQ-EXPR-004"
    ])
    def void testTwoModelDefinitionReferencingDatatypeWithAliasAndReservedKeywordAsName() {
        val resourceSet = resourceSetProvider.get
        val a =
        '''
            model `entity`;
            type string String min-size:0 max-size:128;
        '''.parse(resourceSet)

        val b =
        '''
            model B;
            import `entity` as a;

            entity E abstract {
                field a::String f1;
            }
        '''.parse(resourceSet)

        a.assertNoErrors
        b.assertNoErrors
    }

}
