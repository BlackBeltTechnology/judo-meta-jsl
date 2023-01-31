package hu.blackbelt.judo.meta.jsl.runtime

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.^extension.ExtendWith
import hu.blackbelt.judo.meta.jsl.validation.JslDslValidator
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.junit.jupiter.api.Test
import com.google.inject.Provider
import org.eclipse.emf.ecore.resource.ResourceSet
import hu.blackbelt.judo.requirement.report.annotation.Requirement

@ExtendWith(InjectionExtension)
@InjectWith(JslDslInjectorProvider)
class ImportTests {

    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper
    @Inject Provider<ResourceSet> resourceSetProvider;

    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001"
    ])
    def void testSimpleModelDefinition() {
        '''
            model A;
        '''.parse => [
            assertNoErrors
        ]
    }

    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001"
    ])
    def void testTwoModelDefinitionWithDifferentName() {
        val resourceSet = resourceSetProvider.get
        val a = '''model A;'''.parse(resourceSet)
        val b = '''model B;'''.parse(resourceSet)

        a.assertNoErrors
        b.assertNoErrors
    }


    /*
    @Test
    @Requirement(reqs =#[

    ])
    def void testFailOfTwoModelDefinition() {
        '''
            model A;
            model B;
        '''.parse =>
        [
            // assertSyntaxError("missing EOF at 'model'")
            // assertError(JsldslPackage::eINSTANCE.modelImportDeclaration, "org.eclipse.xtext.diagnostics.Diagnostic.Syntax", -1, -1)
        ]
    } */

    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-MDL-003"
        //TODO: JNG-4393
    ])
    def void testSelfImportClassHierarchyCycle() {
        '''
            model A;
            import A;
        '''.parse =>
        [
            assertHierarchyCycle("A")
        ]
    }


    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-MDL-003"
        //TODO: JNG-4393
    ])
    def void testImportClassHierarchyCycle() {
        val resourceSet = resourceSetProvider.get
        val a =
        '''
            model A;
            import C;
        '''.parse(resourceSet)

        val b =
        '''
            model B;
            import A;
        '''.parse(resourceSet)

        val c =
        '''
            model C;
            import B;
        '''.parse(resourceSet)


        a.assertNoErrors
        b.assertNoErrors
        c.assertNoErrors
    }

    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-MDL-003"
    ])
    def void testTwoModelDefinitionWithImportWithSimpleName() {
        val resourceSet = resourceSetProvider.get
        val a = '''model A;'''.parse(resourceSet)

        val b =
        '''
            model B;
            import A;
        '''.parse(resourceSet)

        a.assertNoErrors
        b.assertNoErrors
    }

    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-MDL-003"
    ])
    def void testTwoModelDefinitionWithIllegalImportName() {
        val resourceSet = resourceSetProvider.get
        val a = '''model A;'''.parse(resourceSet)

        val b =
        '''
            model B;
            import A2;
        '''.parse(resourceSet)

        a.assertNoErrors
        b.assertModelImportDeclarationLinkingError("A2")
    }

    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-MDL-003"
    ])
    def void testTwoModelDefinitionWithEmptyImportName() {
        val resourceSet = resourceSetProvider.get
        val a = '''model A;'''.parse(resourceSet)

        val b =
        '''
            model B;
            import;
        '''.parse(resourceSet)

        a.assertNoErrors
        b.assertSyntaxError("no viable alternative at input")
    }


    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-MDL-002",
        "REQ-MDL-003"
    ])
    def void testTwoModelDefinitionWithImportWithQualifiedName() {
        val resourceSet = resourceSetProvider.get
        val a = '''model ns::A;'''.parse(resourceSet)

        val b =
        '''
            model B;
            import ns::A;
        '''.parse(resourceSet)

        a.assertNoErrors
        b.assertNoErrors
    }

    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-MDL-002",
        "REQ-MDL-003"
    ])
    def void testTwoModelDefinitionWithImportWithIllegalQualifiedName() {
        val resourceSet = resourceSetProvider.get
        val a = '''model ns::A;'''.parse(resourceSet)

        val b =
        '''
            model B;
            import ns2::A;
        '''.parse(resourceSet)

        a.assertNoErrors
        b.assertModelImportDeclarationLinkingError("Couldn't resolve reference to ModelDeclaration 'ns2::A'")

    }

    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-MDL-003"
    ])
    def void testTwoModelDefinitionWithImportWithAlias() {
        val resourceSet = resourceSetProvider.get
        val a = '''model A;'''.parse(resourceSet)

        val b =
        '''
            model B;
            import A as x;
        '''.parse(resourceSet)

        a.assertNoErrors
        b.assertNoErrors
    }


    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-MDL-003",
        "REQ-TYPE-001",
        "REQ-TYPE-004",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-012"
    ])
    def void testTwoModelDefinitionReferencingDatatypeWithoutAlias() {
        val resourceSet = resourceSetProvider.get
        val a =
        '''
            model A;
            type string String(min-size = 0, max-size = 128);
        '''.parse(resourceSet)

        val b =
        '''
            model B;
            import A;

            entity abstract E {
                field String f1;
            }
        '''.parse(resourceSet)

        a.assertNoErrors
        b.assertNoErrors
    }


    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-MDL-003",
        "REQ-TYPE-001",
        "REQ-TYPE-004",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-012"
    ])
    def void testTwoModelDefinitionReferencingDatatypeWithFullyQualifiedName() {
        val resourceSet = resourceSetProvider.get
        val a =
        '''
            model A;
            type string String(min-size = 0, max-size = 128);
        '''.parse(resourceSet)

        val b =
        '''
            model B;

            entity abstract E {
                field A::String f1;
            }
        '''.parse(resourceSet)

        a.assertNoErrors
        b.assertError(
            JsldslPackage::eINSTANCE.entityFieldDeclaration,
            "org.eclipse.xtext.diagnostics.Diagnostic.Linking",
            "Couldn't resolve reference to SingleType 'A::String'."
        )
    }

    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-MDL-003",
        "REQ-TYPE-001",
        "REQ-TYPE-004",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-012"
    ])
    def void testTwoModelDefinitionReferencingDatatypeWithAlias() {
        val resourceSet = resourceSetProvider.get
        val a =
        '''
            model A;
            type string String(min-size = 0, max-size = 128);
        '''.parse(resourceSet)

        val b =
        '''
            model B;
            import A as x;

            entity abstract E {
                field x::String f1;
            }
        '''.parse(resourceSet)

        a.assertNoErrors
        b.assertNoErrors
    }

    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-MDL-003",
        "REQ-TYPE-001",
        "REQ-TYPE-004"
    ])
    def void testImportAliasCollison() {
        val resourceSet = resourceSetProvider.get
        val a =
        '''
            model A;
            type string String(min-size = 0, max-size = 128);
        '''.parse(resourceSet)

        val b =
        '''
            model B;
            type string String(min-size = 0, max-size = 128);
        '''.parse(resourceSet)

        val c =
        '''
            model C;
            import A as x;
            import B as X;
        '''.parse(resourceSet)

        a.assertNoErrors
        b.assertNoErrors
        c.assertError(JsldslPackage::eINSTANCE.modelImportDeclaration, JslDslValidator.IMPORT_ALIAS_COLLISION)
    }

    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-MDL-003",
        "REQ-TYPE-001",
        "REQ-TYPE-004"
        //TODO: JNG-4394
    ])
    def void testImportAliasCollsionWithModel() {
        val resourceSet = resourceSetProvider.get
        val a =
        '''
            model A;
            type string String(min-size = 0, max-size = 128);
        '''.parse(resourceSet)

        val b =
        '''
            model B;
            type string String(min-size = 0, max-size = 128);
        '''.parse(resourceSet)

        val c =
        '''
            model C;
            import A as b;
            import B;
        '''.parse(resourceSet)

        a.assertNoErrors
        b.assertNoErrors
        c.assertError(JsldslPackage::eINSTANCE.modelImportDeclaration, JslDslValidator.IMPORT_ALIAS_COLLISION)
    }

    /*
     * This is an example for JNG-4394
    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-MDL-003",
        "REQ-TYPE-001",
        "REQ-TYPE-004"
        //TODO: JNG-4394
    ])
    def void testImportAliasCollsionWithModel2() {
        val resourceSet = resourceSetProvider.get
        val a =
        '''
            model A;
            type string String(min-size = 0, max-size = 128);
        '''.parse(resourceSet)

        val b =
        '''
            model B;
            type string String(min-size = 0, max-size = 20);
        '''.parse(resourceSet)

        val c =
        '''
            model C;
            import A as b;
            import B as a;

            entity abstract E {
                field a::String f1;
                field b::String f2;
            }
        '''.parse(resourceSet)

        a.assertNoErrors
        b.assertNoErrors
        c.assertNoErrors
    }
    */

    @Test
    @Requirement(reqs =#[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-MDL-003"
    ])
    def void testHiddenDeclaration() {
        val resourceSet = resourceSetProvider.get
        val a =
        '''
            model A;

            entity A {}
        '''.parse(resourceSet)

        val b =
        '''
            model B;
            import A;

            entity A {}
        '''.parse(resourceSet)

        a.assertNoErrors
        b.assertWarning(JsldslPackage::eINSTANCE.named, JslDslValidator.HIDDEN_DECLARATION)
    }

    def private void assertHierarchyCycle(ModelDeclaration modelDeclaration, String expectedClassName) {
        modelDeclaration.assertError(
            JsldslPackage::eINSTANCE.modelImportDeclaration,
            JslDslValidator::HIERARCHY_CYCLE,
            "cycle in hierarchy of model '" + expectedClassName + "'"
        )
    }

    /*
    def private void assertModelReferenceError(ModelDeclaration modelDeclaration, String expectedClassName) {
        modelDeclaration.assertError(
            JsldslPackage::eINSTANCE.modelImportDeclaration,
            JslDslValidator::IMPORTED_MODEL_NOT_FOUND,
            "Imported model '" + expectedClassName + "' not found"
        )
    }
    */

    def private void assertSyntaxError(ModelDeclaration modelDeclaration, String error) {
        modelDeclaration.assertError(
            JsldslPackage::eINSTANCE.modelImportDeclaration,
            "org.eclipse.xtext.diagnostics.Diagnostic.Syntax",
            error
        )
    }

    def private void assertSyntaxError(ModelDeclaration modelDeclaration) {
        modelDeclaration.assertError(
            JsldslPackage::eINSTANCE.modelImportDeclaration,
            "org.eclipse.xtext.diagnostics.Diagnostic.Syntax"
        )
    }

    def private void assertModelImportDeclarationLinkingError(ModelDeclaration modelDeclaration, String error) {
        modelDeclaration.assertError(
            JsldslPackage::eINSTANCE.modelImportDeclaration,
            "org.eclipse.xtext.diagnostics.Diagnostic.Linking",
            error
        )
    }

}
