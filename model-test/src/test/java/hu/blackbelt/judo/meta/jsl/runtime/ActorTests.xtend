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
class ActorTests {
    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper
	
	@Test
    def void testActorOk() {
        '''
			model Test;
			
			import judo::types;
			
			entity E {
				identifier String id;
			}
			
			actor A(E e)
				claim "claim"
				realm "realm"
				guard true
				identity e.id;
        '''.parse => [
            assertNoErrors
        ]
    }

	@Test
    def void testActorExportOk() {
        '''
			model Test;
			
			import judo::types;
			
			entity E1 {
				identifier String id;
			}
			
			entity E2 {
			}
			
			service S1(E1 e1) {}
			service S2(E2 e2) {}
			service S3 {}
			
			actor A(E1 e) exports S1, S3
				claim "claim"
				realm "realm"
				guard true
				identity e.id;
        '''.parse => [
            assertNoErrors
        ]
    }

	@Test
    def void testActorIdentityExpression() {
        '''
			model Test;
			
			import judo::types;
			
			entity E {
				identifier String id;
			}
			
			actor A(E e)
				claim "claim"
				realm "realm"
				guard true
				identity E!any().id;
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.actorDeclaration, JslDslValidator.INVALID_IDENTITY_MAPPING)
        ]
    }

	@Test
    def void testActorIdentityNonField() {
        '''
			model Test;
			
			import judo::types;
			
			entity E {
				identifier String id;
				derived String id2 => self.id;
			}
			
			actor A(E e)
				claim "claim"
				realm "realm"
				guard true
				identity e.id2;
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.actorDeclaration, JslDslValidator.INVALID_IDENTITY_MAPPING)
        ]
    }

	@Test
    def void testActorIdentityNonString() {
        '''
			model Test;
			
			import judo::types;
			
			entity E {
				identifier Integer id;
			}
			
			actor A(E e)
				claim "claim"
				realm "realm"
				guard true
				identity E!any().id;
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.actorDeclaration, JslDslValidator.INVALID_IDENTITY_MAPPING)
        ]
    }

	@Test
    def void testActorExportIncompatible() {
        '''
			model Test;
			
			import judo::types;
			
			entity E1 {
				identifier String id;
			}
			
			entity E2 {
			}
			
			service S1(E1 e1) {}
			service S2(E2 e2) {}
			service S3 {}
			
			actor A exports S1, S3
				claim "claim"
				realm "realm"
				guard true;
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.actorDeclaration, JslDslValidator.INCOMPAIBLE_EXPORT)
        ]
    }

	@Test
    def void testActorMappedExportIncompatible() {
        '''
			model Test;
			
			import judo::types;
			
			entity E1 {
				identifier String id;
			}
			
			entity E2 {
			}
			
			service S1(E1 e1) {}
			service S2(E2 e2) {}
			service S3 {}
			
			actor A(E1 e) exports S1, S2
				claim "claim"
				realm "realm"
				guard true;
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.actorDeclaration, JslDslValidator.INCOMPAIBLE_EXPORT)
        ]
    }

	@Test
    def void testActorDuplicateFunctionExport() {
        '''
			model Test;
			
			import judo::types;
			
			entity E1 {
				identifier String id;
			}
			
			service S1(E1 e1) {
				function void f();
			}
			service S2(E1 e1) {
				function void f();
			}
			
			actor A(E1 e) exports S1, S2
				claim "claim"
				realm "realm"
				guard true;
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.actorDeclaration, JslDslValidator.DUPLICATE_MEMBER_NAME)
        ]
    }
}
