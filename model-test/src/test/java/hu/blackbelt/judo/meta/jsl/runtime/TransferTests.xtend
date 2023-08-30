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

            enum EN {
                literal1 = 0;
                literal2 = 1;
            }

            entity E1 {
                identifier String id;
                field Integer f;
                field EN en;
            }

            entity E2 {
                identifier String id;
                field Integer f;
            }

            entity E3 extends E2 {
                field Integer f2;
            }

            transfer T1 {
                field String f;
                relation T2[] t2;

                constructor {
                    self.f = "";
                    self.t2 = E1!all();
                }
            }

            transfer T2(E1 e1) {
                field String f;
                field Integer f2 <= e1.f;
                field Integer f3 <=> e1.f;
                field Integer f4 <= E1!all()!size();
                field EN en <=> e1.en;
            }

            transfer T3(E2 e2);

            transfer T4(E3 e3) {
                field Integer f <= e3.f;
                field Integer f2 <= e3.f2;
            }

        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    def void testTransferUnmappedReadsOk() {
        '''
            model Test;

            import judo::types;

            entity E {}

            transfer T {
                field Integer i <= E!all()!size();
            };
        '''.parse => [
            assertNoErrors
        ]
    }


    @Test
    def void testTransferFieldRelationOk() {
        '''
            model Test;

            import judo::types;

            entity E1 {
                relation E2 e2;
                relation E2[] e2list;
            }

            entity E2 {
            }

            transfer T2(E2 e2);

            transfer T1(E1 e1) {
                relation T2 t2 <= e1.e2;
                relation T2[] t2list <= e1.e2list;
            }

        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    def void testTransferMapsReadsOppositeOk() {
        '''
            model Test;

            import judo::types;

            entity E1 {
                relation E2 e2 opposite-add:e1;
            }

            entity E2 {
            }

            transfer T1(E1 e1);

            transfer T2(E2 e2) {
                relation T1 t1r <= e2.e1;
                relation T1 t1m <=> e2.e1 choices:E1!all();
            }
        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    def void testTransferIdenitiferMapping() {
        '''
            model MappedTransferObjectTypeModel;

            type string String min-size:0 max-size:250;
            type numeric Integer precision:3 scale:0;

            entity Entity {
                identifier Integer identifier;
            }

            transfer Mapped maps Entity as e {
                field Integer mappedIdentifier <=> e.identifier;
            }
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
                relation required T2[] t2;
            }

            transfer T2(E1 e1) {
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferRelationDeclaration, JslDslValidator.INVALID_DECLARATION)
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
            m | m.assertError(JsldslPackage::eINSTANCE.transferDataAssignment, JslDslValidator.NON_STATIC_EXPRESSION)
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
            m | m.assertError(JsldslPackage::eINSTANCE.transferDataAssignment, JslDslValidator.TYPE_MISMATCH)
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
                field Integer f <= e1.f;
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
                field Integer f <=> e1.f;
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
                field String f <=> E1!any().f;
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
            m | m.assertError(JsldslPackage::eINSTANCE.transferFieldDeclaration, "org.eclipse.xtext.diagnostics.Diagnostic.Syntax")
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

//    @Test
//    def void testTransferAutomapDuplication() {
//        '''
//            model Test;
//
//            import judo::types;
//
//            entity E1 {
//                identifier String id;
//            }
//
//            transfer A1(E1 e);
//            transfer A2(E1 e);
//        '''.parse => [
//            m | m.assertError(JsldslPackage::eINSTANCE.transferDeclaration, JslDslValidator.DUPLICATE_AUTOMAP)
//        ]
//    }

//    @Test
//    def void testTransferMissingAutomap() {
//        '''
//            model Test;
//
//            import judo::types;
//
//            entity E1 {
//                field String f;
//            }
//
//            entity E2 {
//                field E1[] e1list;
//            }
//
//            transfer T1(E1 e1) {};
//
//            transfer T2(E2 e2);
//        '''.parse => [
//            m | m.assertError(JsldslPackage::eINSTANCE.transferDeclaration, JslDslValidator.INVALID_DECLARATION)
//        ]
//    }

    @Test
    def void testTransferUnmappedMaps() {
        '''
            model Test;

            import judo::types;

            entity E {}

            transfer T {
                field Integer i <=> E!all()!size();
            };
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferFieldDeclaration, JslDslValidator.INVALID_FIELD_MAPPING,"Invalid field mapping. Maps keyword cannot be used in unmapped transfer object.")
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
                relation T1 t1 <=> e.e2;
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferRelationDeclaration, JslDslValidator.INVALID_FIELD_MAPPING)
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
                relation T1 t1 <= e.e2;
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferRelationDeclaration, JslDslValidator.INVALID_FIELD_MAPPING)
        ]
    }

    @Test
    def void testTransferOppositeReadsTypeMismatch() {
        '''
            model Test;

            import judo::types;

            entity E0 {
                relation E2 e2 opposite-add:e0;
            }

            entity E1 {
            }

            entity E2 {
            }

            transfer T0(E0 e0);
            transfer T1(E1 e1);

            transfer T2(E2 e2) {
                relation T1 t1r <= e2.e0;
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferRelationDeclaration, JslDslValidator.TYPE_MISMATCH)
        ]
    }

    @Test
    def void testTransferOppositeMapsTypeMismatch() {
        '''
            model Test;

            import judo::types;

            entity E0 {
                relation E2 e2 opposite-add:e0;
            }

            entity E1 {
            }

            entity E2 {
            }

            transfer T0(E0 e0);
            transfer T1(E1 e1);

            transfer T2(E2 e2) {
                field T1 t1r <=> e2.e0;
            }
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferFieldDeclaration, JslDslValidator.TYPE_MISMATCH)
        ]
    }

    @Test
    def void testTransferFieldChoice() {
        '''
            model Test;

            import judo::types;

            entity E1 {
                relation E2 e2;
            }

            entity E2 {
            }

            transfer T1(E1 e1) {
                relation T2 t2 <=> e1.e2 choices:E2!any();
            }

            transfer T2(E2 e2);
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferChoiceModifier, JslDslValidator.INVALID_CHOICES)
        ]
    }

    @Test
    def void testTransferFieldCompositionChoice() {
        '''
            model Test;

            import judo::types;

            entity E1 {
                field E2 e2;
            }

            entity E2 {
            }

            transfer T1(E1 e1) {
                relation T2 t2 <=> e1.e2 choices:E2!any();
            }

            transfer T2(E2 e2);
        '''.parse => [
            m | m.assertError(JsldslPackage::eINSTANCE.transferChoiceModifier, JslDslValidator.INVALID_CHOICES)
        ]
    }

    @Test
    def void testTransferFieldDuplicateMapping() {
        '''
            model Test;

            import judo::types;

            entity E {
                field Integer f;
            }

            transfer T(E e) {
                field Integer f1 <=> e.f;
                field Integer f2 <=> e.f;
            }
        '''.parse => [
            m | m.assertWarning(JsldslPackage::eINSTANCE.transferFieldDeclaration, JslDslValidator.DUPLICATE_FIELD_MAPPING)
        ]
    }
    
    @Test
    def void testTransferInitializerUnmapped() {
        '''
            model Test;

            import judo::types;

            transfer T {
            	initializer;
            }
        '''.parse => [
            assertError(JsldslPackage::eINSTANCE.transferInitializerDeclaration, JslDslValidator.INVALID_DECLARATION)
        ]
    }

    @Test
    def void testTransferInitializerDuplicated() {
        '''
			model Test;
			
			import judo::types;
			
			entity A {}
			
			transfer T(A a) {
				initializer;
				initializer;
			}
        '''.parse => [
            assertError(JsldslPackage::eINSTANCE.transferInitializerDeclaration, JslDslValidator.DUPLICATE_EVENT)
        ]
    }

    @Test
    def void testTransferCreateUnmapped() {
    	// TODO: Is create allowed in unmapped transfer object? Delete? Update? Initializer?
//        '''
//            model Test;
//
//            import judo::types;
//
//            transfer T {
//            	create;
//            }
//        '''.parse => [
//            assertError(JsldslPackage::eINSTANCE.transferCreateDeclaration, JslDslValidator.INVALID_DECLARATION, "Create is not allowed in unmapped transfer object.")
//        ]
    }

    @Test
    def void testTransferCreateDuplicated() {
        '''
			model Test;
			
			import judo::types;
			
			entity A {}
			
			transfer T(A a) {
				create;
				create;
			}
        '''.parse => [
            assertError(JsldslPackage::eINSTANCE.transferCreateDeclaration, JslDslValidator.DUPLICATE_EVENT)
        ]
    }

    @Test
    def void testTransferCreateIncompatibleParameter() {
        '''
			model Test;
			
			import judo::types;
			
			entity A {}
			entity B {}
			
			transfer TA(A a) {
				create(TB);
			}
			
			transfer TB (B b) {}
        '''.parse => [
            assertError(JsldslPackage::eINSTANCE.transferCreateDeclaration, JslDslValidator.INVALID_DECLARATION, "Create parameter must be compatible to transfer object type.")
        ]
    }

    @Test
    def void testTransferCreateOk() {
        '''
			model Test;
			
			import judo::types;
			
			entity A {}
			entity B extends A {}
			
			transfer TA(A a) {
				create(TB);
			}
			
			transfer TB (B b) {}
        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    def void testTransferUpdateUnmapped() {
        '''
            model Test;

            import judo::types;

            transfer T {
            	update;
            }
        '''.parse => [
            assertError(JsldslPackage::eINSTANCE.transferUpdateDeclaration, JslDslValidator.INVALID_DECLARATION)
        ]
    }

    @Test
    def void testTransferUpdateDuplicated() {
        '''
			model Test;
			
			import judo::types;
			
			entity A {}
			
			transfer T(A a) {
				update;
				update;
			}
        '''.parse => [
            assertError(JsldslPackage::eINSTANCE.transferUpdateDeclaration, JslDslValidator.DUPLICATE_EVENT)
        ]
    }

    @Test
    def void testTransferUpdateOk() {
        '''
			model Test;
			
			import judo::types;
			
			entity A {}
			
			transfer T(A a) {
				update;
			}
        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    def void testTransferDeleteUnmapped() {
        '''
            model Test;

            import judo::types;

            transfer T {
            	delete;
            }
        '''.parse => [
            assertError(JsldslPackage::eINSTANCE.transferDeleteDeclaration, JslDslValidator.INVALID_DECLARATION)
        ]
    }

    @Test
    def void testTransferDeleteDuplicated() {
        '''
			model Test;
			
			import judo::types;
			
			entity A {}
			
			transfer T(A a) {
				delete;
				delete;
			}
        '''.parse => [
            assertError(JsldslPackage::eINSTANCE.transferEventDeclaration, JslDslValidator.DUPLICATE_EVENT)
        ]
    }

    @Test
    def void testTransferDeleteOk() {
        '''
			model Test;
			
			import judo::types;
			
			entity A {}
			
			transfer T(A a) {
				delete;
			}
        '''.parse => [
            assertNoErrors
        ]
    }
}
