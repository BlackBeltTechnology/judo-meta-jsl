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
import org.eclipse.emf.ecore.EClass
import hu.blackbelt.judo.requirement.report.annotation.Requirement

@ExtendWith(InjectionExtension) 
@InjectWith(JslDslInjectorProvider)
class EntityMemberDeclarationTests {
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension ValidationTestHelper
	
	@Test
    @Requirement(reqs =#[
        
    ])
	def void testSelfInDefaultNotAllowed() {
		'''
			model test;
			
			type boolean Boolean;
			
			entity A {
				field Boolean a;
				field Boolean b = self.a;
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.entityFieldDeclaration, JslDslValidator.SELF_NOT_ALLOWED)
		]
	}

	@Test
    @Requirement(reqs =#[
        
    ])
	def void testDuplicateInheritedMembersInvalid() {
		'''
			model test;
			
			type string String(min-size = 0, max-size = 12);
			
			entity B1 {
			    field String name;
			}
			
			entity B2 {
			    field String name;
			}
			
			entity A extends B1,B2 {
			}

		'''.parse => [
			assertInheritedMemberNameCollisionError("Inherited member name collision for: 'test::B1.name', 'test::B2.name'", JsldslPackage::eINSTANCE.entityDeclaration)
		]
	}

	@Test
    @Requirement(reqs =#[
        
    ])
	def void testMemberNameTooLong() {
		'''
			model test;
			
			type string String(min-size = 0, max-size = 12);
			
			entity Person {
				field String tgvkyzidsggsdxxrszoscrljgnnixjzkyztoxpdvvqbmlrpzaakkwcczsarbqrqjnphrlfkfcjgcmgbxdexakswitdmcfjyjblkmiknvdgtyxlunkolxzaneifhyizgureqemldvypsongytiwmfaqrnxuodiunflyduwzerdossywvzgkmvdbfvpumaqzdazqomqwoaqynrixrwirmtbqmihmwkjmdaulwnfoxcmzldaxyjnihbluepwdswz;
			}

		'''.parse => [
			assertInheritedMemberNameLengthError("Member name: 'tgvkyzidsggsdxxrszoscrljgnnixjzkyztoxpdvvqbmlrpzaakkwcczsarbqrqjnphrlfkfcjgcmgbxdexakswitdmcfjyjblkmiknvdgtyxlunkolxzaneifhyizgureqemldvypsongytiwmfaqrnxuodiunflyduwzerdossywvzgkmvdbfvpumaqzdazqomqwoaqynrixrwirmtbqmihmwkjmdaulwnfoxcmzldaxyjnihbluepwdswz' is too long, must be at most 128 characters", JsldslPackage::eINSTANCE.entityMemberDeclaration)
		]
	}
	
	@Test
    @Requirement(reqs =#[
        
    ])
	def void testFieldIsManyRequired() {
		'''
			model test;
			
			type string String(min-size = 0, max-size = 1000);
			
			entity B1 {
			    field required String[] attr;
			}

		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.entityFieldDeclaration, JslDslValidator.USING_REQUIRED_WITH_IS_MANY, "Collection typed field: 'attr' cannot have keyword: 'required'")
		]
	}
	
	@Test
    @Requirement(reqs =#[
        
    ])
	def void testRelationIsManyRequired() {
		'''
			model test;
			
			type string String(min-size = 0, max-size = 1000);
			
			entity B1 {
			    relation required B2[] others;
			}

			entity B2 {
			    String name;
			}
		'''.parse => [
			m | m.assertError(JsldslPackage::eINSTANCE.entityRelationDeclaration, JslDslValidator.USING_REQUIRED_WITH_IS_MANY, "Collection typed relation: 'others' cannot have keyword: 'required'")
		]
	}

	def private void assertInheritedMemberNameCollisionError(ModelDeclaration modelDeclaration, String error, EClass target) {
		modelDeclaration.assertError(
			target, 
			JslDslValidator.INHERITED_MEMBER_NAME_COLLISION, 
			error
		)
	}

	def private void assertInheritedMemberNameLengthError(ModelDeclaration modelDeclaration, String error, EClass target) {
		modelDeclaration.assertError(
			target, 
			JslDslValidator.MEMBER_NAME_TOO_LONG, 
			error
		)
	}
}
