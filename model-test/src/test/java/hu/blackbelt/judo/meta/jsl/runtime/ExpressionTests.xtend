package hu.blackbelt.judo.meta.jsl.runtime

import static extension hu.blackbelt.judo.meta.jsl.util.JslExpressionToJqlExpression.*
import static extension org.junit.jupiter.api.Assertions.*

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
import hu.blackbelt.judo.meta.jsl.jsldsl.support.JslDslModelResourceSupport
import org.eclipse.emf.common.util.URI
import hu.blackbelt.judo.meta.jsl.jsldsl.support.JslDslModelResourceSupport.SaveArguments
import java.io.File
import java.util.stream.Collectors
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration

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
			type string String max-length 32
			
			entity Lead {
				field Integer value = 100000
			}
			
			entity SalesPerson {
				relation Lead[] leads
			    derived Integer value = self.leads!count()
			    derived Integer t1 = self.leads!count() > 1
				derived Customer[] leadsOver(Integer limit = 100) = self.leads!filter(lead | lead.value > limit)
				derived Customer[] leadsOver10 = self.leads(limit = 10)
				derived Customer selfDerived = self
				derived Customer anyCustomer = Customer!any()
				derived Customer stringConcat = "" + self.value + "test"
				derived Customer complex = self.leads!count() > 0 ? self.leads!filter(lead | lead.closed)!count() / self.leads!count() : 0
				derived Customer arithmetic = ((1 + 2) * 3) / 4
			}

			entity Customer {
				identifier required String name
				relation Lead[] lead opposite-single customer
			}
		'''.parse(resourceSet)
		
		model.assertNoErrors
		

		// Save as XMI model
 		val jslDslModel = JslDslModelResourceSupport.jslDslModelResourceSupportBuilder()
                  .uri(URI.createFileURI("test.model"))
                  .build();
		jslDslModel.addContent(model);
		jslDslModel.saveJslDsl(SaveArguments.jslDslSaveArgumentsBuilder.file(new File("target/salesmodel-jsl.model")))

		jslDslModel.jql("SalesPerson", "value").assertEquals("self.leads!count()")
		jslDslModel.jql("SalesPerson", "t1").assertEquals("self.leads!count()>1")
		jslDslModel.jql("SalesPerson", "leadsOver").assertEquals("self.leads!filter(lead|lead.value>limit)")
		jslDslModel.jql("SalesPerson", "leadsOver10").assertEquals("self.leads(limit=10)")
		jslDslModel.jql("SalesPerson", "selfDerived").assertEquals("self")
		jslDslModel.jql("SalesPerson", "anyCustomer").assertEquals("Customer!any()")
		jslDslModel.jql("SalesPerson", "stringConcat").assertEquals("\"\"+self.value+\"test\"")
		jslDslModel.jql("SalesPerson", "complex").assertEquals("self.leads!count()>0?self.leads!filter(lead|lead.closed)!count()/self.leads!count():0")
		jslDslModel.jql("SalesPerson", "arithmetic").assertEquals("((1+2)*3)/4")
	}
	
	
	def String jql(JslDslModelResourceSupport it, String entity, String field) {
		it.streamOfJsldslEntityDerivedDeclaration.collect(Collectors.toList())
			.findFirst[d | d.name.equals(field) && (d.eContainer as EntityDeclaration).name.equals(entity)].expression.jql
	}
}	
