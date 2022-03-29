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
import org.eclipse.xtext.diagnostics.Severity
import hu.blackbelt.judo.meta.jsl.jsldsl.support.JslDslModelResourceSupport
import hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel.LoadArguments
import org.eclipse.emf.common.util.URI
import hu.blackbelt.judo.meta.jsl.jsldsl.support.JslDslModelResourceSupport.SaveArguments
import java.io.File

@ExtendWith(InjectionExtension) 
@InjectWith(JslDslInjectorProvider)
class ExpressionTests {
	
	@Inject extension ParseHelper<ModelDeclaration> 
	@Inject extension ValidationTestHelper
	@Inject Provider<ResourceSet> resourceSetProvider;
	
	@Test 
	def void testExpressionModel() {
		val resourceSet = resourceSetProvider.get

		val model = '''
			model SalesModel
			
			type numeric Integer precision 9  scale 0
			
			entity Lead {
				field Integer value = 100000
			}
			
			entity SalesPerson {
				relation Lead[] leads
			    derived Integer value = self.leads!count()
			    derived Integer t1 = self.leads!count() > 1
			}

		'''.parse(resourceSet)
		
		model.assertNoErrors
		
		System.out.println(model)

		// Save as XMI model
 		val jslDslModel = JslDslModelResourceSupport.jslDslModelResourceSupportBuilder()
                  .uri(URI.createFileURI("test.model"))
                  .build();
		jslDslModel.addContent(model);		
		jslDslModel.saveJslDsl(SaveArguments.jslDslSaveArgumentsBuilder.file(new File("target/salesmodel-jsl.model")))
		
	}

}	
