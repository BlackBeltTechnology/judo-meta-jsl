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
    @Requirement(reqs =#[
        
    ])
	def void testFieldNameReservedWord() {
		'''
			model Test;
			type string String(min-size = 0, max-size = 128);			

			entity A {
				field String `entity`;
				derived String d => self.`entity`;
			}
		'''.parse => [
			assertNoErrors
		]
	}


	@Test 
	def void testEntityNameReservedWord() {
		'''
			model Test;
			type string String(min-size = 0, max-size = 128);			

			entity `entity` {
				field String str;
			}

			entity B {
				derived `entity`[] e => `entity`!all();
			}

		'''.parse => [
			assertNoErrors
		]
	}

	@Test 
	def void testTwoModelDefinitionReferencingDatatypeWithoutAliasAndReservedKeywordAsName() {
		val resourceSet = resourceSetProvider.get
		val a = 
		'''
			model `entity`;
			type string String(min-size = 0, max-size = 128);			
		'''.parse(resourceSet)
		
		val b = 
		'''
			model B;
			import `entity`;
			
			entity abstract E {
				field String f1;
			}	
		'''.parse(resourceSet)
		
		a.assertNoErrors
		b.assertNoErrors
	}

	@Test 
	def void testTwoModelDefinitionReferencingDatatypeWithAliasAndReservedKeywordAsName() {
		val resourceSet = resourceSetProvider.get
		val a = 
		'''
			model `entity`;
			type string String(min-size = 0, max-size = 128);			
		'''.parse(resourceSet)
		
		val b = 
		'''
			model B;
			import `entity` as a;
			
			entity abstract E {
				field a::String f1;
			}	
		'''.parse(resourceSet)
		
		a.assertNoErrors
		b.assertNoErrors
	}

}	
