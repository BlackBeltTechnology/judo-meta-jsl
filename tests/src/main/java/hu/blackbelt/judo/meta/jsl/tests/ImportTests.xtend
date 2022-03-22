package hu.blackbelt.judo.meta.jsl.tests

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.^extension.ExtendWith
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelImport
import hu.blackbelt.judo.meta.jsl.validation.JslDslValidator
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import static extension org.junit.jupiter.api.Assertions.*
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.junit.jupiter.api.Test

@ExtendWith(InjectionExtension) 
@InjectWith(JslDslInjectorProvider)
class ImportTests {
	
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension ValidationTestHelper
		
		
	@Test 
	def void testSelfImportClassHierarchyCycle() {
		'''
		model A
		import A
		'''.parse => [
			assertHierarchyCycle("A")
		]
	}
		
	def private void assertHierarchyCycle(ModelDeclaration modelDeclaration, String expectedClassName) {
		modelDeclaration.assertError(
			JsldslPackage::eINSTANCE.modelImport,
			JslDslValidator::HIERARCHY_CYCLE,
			"cycle in hierarchy of model '" + expectedClassName + "'"
		)
	}
	
}