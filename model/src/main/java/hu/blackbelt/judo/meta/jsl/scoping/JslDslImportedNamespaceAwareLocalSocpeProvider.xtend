package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.emf.ecore.EObject
import java.util.List
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelImport
import org.eclipse.xtext.naming.IQualifiedNameConverter
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.eclipse.xtext.scoping.impl.AbstractGlobalScopeDelegatingScopeProvider
import org.eclipse.emf.ecore.EReference
import java.util.ArrayList
import org.eclipse.xtext.scoping.IScope
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.ISelectable
import static java.util.Collections.singletonList
import com.google.inject.Provider
import org.eclipse.xtext.util.IResourceScopeCache
import java.util.Iterator
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.scoping.impl.MultimapBasedSelectable
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.scoping.impl.ImportScope
import org.eclipse.emf.ecore.EClass
import org.eclipse.xtext.util.Tuples
import com.google.common.collect.Lists
import org.eclipse.emf.common.util.EList
import org.eclipse.xtext.scoping.impl.SelectableBasedScope
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.util.Strings

class JslDslImportedNamespaceAwareLocalSocpeProvider extends 
 AbstractGlobalScopeDelegatingScopeProvider { 
//ImportedNamespaceAwareLocalScopeProvider {

	@Inject extension IQualifiedNameConverter

	@Inject
	private IQualifiedNameProvider qualifiedNameProvider;

	@Inject
	private IQualifiedNameConverter qualifiedNameConverter;

	@Inject
	private IResourceScopeCache cache = IResourceScopeCache.NullImpl.INSTANCE;

	/* 
	override getImplicitImports(boolean ignoreCase) {
		newArrayList(new ImportNormalizer(QualifiedName.create("smalljava", "lang"), true, ignoreCase
		))
	} */	
	// https://github.com/eclipse/xtext-extras/blob/master/org.eclipse.xtext.xbase/deprecated/org/eclipse/xtext/xbase/scoping/XbaseImportedNamespaceScopeProvider.java
	
//	protected getImportedNamespace(EObject object) {
//		val ns = super.getImportedNamespace(object)
//		System.out.println("JslDslImportedNamespaceAwareLocalSocpeProvider.getImportedNamespace=" + ns + " object: " + object);
//		//ns
//		""
//	}

	def List<ImportNormalizer> internalgetImportedNamespaceResolvers(EObject context, boolean ignoreCase) {
		val resolvers = new ArrayList<ImportNormalizer>(); 
		// super.internalGetImportedNamespaceResolvers(context, ignoreCase)
		
//		System.out.println("JslDslImportedNamespaceAwareLocalSocpeProvider.internalGetImportedNamespaceResolvers="+ context.toString + " Num of resolvers: " + resolvers.size);
//		if (context instanceof ModelDeclaration) {
//			resolvers += createImportedNamespaceResolver(context.name, ignoreCase)
//		}

		if (context instanceof ModelDeclaration) {
			System.out.println("JslDslImportedNamespaceAwareLocalSocpeProvider.internalGetImportedNamespaceResolvers="+ context.toString);

			val root = context as ModelDeclaration
			for (ModelImport modelImport : root.imports) {
				if (modelImport.importedModel !== null && modelImport.importedModel.name.toQualifiedName !== null) {
					resolvers += new JslDslImportNormalizer(modelImport.importedModel.alias, modelImport.importedModel.name.toQualifiedName, true, ignoreCase)
				}
			}
		}
		resolvers
	}
	
	override getScope(EObject context, EReference reference) {
		System.out.println("JslDslImportedNamespaceAwareLocalSocpeProvider.getScope Context: " + context + " Reference: " + reference);

		if (context === null)
			throw new NullPointerException("context");
			
		if (context instanceof ModelImport) {
			// Resolving model
			if (reference.name.equals("importModel")) {
				
			}
		}

		var IScope result = null;
		if (context.eContainer() !== null) {
			result = getScope(context.eContainer(), reference);
		} else {
			result = getResourceScope(context.eResource(), reference);
		}
		return getLocalElementsScope(result, context, reference);

	}
	
	def IScope getResourceScope(Resource res, EReference reference) {
		System.out.println("JslDslImportedNamespaceAwareLocalSocpeProvider.getResourceScope  Resource: " + res + " Ref: " + reference)
		val EObject context = res.getContents().get(0);
		var IScope globalScope = getGlobalScope(res, reference);
		val List<ImportNormalizer> normalizers = new ArrayList() // getImplicitImports(isIgnoreCase(reference));
		if (!normalizers.isEmpty()) {
			globalScope = createImportScope(globalScope, normalizers, null, reference.getEReferenceType(), isIgnoreCase(reference));
		}
		return getResourceScope(globalScope, context, reference);
	}
	
	def IScope getResourceScope(IScope parent, EObject context, EReference reference) {
		// TODO: SZ - context may not be a proxy, may it?
		if (context.eResource() === null)
			return parent;
		val ISelectable allDescriptions = getAllDescriptions(context.eResource());
		return SelectableBasedScope.createScope(parent, allDescriptions, reference.getEReferenceType(), isIgnoreCase(reference));
	}
	
	
	def IScope getLocalElementsScope(IScope parent, EObject context,
			EReference reference) {
		var IScope result = parent;
		val ISelectable allDescriptions = getAllDescriptions(context.eResource());
		val QualifiedName name = getQualifiedNameOfLocalElement(context);
		val boolean ignoreCase = isIgnoreCase(reference);
		val List<ImportNormalizer> namespaceResolvers = getImportedNamespaceResolvers(context, ignoreCase);
		if (!namespaceResolvers.isEmpty()) {
			if (name !== null && !name.isEmpty()) {
				val ImportNormalizer localNormalizer = doCreateImportNormalizer(name, true, ignoreCase); 
				result = createImportScope(result, singletonList(localNormalizer), allDescriptions, reference.getEReferenceType(), isIgnoreCase(reference));
			}
			result = createImportScope(result, namespaceResolvers, null, reference.getEReferenceType(), isIgnoreCase(reference));
		}
		if (name !== null) {
			val ImportNormalizer localNormalizer = doCreateImportNormalizer(name, true, ignoreCase); 
			result = createImportScope(result, singletonList(localNormalizer), allDescriptions, reference.getEReferenceType(), isIgnoreCase(reference));
		}
		return result;
	}
	
	def ISelectable getAllDescriptions(Resource resource) {
		return cache.get("internalGetAllDescriptions", resource, new Provider<ISelectable>() {
			override ISelectable get() {
				return internalGetAllDescriptions(resource);
			}
		});
	}
	
	def ISelectable internalGetAllDescriptions(Resource resource) {
		val Iterable<EObject> allContents = new Iterable<EObject>(){
			override Iterator<EObject> iterator() {
				return EcoreUtil.getAllContents(resource, false);
			}
		}; 
		val Iterable<IEObjectDescription> allDescriptions = Scopes.scopedElementsFor(allContents, qualifiedNameProvider);
		return new MultimapBasedSelectable(allDescriptions);
	}
	
	def QualifiedName getQualifiedNameOfLocalElement(EObject context) {
		return qualifiedNameProvider.getFullyQualifiedName(context);
	}
	
	def ImportScope createImportScope(IScope parent, List<ImportNormalizer> namespaceResolvers, ISelectable importFrom, EClass type, boolean ignoreCase) {
		return new ImportScope(namespaceResolvers, parent, importFrom, type, ignoreCase);
	}
	
	def List<ImportNormalizer> getImportedNamespaceResolvers(EObject context, boolean ignoreCase) {
		return cache.get(Tuples.create(context, ignoreCase, "imports"), context.eResource(), new Provider<List<ImportNormalizer>>() {
			override List<ImportNormalizer> get() {
				return internalGetImportedNamespaceResolvers(context, ignoreCase);
			}
		});
	}
	
	def List<ImportNormalizer> internalGetImportedNamespaceResolvers(EObject context, boolean ignoreCase) {
		val List<ImportNormalizer> importedNamespaceResolvers = Lists.newArrayList();
		val EList<EObject> eContents = context.eContents();
		for (EObject child : eContents) {
			val String value = getImportedNamespace(child);
			val ImportNormalizer resolver = createImportedNamespaceResolver(value, ignoreCase);
			if (resolver !== null)
				importedNamespaceResolvers.add(resolver);
		}
		return importedNamespaceResolvers;
	}
		
	def ImportNormalizer doCreateImportNormalizer(QualifiedName importedNamespace, boolean wildcard, boolean ignoreCase) {
		return new ImportNormalizer(importedNamespace, wildcard, ignoreCase);
	}
	
	def String getImportedNamespace(EObject object) {
		val EStructuralFeature feature = object.eClass().getEStructuralFeature("importedModel");
		if (feature !== null && String.equals(feature.getEType().getInstanceClass())) {
			return object.eGet(feature) as String;
		}
		return null;
	}
	
	
	/**
	 * Create a new {@link ImportNormalizer} for the given namespace.
	 * @param namespace the namespace.
	 * @param ignoreCase <code>true</code> if the resolver should be case insensitive.
	 * @return a new {@link ImportNormalizer} or <code>null</code> if the namespace cannot be converted to a valid
	 * qualified name.
	 */
	def ImportNormalizer createImportedNamespaceResolver(String namespace, boolean ignoreCase) {
		if (Strings.isEmpty(namespace))
			return null;
		val QualifiedName importedNamespace = qualifiedNameConverter.toQualifiedName(namespace);
		if (importedNamespace == null || importedNamespace.isEmpty()) {
			return null;
		}
		return doCreateImportNormalizer(importedNamespace, true, ignoreCase);
	}
	
}