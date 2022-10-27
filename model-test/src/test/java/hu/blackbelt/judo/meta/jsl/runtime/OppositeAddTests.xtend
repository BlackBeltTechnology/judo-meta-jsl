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

@ExtendWith(InjectionExtension) 
@InjectWith(JslDslInjectorProvider)
class OppositeAddTests {
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension ValidationTestHelper
	@Inject Provider<ResourceSet> resourceSetProvider;


	@Test
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
	def void testInheritedOppositeAdd() {
		'''
			model InheritedOppositeAdd;

			entity Product {
			//	relation Discount diss;
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
