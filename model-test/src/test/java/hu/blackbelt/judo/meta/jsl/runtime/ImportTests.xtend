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
			assertSyntaxError("no viable alternative at input")
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
	def void testTwoModelDefinitionWithEmptyImportName() {
		val resourceSet = resourceSetProvider.get
		val a = '''model A'''.parse(resourceSet)
		
		val b = 
		'''
			model B
			import
		'''.parse(resourceSet)
		
		a.assertNoErrors
		b.assertSyntaxError("no viable alternative at input")
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

	@Test 
	def void testTwoModelDefinitionWithImportWithAlias() {
		val resourceSet = resourceSetProvider.get
		val a = '''model A'''.parse(resourceSet)
		
		val b = 
		'''
			model B
			import A as a
		'''.parse(resourceSet)
		
		a.assertNoErrors
		b.assertNoErrors
	}


	@Test 
	def void testTwoModelDefinitionReferencingDatatypeWithoutAlias() {
		val resourceSet = resourceSetProvider.get
		val a = 
		'''
			model A
			type string String(max-length = 128)			
		'''.parse(resourceSet)
		
		val b = 
		'''
			model B
			import A
			
			entity abstract E {
				field String f1
			}	
		'''.parse(resourceSet)
		
		a.assertNoErrors
		b.assertNoErrors
	}


	@Test 
	def void testTwoModelDefinitionReferencingDatatypeWithFullyQualifiedName() {
		val resourceSet = resourceSetProvider.get
		val a = 
		'''
			model A
			type string String(max-length = 128)			
		'''.parse(resourceSet)
		
		val b = 
		'''
			model B
			
			entity abstract E {
				field A::String f1
			}	
		'''.parse(resourceSet)
		
		a.assertNoErrors
		b.assertError(
			JsldslPackage::eINSTANCE.entityFieldDeclaration, 
			"org.eclipse.xtext.diagnostics.Diagnostic.Linking",
			"Couldn't resolve reference to SingleType 'A::String'."
		)
	}

	@Test 
	def void testTwoModelDefinitionReferencingDatatypeWithAlias() {
		val resourceSet = resourceSetProvider.get
		val a = 
		'''
			model A
			type string String(max-length = 128)			
		'''.parse(resourceSet)
		
		val b = 
		'''
			model B
			import A as a
			
			entity abstract E {
				field a::String f1
			}	
		'''.parse(resourceSet)
		
		a.assertNoErrors
		b.assertNoErrors
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
			JslDslValidator::IMPORTED_MODEL_NOT_FOUND,
			"Imported model '" + expectedClassName + "' not found"
		)
	}
	
	def private void assertSyntaxError(ModelDeclaration modelDeclaration, String error) {
		modelDeclaration.assertError(
			JsldslPackage::eINSTANCE.modelDeclaration, 
			"org.eclipse.xtext.diagnostics.Diagnostic.Syntax", 
			error
		)
	}
}	
