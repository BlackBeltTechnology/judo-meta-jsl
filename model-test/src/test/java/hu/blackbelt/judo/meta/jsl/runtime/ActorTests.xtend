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

            actor human A(E e)
                claim:"claim"
                realm:"realm"
                guard:true
                identity:e.id;
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

            actor human A(E e)
                claim:"claim"
                realm:"realm"
                guard:true
                identity:E!any().id;
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.identityModifier, JslDslValidator.INVALID_IDENTITY_MAPPING)
        ]
    }

    @Test
    def void testActorIdentityNonField() {
        '''
            model Test;

            import judo::types;

            entity E {
                identifier String id;
                field String id2 <= self.id;
            }

            actor system A(E e)
                claim:"claim"
                realm:"realm"
                guard:true
                identity:e.id2;
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.identityModifier, JslDslValidator.INVALID_IDENTITY_MAPPING)
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

            actor human A(E e)
                claim:"claim"
                realm:"realm"
                guard:true
                identity:E!any().id;
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.identityModifier, JslDslValidator.INVALID_IDENTITY_MAPPING)
        ]
    }
    
    @Test
    def void testSystemActorMenuError() {
        '''
            model Test;

            import judo::types;

            entity E {
                identifier String id;
            }

            view VE(E e) {}

            actor system A(E e)
                claim:"claim"
                realm:"realm"
                guard:true
                identity:e.id
            {
            	menu VE ve <= E!any();
            };
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.actorDeclaration, "org.eclipse.xtext.diagnostics.Diagnostic.Syntax")
        ]
    }

    @Test
    def void testSystemActorGroupError() {
        '''
            model Test;

            import judo::types;

            actor system A
            {
            	group g {};
            };
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.actorDeclaration, "org.eclipse.xtext.diagnostics.Diagnostic.Syntax")
        ]
    }
}
