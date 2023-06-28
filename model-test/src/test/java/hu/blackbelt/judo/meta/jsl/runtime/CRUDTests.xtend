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
class CRUDTests {
    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper

    @Test
    def void testCreateOnReadError() {
        '''
			model Test;
			
			import judo::types;
			
			entity A {
			}
			
			entity B {
				relation A[] alist;
			}
			
			transfer TA(A a) {
			}
			
			transfer TB(B b) {
				relation TA[] talist <= b.alist create:true;
			}
        '''.parse => [
            assertError(JsldslPackage::eINSTANCE.transferRelationDeclaration, JslDslValidator.INVALID_DECLARATION, "Create flag is allowed only for mapped relations.")
        ]
    }

    @Test
    def void testTransferCrudOk() {
        '''
			model Test;
			
			import judo::types;
			
			entity A {
			}
			
			entity B {
				relation A[] alist;
			}
			
			transfer TA(A a) {
			}
			
			transfer TB(B b) {
				relation TA[] talist <=> b.alist create:true delete:true update:true;
			}
        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    def void testTransferCrudOnUnmappedError() {
        '''
			model Test;
			
			import judo::types;
			
			entity A {
			}
			
			entity B {
				relation A[] alist;
			}
			
			transfer TA {
			}
			
			transfer TB(B b) {
				relation TA[] talist <= b.alist create:true;
			}
        '''.parse => [
            assertError(JsldslPackage::eINSTANCE.transferRelationDeclaration, JslDslValidator.INVALID_DECLARATION, "Create flag is allowed only for mapped relations.")
        ]
    }

    @Test
    def void testActorCrudOk() {
        '''
			model Test;
			
			import judo::types;
			
			entity A {
			}
			
			row TA(A a) {
			}
			
			actor human Actor {
				menu TA[] talist <= A!all() create:true delete:true update:true;
			}
        '''.parse => [
            assertNoErrors
        ]
    }
}
