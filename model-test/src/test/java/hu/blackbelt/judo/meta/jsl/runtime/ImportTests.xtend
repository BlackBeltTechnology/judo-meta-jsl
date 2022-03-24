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

@ExtendWith(InjectionExtension) 
@InjectWith(JslDslInjectorProvider)
class ImportTests {
	
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension ValidationTestHelper
	@Inject Provider<ResourceSet> resourceSetProvider;
	
	@Test 
	def void testSimpleModelDefinition() {
		'''
			model A
		'''.parse => [
			assertNoErrors
		]
	}

	@Test 
	def void testTwoModelDefinitionWithDifferentName() {
		val resourceSet = resourceSetProvider.get
		val a = '''model A'''.parse(resourceSet)
		val b = '''model B'''.parse(resourceSet)
		
		a.assertNoErrors
		b.assertNoErrors
	}


	@Test 
	def void testFailOfTwoModelDefinition() {
		'''
			model A
			model B
		'''.parse => 
		[
			assertNoViableInputError
		]
	}
				
	@Test 
	def void testSelfImportClassHierarchyCycle() {
		'''
			model A
			import A
		'''.parse => 
		[
			assertHierarchyCycle("A")
		]
	}


	@Test 
	def void testImportClassHierarchyCycle() {
		val resourceSet = resourceSetProvider.get
		val a = 
		'''model A
		import C		
		'''.parse(resourceSet)
		
		val b = 
		'''
			model B
			import A
		'''.parse(resourceSet)

		val c = 
		'''
			model C
			import B
		'''.parse(resourceSet)

		
		a.assertNoErrors
		b.assertNoErrors
		c.assertNoErrors
	}

	@Test 
	def void testTwoModelDefinitionWithImportWithSimpleName() {
		val resourceSet = resourceSetProvider.get
		val a = '''model A'''.parse(resourceSet)
		
		val b = 
		'''
			model B
			import A
		'''.parse(resourceSet)
		
		a.assertNoErrors
		b.assertNoErrors
	}

	@Test 
	def void testTwoModelDefinitionWithIllegalImportName() {
		val resourceSet = resourceSetProvider.get
		val a = '''model A'''.parse(resourceSet)
		
		val b = 
		'''
			model B
			import A2
		'''.parse(resourceSet)
		
		a.assertNoErrors
		b.assertModelReferenceError("A2")
	}

	@Test 
	def void testTwoModelDefinitionWithImportWithQualifiedName() {
		val resourceSet = resourceSetProvider.get
		val a = '''model ns::A'''.parse(resourceSet)
		
		val b = 
		'''
			model B
			import ns::A
		'''.parse(resourceSet)
		
		a.assertNoErrors
		b.assertNoErrors
	}

	@Test 
	def void testTwoModelDefinitionWithImportWithIllegalQualifiedName() {
		val resourceSet = resourceSetProvider.get
		val a = '''model ns::A'''.parse(resourceSet)
		
		val b = 
		'''
			model B
			import ns2::A
		'''.parse(resourceSet)
		
		a.assertNoErrors
		b.assertModelReferenceError("ns2::A")
	}

		
	def private void assertHierarchyCycle(ModelDeclaration modelDeclaration, String expectedClassName) {
		modelDeclaration.assertError(
			JsldslPackage::eINSTANCE.modelImport,
			JslDslValidator::HIERARCHY_CYCLE,
			"cycle in hierarchy of model '" + expectedClassName + "'"
		)
	}

	def private void assertModelReferenceError(ModelDeclaration modelDeclaration, String expectedClassName) {
		modelDeclaration.assertError(
			JsldslPackage::eINSTANCE.modelImport,
			"org.eclipse.xtext.diagnostics.Diagnostic.Linking",
			"Couldn't resolve reference to ModelDeclaration '" + expectedClassName + "'."
		)
	}
	
	def private void assertNoViableInputError(ModelDeclaration modelDeclaration) {
		modelDeclaration.assertError(
			JsldslPackage::eINSTANCE.modelDeclaration, 
			"org.eclipse.xtext.diagnostics.Diagnostic.Syntax", 
			"no viable alternative at input"
		)
	}
	
}
