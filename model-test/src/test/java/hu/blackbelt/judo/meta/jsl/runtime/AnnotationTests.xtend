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
class AnnotationTests {
    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper

    @Test
    def void testAnnotationOk() {
        '''
            model Test;

            entity E {
            }

            transfer T(E e) {
                @A1
                action T f1();

                @A2(s = "string")
                action T f2();

                @A3
                action T f3();
            }

            annotation A1 transfer:action;
            annotation A2(string s) transfer:action;
            annotation A3 transfer:action {
                @A1
                @A2(s = "string")
            }
        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    def void testCyclicAnnotation() {
        '''
            model Test;

            annotation A {
                @B
            };
            annotation B {
                @A
            }
        '''.parse => [
            assertError(JsldslPackage::eINSTANCE.annotationDeclaration, JslDslValidator.ANNOTATION_CYCLE,"Cyclic annotation definition at 'A'.")
            assertError(JsldslPackage::eINSTANCE.annotationDeclaration, JslDslValidator.ANNOTATION_CYCLE,"Cyclic annotation definition at 'B'.")
        ]
    }


    @Test
    def void testAnnotationArgument() {
        '''
            model Test;

            entity E {
            }

            transfer T(E e) {
                @A2(s = 1)
                action T f2();
            }

            annotation A2(string s) transfer:action;
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationArgument, JslDslValidator.TYPE_MISMATCH,"Literal at annotation argument 's' is not compatible. (Expected: string constant, Got: numeric constant)")
        ]
    }

    @Test
    def void testAnnotationArgumentDuplicate() {
        '''
            model Test;

            entity E {
            }

            transfer T(E e) {
                @A2(s = "1", s = "2")
                action T f2();
            }

            annotation A2(string s) transfer:action;
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationArgument, JslDslValidator.DUPLICATE_PARAMETER)
        ]
    }

    @Test
    def void testAnnotationInvalid() {
        '''
            model Test;

            @A
            entity E {
            }

            transfer T(E e) {
            }

            annotation A model:transfer;
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationMark, JslDslValidator.INVALID_ANNOTATION)
        ]
    }
}
