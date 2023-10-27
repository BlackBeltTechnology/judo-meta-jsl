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
class EagerModifierTests {
    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper


    @Test
    def void testPrimitiveFieldEagerFalse() {
        '''
            model Test;

            import judo::types;

            entity A {
                field Integer id eager : false;
            }

        '''.parse => [
            assertError(JsldslPackage::eINSTANCE.eagerModifier, JslDslValidator.INVALID_DECLARATION, "Primitive non-calculated field must be eager fetched.")
        ]
    }

    @Test
    def void testPrimitiveFieldEagerTrue() {
        '''
            model Test;

            import judo::types;

            entity A {
                field Integer id eager : true;
            }

        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    def void testRelationEagerModifier() {
        '''
            model Test;

            import judo::types;

            entity A {
                relation B b1 eager : true;
                relation B b2 eager : false;
            }

            entity B {

            }

        '''.parse => [
            assertNoErrors
        ]
    }


    @Test
    def void testTransferRelationEagerModifier() {
        '''
            model Test;

            import judo::types;

            entity A {
                relation B b1;
                relation B b2;
            }

            entity B {
            }

            transfer TA (A a) {
                 relation TB tb1 <= a.b1 eager:true;
                 relation TB tb2 eager:true;
            }

            transfer TB (B b) {
            }

        '''.parse => [
            assertError(JsldslPackage::eINSTANCE.eagerModifier, JslDslValidator.INVALID_DECLARATION, "Eager modifier needs a getter expression.")
        ]
    }

}
