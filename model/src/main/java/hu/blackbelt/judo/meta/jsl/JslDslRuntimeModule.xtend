package hu.blackbelt.judo.meta.jsl

import hu.blackbelt.judo.meta.jsl.runtime.JslTerminalConverters
import org.eclipse.xtext.conversion.IValueConverterService
import com.google.inject.Binder
import org.eclipse.xtext.scoping.IScopeProvider
import com.google.inject.name.Names
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import hu.blackbelt.judo.meta.jsl.scoping.JslDslImportedNamespaceAwareLocalSocpeProvider
import hu.blackbelt.judo.meta.jsl.scoping.JslResourceDescriptionStrategy
import org.eclipse.xtext.resource.IDefaultResourceDescriptionStrategy

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class JslDslRuntimeModule extends AbstractJslDslRuntimeModule {
    
    override Class<? extends IValueConverterService> bindIValueConverterService() {
        return typeof(JslTerminalConverters)
    }
    
    override configureIScopeProviderDelegate(Binder binder) {
		binder.bind(IScopeProvider).annotatedWith(Names.named(AbstractDeclarativeScopeProvider.NAMED_DELEGATE)).to(JslDslImportedNamespaceAwareLocalSocpeProvider);
	}
	
	def Class<? extends IDefaultResourceDescriptionStrategy> bindIDefaultResourceDescriptionStrategy() {
		return JslResourceDescriptionStrategy;
	}
}
