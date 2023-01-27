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
class OppositeAddTests {
    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper
    @Inject Provider<ResourceSet> resourceSetProvider;


    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-ENT-001",
        "REQ-ENT-004",
        "REQ-ENT-005",
        "REQ-ENT-006",
        "REQ-ENT-008",
        "REQ-EXPR-003"
    ])
    def void testSimpleOppositeAdd() {

        '''
            model SimpleOppositeAdd;

            entity Product {
            }

            entity Discount {
                relation Product[] products opposite-add discount;
            }


            entity CartItem {
                relation required Product product;
                derived Discount b => self.product.discount;
            }
        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-ENT-001",
        "REQ-ENT-004",
        "REQ-ENT-005",
        "REQ-ENT-006",
        "REQ-ENT-008",
        "REQ-EXPR-003"
    ])
    def void testSimpleWithMultipleCardinalityOppositeAdd() {

        '''
            model SimpleWithMultipleCardinalityOppositeAdd;

            entity Product {
            }

            entity Discount {
                relation Product[] products opposite-add discounts[];
            }


            entity CartItem {
                relation required Product product;
                derived Discount[] b => self.product.discounts;
            }
        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-SYNT-005",
        "REQ-MDL-001",
        "REQ-ENT-001",
        "REQ-ENT-004",
        "REQ-ENT-005",
        "REQ-ENT-006",
        "REQ-ENT-008",
        "REQ-ENT-012",
        "REQ-EXPR-003"
    ])
    def void testInheritedOppositeAdd() {
        '''
            model InheritedOppositeAdd;

            entity Product {
            //    relation Discount diss;
            }

            entity ChildProduct extends Product {
            }


            entity Discount {
                relation Product[] products opposite-add discount;
            }


            entity CartItem {
                relation required ChildProduct product;
                derived Discount b => self.product.discount;
            }
        '''.parse => [
            assertNoErrors
        ]
    }



    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-MDL-003",
        "REQ-ENT-001",
        "REQ-ENT-004",
        "REQ-ENT-005",
        "REQ-ENT-006",
        "REQ-ENT-008",
        "REQ-EXPR-003"
    ])
    def void testImportedModelNavigation() {
        val resourceSet = resourceSetProvider.get
        val a =
        '''
            model ImportedModelNavigationProduct;

            entity Product {
            }
        '''.parse(resourceSet)

        val b =
        '''
            model ImportedModelNavigation;
            import ImportedModelNavigationProduct as P;

            entity Discount {
                relation P::Product[] products opposite-add discount;
            }


            entity CartItem {
                relation required P::Product product;
                derived Discount b => self.product.discount;
            }


        '''.parse(resourceSet)

        a.assertNoErrors
        b.assertNoErrors
    }


    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-MDL-003",
        "REQ-ENT-001",
        "REQ-ENT-004",
        "REQ-ENT-005",
        "REQ-ENT-006",
        "REQ-ENT-008",
        "REQ-ENT-012",
        "REQ-EXPR-003"
    ])
    def void testInheritedImportedModelNavigation() {
        val resourceSet = resourceSetProvider.get
        val a =
        '''
            model InheritedImportedModelNavigationProduct;

            entity Product {
            }
        '''.parse(resourceSet)

        val b =
        '''
            model InheritedImportedModelNavigation;
            import InheritedImportedModelNavigationProduct as P;

            entity ChildProduct extends P::Product {
            }


            entity Discount {
                relation ChildProduct products opposite-add discount;
            }


            entity CartItem {
                relation required ChildProduct product;
                derived Discount b => self.product.discount;
            }


        '''.parse(resourceSet)

        a.assertNoErrors
        b.assertNoErrors
    }

}
