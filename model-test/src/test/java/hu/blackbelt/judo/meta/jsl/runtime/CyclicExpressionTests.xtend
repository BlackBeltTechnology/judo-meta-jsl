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
        "REQ-ENT-001",
        "REQ-ENT-008",
        "REQ-TYPE-001",
        "REQ-TYPE-006",
        "REQ-EXPR-001",
        "REQ-EXPR-004"
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
        "REQ-ENT-001",
        "REQ-ENT-008",
        "REQ-TYPE-001",
        "REQ-TYPE-006",
        "REQ-EXPR-001",
        "REQ-EXPR-004",
        "REQ-EXPR-005",
        "REQ-EXPR-006",
        "REQ-EXPR-007",
        "REQ-EXPR-022",
        "REQ-ENT-009",
        "REQ-ENT-010",
        "REQ-ENT-011"
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
