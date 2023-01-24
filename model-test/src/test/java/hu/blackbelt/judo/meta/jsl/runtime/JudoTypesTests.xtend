package hu.blackbelt.judo.meta.jsl.runtime

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.^extension.ExtendWith
import hu.blackbelt.judo.meta.jsl.validation.JslDslValidator
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
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
class JudoTypesTests {
	
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension ValidationTestHelper
	@Inject Provider<ResourceSet> resourceSetProvider;
	
				

	@Test
    @Requirement(reqs =#[
        "REQ-MDL-001",
        "REQ-MDL-002",
        "REQ-MDL-003",
        "REQ-TYPE-001",
        "REQ-ENT-001",
        "REQ-ENT-002"
    ])
	def void testJudoTypesImport() {
		val resourceSet = resourceSetProvider.get
		val a = 
		'''
			model A;
			
			import judo::types;
			
			entity A {
				field String str;
			}	
		'''.parse(resourceSet)
		
		a.assertNoErrors
	}
}	
