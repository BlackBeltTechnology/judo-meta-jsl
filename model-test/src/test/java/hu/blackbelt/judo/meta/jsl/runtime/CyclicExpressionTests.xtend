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

@ExtendWith(InjectionExtension) 
@InjectWith(JslDslInjectorProvider)
class CyclicExpressionTests {
	
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension ValidationTestHelper
	
	@Test
    @Requirement(reqs =#[
        
    ])
	def void testSelfDerived() {
		'''
			model Test;
			
			type boolean Boolean;
			
			entity Test {
				derived Boolean b => self.b;
			}
						
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.entityDerivedDeclaration, JslDslValidator.EXPRESSION_CYCLE)
		]
	}


	@Test
    @Requirement(reqs =#[
        
    ])
	def void testComplexCycle() {
		'''
			model test;
			
			type boolean Boolean;
			
			query Boolean staticQuery() => A!any().c;
			
			entity A {
				query Boolean q() => staticQuery();
				derived Boolean a => self.q();
				derived Boolean b => self.a;
				derived Boolean c => self.b;
			}						
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.entityDerivedDeclaration, JslDslValidator.EXPRESSION_CYCLE)
		]
	}
}	
