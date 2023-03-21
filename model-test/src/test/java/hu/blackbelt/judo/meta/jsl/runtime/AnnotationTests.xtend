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
import hu.blackbelt.judo.requirement.report.annotation.Requirement

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
			}
			
			service S(E e) {
				@A1
				function T f1();
			
				@A2(s = "string")
				function T f2();
			
				@A3
				function T f3();
			}
			
			annotation A1 on service::function;
			annotation A2(string s) on service::function;
			annotation A3  on service::function {
				@A1
				@A2(s = "string")
			}
        '''.parse => [
            assertNoErrors
        ]
    }

	@Test
    def void testAnnotationCRUDOk() {
        '''
			model Test;
			
			entity E {
			}
			
			transfer T(E e) {
			}
			
			service S(E e) {
				@Factory
				function T f1();
			
				@Delete
				function void f2();
			
				@Create
				function void f3(T t);
			
				@Update
				function void f4(T t);
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
            m | m.assertError(JsldslPackage::eINSTANCE.annotationDeclaration, JslDslValidator.ANNOTATION_CYCLE)
        ]
    }

    @Test
    def void testFactoryIsAction() {
        '''
			model Test;
			
			entity E {
			}
			
			transfer T(E e) {
			}
			
			service S(E e) {
				@Factory
				function T fd => E!any();
			}

		'''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationMark, JslDslValidator.INVALID_ANNOTATION_MARK)
        ]
    }

    @Test
    def void testFactoryReturnValue() {
        '''
			model Test;
			
			transfer A {
			}
			
			service S {
				@Factory
				function void f();
			}        
		'''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationMark, JslDslValidator.INVALID_ANNOTATION_MARK)
        ]
    }

    @Test
    def void testFactoryInput() {
        '''
			model Test;
			
			transfer A {
			}
			
			service S {
				@Factory
				function A f(A a);
			}        
		'''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationMark, JslDslValidator.INVALID_ANNOTATION_MARK)
        ]
    }

    @Test
    def void testDeleteIsAction() {
        '''
			model Test;
			
			entity E {
			}
			
			transfer T(E e) {
			}
			
			service S(E e) {
				@Factory
				function T fd => E!any();
			}

		'''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationMark, JslDslValidator.INVALID_ANNOTATION_MARK)
        ]
    }

    @Test
    def void testDeleteInput() {
        '''
			model Test;
			
			entity E {
			}
			
			transfer T {
			}
			
			service S(E e) {
				@Delete
				function void f(A a);
			}
		'''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationMark, JslDslValidator.INVALID_ANNOTATION_MARK)
        ]
    }

    @Test
    def void testDeleteReturnValue() {
        '''
			model Test;
			
			entity E {
			}
			
			transfer T {
			}
			
			service S(E e) {
				@Delete
				function A f();
			}
		'''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationMark, JslDslValidator.INVALID_ANNOTATION_MARK)
        ]
    }

    @Test
    def void testDeleteUnampped() {
        '''
			model Test;
			
			entity E {
			}
			
			transfer T {
			}
			
			service S {
				@Delete
				function void f();
			}
		'''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationMark, JslDslValidator.INVALID_ANNOTATION_MARK)
        ]
    }

    @Test
    def void testCreateIsAction() {
        '''
			model Test;
			
			entity E {
			}
			
			transfer T(E e) {
			}
			
			service S(E e) {
				@Create
				function T fd => E!any();
			}

		'''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationMark, JslDslValidator.INVALID_ANNOTATION_MARK)
        ]
    }

    @Test
    def void testCreateReturnValue() {
        '''
			model Test;
			
			entity E {
			}
			
			transfer T {
			}
			
			service S(E e) {
				@Create
				function A f();
			}
		'''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationMark, JslDslValidator.INVALID_ANNOTATION_MARK)
        ]
    }

    @Test
    def void testCreateInputValue() {
        '''
			model Test;
			
			entity E {
			}
			
			transfer T {
			}
			
			service S(E e) {
				@Create
				function void f();
			}
		'''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationMark, JslDslValidator.INVALID_ANNOTATION_MARK)
        ]
    }

    @Test
    def void testCreateInputIsMapped() {
        '''
			model Test;
			
			entity E {
			}
			
			transfer T {
			}
			
			service S(E e) {
				@Create
				function void f(T);
			}
		'''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationMark, JslDslValidator.INVALID_ANNOTATION_MARK)
        ]
    }

    @Test
    def void testInsertIsCollection() {
        '''
			model Test;
			
			entity E {
			}
			
			transfer T(E e) {
			}
			
			service S(E e) {
				@Insert
				function T fd => E!any();
			}
		'''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationMark, JslDslValidator.INVALID_ANNOTATION_MARK)
        ]
    }

    @Test
    def void testInsertIsData() {
        '''
			model Test;
			
			entity E {
			}
			
			transfer T(E e) {
			}
			
			service S(E e) {
				@Insert
				function T f();
			}
		'''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationMark, JslDslValidator.INVALID_ANNOTATION_MARK)
        ]
    }

	@Test
    def void testAnnotationArgument() {
        '''
			model Test;
			
			entity E {
			}
			
			transfer T(E e) {
			}
			
			service S(E e) {
				@A2(s = 1)
				function T f2();
			}
			
			annotation A2(string s) on service::function;
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationArgument, JslDslValidator.TYPE_MISMATCH)
        ]
    }

	@Test
    def void testAnnotationArgumentDuplicate() {
        '''
			model Test;
			
			entity E {
			}
			
			transfer T(E e) {
			}
			
			service S(E e) {
				@A2(s = "1", s = "2")
				function T f2();
			}
			
			annotation A2(string s) on service::function;
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationArgument, JslDslValidator.DUPLICATE_PARAMETER)
        ]
    }

	@Test
    def void testAnnotationArgumentRequired() {
        '''
			model Test;
			
			entity E {
			}
			
			transfer T(E e) {
			}
			
			service S(E e) {
				@A2()
				function T f2();
			}
			
			annotation A2(string s) on service::function;
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationMark, JslDslValidator.MISSING_REQUIRED_PARAMETER)
        ]
    }

	@Test
    def void testAnnotationInvalid() {
        '''
			model Test;
			
			entity E {
			}
			
			transfer T(E e) {
			}
			
			@A
			service S(E e) {
				function T f2();
			}
			
			annotation A on service::function;
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationMark, JslDslValidator.INVALID_ANNOTATION)
        ]
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SRV-010",
        "REQ-SRV-011",
        "REQ-SRV-012"
    ])
    def void testInsertAndRemoveAnnotation() {
        '''
			model test;

			entity A {
				relation B b;
				relation B[] lst;
			}
			
			entity B {
			}
			
			transfer TB(B b) {
			}
			
			service S(A a) {
				@Insert @Remove
				function TB b => a.b;

				@Insert @Remove
				function TB[] lst => a.lst;
			}
        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SRV-010",
        "REQ-SRV-011"
    ])
    def void testInsertAnnotationOnComposition() {
        '''
			model test;

			entity A {
				field B[] lst;
			}
			
			entity B {
			}
			
			transfer TB(B b) {
			}
			
			service S(A a) {
				@Insert
				function TB[] lst => a.lst;
			}
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationMark, JslDslValidator.INVALID_ANNOTATION_MARK)
        ]
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SRV-010",
        "REQ-SRV-012"
    ])
    def void testRemoveAnnotationOnStatic() {
        '''
			model test;

			entity A {
				relation B[] lst;
			}
			
			entity B {
			}
			
			transfer TB(B b) {
			}
			
			service S(A a) {
				@Remove
				function TB[] lst => A!any().lst;
			}
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.annotationMark, JslDslValidator.INVALID_ANNOTATION_MARK)
        ]
    }

}