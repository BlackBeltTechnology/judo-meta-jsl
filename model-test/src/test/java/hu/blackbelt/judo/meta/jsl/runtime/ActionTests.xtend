package hu.blackbelt.judo.meta.jsl.runtime

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.^extension.ExtendWith
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.junit.jupiter.api.Test
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import hu.blackbelt.judo.meta.jsl.validation.JslDslValidator

@ExtendWith(InjectionExtension)
@InjectWith(JslDslInjectorProvider)
class ActionTests {
    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper

    @Test
    def void testActionOk() {
        '''
			model test;

			entity A {
			}

			transfer TA maps A as a {
				action void taAction();
			}

			transfer TB {
				action void tbAction() static;
			}
        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    def void testNonstaticActionInUnammpedTransfer() {
        '''
			model test;

			transfer TB {
				action void tbAction();
			}
        '''.parse => [
        	m | m.assertError(JsldslPackage::eINSTANCE.transferActionDeclaration, JslDslValidator.INVALID_DECLARATION)
        ]
    }
}
