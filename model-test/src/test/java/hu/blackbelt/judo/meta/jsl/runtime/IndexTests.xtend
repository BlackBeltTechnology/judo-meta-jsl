package hu.blackbelt.judo.meta.jsl.runtime

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
import com.google.inject.Provider
import org.eclipse.emf.ecore.resource.ResourceSet
import hu.blackbelt.judo.meta.jsl.scoping.JslDslIndex
import org.eclipse.emf.ecore.EObject

@ExtendWith(InjectionExtension) 
@InjectWith(JslDslInjectorProvider)
class IndexTests {
	
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension ValidationTestHelper
	@Inject extension JslDslIndex

	@Test 
	def void testSimpleModelExport() {
		'''
			model A
		'''.parse => [
			assertExportedEObjectDescriptions("A")
		]
	}

	@Test 
	def void testEntityExport() {
		'''
			model A
			entity T1
		'''.parse => [
			assertExportedEObjectDescriptions("A, A::T1")
		]
	}

	def private assertExportedEObjectDescriptions(EObject o, CharSequence expected) {
		expected.toString.assertEquals(
			o.getExportedEObjectDescriptions.map[qualifiedName.toString("::")].join(", "))
	}
	
}
