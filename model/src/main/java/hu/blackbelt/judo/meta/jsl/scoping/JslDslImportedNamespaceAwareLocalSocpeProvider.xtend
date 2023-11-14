package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.emf.ecore.EObject
import java.util.List
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameConverter
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.eclipse.emf.ecore.EReference
import java.util.ArrayList
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.naming.QualifiedName

class JslDslImportedNamespaceAwareLocalSocpeProvider extends ImportedNamespaceAwareLocalScopeProvider {

    @Inject extension IQualifiedNameConverter
    @Inject extension JslDslIndex

    override protected getImplicitImports(boolean ignoreCase) {
        newArrayList(new ImportNormalizer(QualifiedName.create("judo","functions"), true, ignoreCase), new ImportNormalizer(QualifiedName.create("judo","meta"), true, ignoreCase))
    }

    override protected List<ImportNormalizer> internalGetImportedNamespaceResolvers(EObject context, boolean ignoreCase) {
        val resolvers = new ArrayList<ImportNormalizer>()
        if (context instanceof ModelDeclaration) {
            // System.out.println("Import NS: " + context.EObjectDescription.getUserData("imports"))
            for (e : context.allImports.entrySet) {
                resolvers += new JslDslImportNormalizer(e.value, e.key.toQualifiedName, true, ignoreCase)
            }
        }
        resolvers
    }

    override getScope(EObject context, EReference ref) {
        // System.out.println("JslDslImportedNamespaceAwareLocalSocpeProvider.scope=scope_" + ref.EContainingClass.name + "_" + ref.name + "(" + context.eClass.name + " context, EReference ref) : " + ref.EReferenceType.name);
        // printParents(context)

        if (context === null)
            throw new NullPointerException("context");
        var IScope result = null;
        if (context.eContainer() !== null) {
            // System.out.println("\tContainr scope")
            result = getScope(context.eContainer(), ref);
        } else {
            // System.out.println("\tResource scope")
            result = getResourceScope(context.eResource(), ref);
        }
        return getLocalElementsScope(result, context, ref);
    }

}
