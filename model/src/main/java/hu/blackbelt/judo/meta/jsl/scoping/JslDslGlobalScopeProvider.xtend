package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.xtext.scoping.impl.DefaultGlobalScopeProvider
import org.eclipse.xtext.scoping.IScope
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.EReference
import com.google.common.base.Predicate
import org.eclipse.xtext.resource.IEObjectDescription
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameConverter
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import org.slf4j.Logger
import org.slf4j.LoggerFactory

class JslDslGlobalScopeProvider extends DefaultGlobalScopeProvider {
	Logger log = LoggerFactory.getLogger(JslDslGlobalScopeProvider);

	@Inject extension IQualifiedNameConverter
	@Inject extension JslDslModelExtension
		
	override getScope(Resource resource, EReference reference) {
		log.debug("JslDslGlobalScopeProvider.getScope=" + reference);
		super.getScope(resource, reference)		

	}
	
    override IScope getScope(Resource resource, EReference reference, Predicate<IEObjectDescription> filter) {
		log.debug("JslDslGlobalScopeProvider.getScope Res: " + resource + "Ref: " + reference);

		
		if (JsldslPackage::eINSTANCE.modelImport_ModelName == reference) {
			log.debug("JslDslGlobalScopeProvider.getScope NULL");
			super.getScope(resource, reference, filter);
		}

	    val overridedFilter = new Predicate<IEObjectDescription>() {
            override boolean apply(IEObjectDescription input) {
				val model = resource.getContents().get(0).modelDeclaration

				var found = false
				for (modelImport : model.imports) {

					log.debug("> JslDslGlobalScopeProvider.getScope Import NS: " + modelImport.modelName.importName.toQualifiedName.toString("::") + " FIELD: " + input.qualifiedName.toString("::"));

					val normalizer = new ImportNormalizer(modelImport.modelName.importName.toQualifiedName, true, false);
					if (normalizer.deresolve(input.qualifiedName) !== null) {
						log.debug("> JslDslGlobalScopeProvider.getScope=" + input.qualifiedName.toString("::"));
						found = true
					}
				}
	
				if (filter === null) {
					return found
				} else {
	            	return filter.apply(input) && found					
				}
            }
        }
        super.getScope(resource, reference, overridedFilter);
    }
	
}