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
class TransferTests {
    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper
	
	@Test
    def void testTransferOk() {
        '''
			model Test;
			
			import judo::types;
			
			entity E1 {
				identifier String id;
				field Integer f;
			}

			entity E2 {
				identifier String id;
				field Integer f;
			}
			
			transfer T1 {
				field String f;
				field T2[] t2;

				constructor {
					self.f = "";
					self.t2 = E1!all();
				}
			}
			
			transfer T2(E1 e1) {
				field String f;
				field Integer f2 reads e1.f;
				field Integer f3 maps e1.f;
			}
			
			transfer T3(E2 e2);
        '''.parse => [
            assertNoErrors
        ]
    }

	@Test
    def void testTransferCollectionRequired() {
        '''
			model Test;
			
			import judo::types;
			
			entity E1 {
				identifier String id;
				field Integer f;
			}
			
			transfer T1 {
				field String f;
				field required T2[] t2;
			}
			
			transfer T2(E1 e1) {
			}
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferFieldDeclaration, JslDslValidator.USING_REQUIRED_WITH_IS_MANY)
        ]
    }

	@Test
    def void testTransferDefaultNonStatic() {
        '''
			model Test;
			
			import judo::types;
			
			entity E1 {
				identifier String id;
			}
			
			transfer T1(E1 e1) {
				field String f;
			
				constructor {
					self.f = e1.id;
				}
			}
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferDefault, JslDslValidator.NON_STATIC_EXPRESSION)
        ]
    }

	@Test
    def void testTransferDefaultTypeMismatch() {
        '''
			model Test;
			
			import judo::types;
			
			entity E1 {
				identifier String id;
			}
			
			transfer T1(E1 e1) {
				field String f;
			
				constructor {
					self.f = 1;
				}
			}
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferDefault, JslDslValidator.TYPE_MISMATCH)
        ]
    }

	@Test
    def void testTransferFieldReadsTypeMismatch() {
        '''
			model Test;
			
			import judo::types;
			
			entity E1 {
				field String f;
			}
			
			transfer T1(E1 e1) {
				field Integer f reads e1.f;
			}
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferFieldDeclaration, JslDslValidator.TYPE_MISMATCH)
        ]
    }

	@Test
    def void testTransferFieldMapsTypeMismatch() {
        '''
			model Test;
			
			import judo::types;
			
			entity E1 {
				field String f;
			}
			
			transfer T1(E1 e1) {
				field Integer f maps e1.f;
			}
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferFieldDeclaration, JslDslValidator.TYPE_MISMATCH)
        ]
    }

	@Test
    def void testTransferFieldMapsInvalid() {
        '''
			model Test;
			
			import judo::types;
			
			entity E1 {
				field String f;
			}
			
			transfer T1(E1 e1) {
				field String f maps E1!any().f;
			}
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferFieldDeclaration, JslDslValidator.INVALID_FIELD_MAPPING)
        ]
    }

	@Test
    def void testTransferFieldPrimitiveCollection() {
        '''
			model Test;
			
			import judo::types;
			
			entity E1 {
				field String f;
			}
			
			transfer T1(E1 e1) {
				field Integer[] f;
			}
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferFieldDeclaration, JslDslValidator.INVALID_COLLECTION)
        ]
    }

	@Test
    def void testTransferFieldMappingFieldDuplication() {
        '''
			model Test;
			
			import judo::types;
			
			entity E1 {
				field String f;
			}
			
			transfer T1(E1 e1) {
				field Integer e1;
			}
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferFieldDeclaration, JslDslValidator.DUPLICATE_MEMBER_NAME)
        ]
    }

	@Test
    def void testTransferFieldDuplication() {
        '''
			model Test;
			
			import judo::types;
			
			transfer T1 {
				field Integer f1;
				field Integer f2;
				field String f1;
			}
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferFieldDeclaration, JslDslValidator.DUPLICATE_MEMBER_NAME)
        ]
    }

	@Test
    def void testTransferDuplicateFunctionExport() {
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
			
			transfer A(E1 e) exports S1, S2 {}
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferDeclaration, JslDslValidator.DUPLICATE_MEMBER_NAME)
        ]
    }

	@Test
    def void testTransferAutomapDuplication() {
        '''
			model Test;
			
			import judo::types;
			
			entity E1 {
				identifier String id;
			}
			
			transfer A1(E1 e);
			transfer A2(E1 e);
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferDeclaration, JslDslValidator.DUPLICATE_AUTOMAP)
        ]
    }

	@Test
    def void testTransferMissingAutomap() {
        '''
			model Test;
			
			import judo::types;
			
			entity E1 {
				field String f;
			}
			
			entity E2 {
				field E1[] e1list;
			}
			
			transfer T1(E1 e1) {};
			
			transfer T2(E2 e2);
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferDeclaration, JslDslValidator.INVALID_DECLARATION)
        ]
    }


	@Test
    def void testTransferExportIncompatible() {
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
			
			transfer T exports S1, S3;
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferDeclaration, JslDslValidator.INCOMPAIBLE_EXPORT)
        ]
    }

	@Test
    def void testTransferMappedExportIncompatible() {
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
			
			transfer T(E1 e) exports S1, S2;
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferDeclaration, JslDslValidator.INCOMPAIBLE_EXPORT)
        ]
    }

	@Test
	def void testTransferUnmappedMaps() {
        '''
			model Test;
			
			import judo::types;
			
			entity E {}
			
			transfer T {
				field Integer i maps E!all()!size();
			};
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferFieldDeclaration, JslDslValidator.INVALID_FIELD_MAPPING)
        ]
    }

	@Test
	def void testTransferUnmappedReads() {
        '''
			model Test;
			
			import judo::types;
			
			entity E {}
			
			transfer T {
				field Integer i reads E!all()!size();
			};
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferFieldDeclaration, JslDslValidator.INVALID_FIELD_MAPPING)
        ]
    }

	@Test
	def void testTransferUnmappedReferenceMaps() {
        '''
			model Test;
			
			import judo::types;
			

			entity E1 {
				relation E2 e2;
			}
			
			entity E2 {}
			
			transfer T1 {}
			
			transfer T2 maps E1 as e {
				field T1 t1 maps e.e2;
			}
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferFieldDeclaration, JslDslValidator.INVALID_FIELD_MAPPING)
        ]
    }

	@Test
	def void testTransferUnmappedReferenceReads() {
        '''
			model Test;
			
			import judo::types;
			

			entity E1 {
				relation E2 e2;
			}
			
			entity E2 {}
			
			transfer T1 {}
			
			transfer T2 maps E1 as e {
				field T1 t1 reads e.e2;
			}
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferFieldDeclaration, JslDslValidator.INVALID_FIELD_MAPPING)
        ]
    }
}
