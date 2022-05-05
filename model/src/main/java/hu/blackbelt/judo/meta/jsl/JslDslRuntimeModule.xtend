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
import org.eclipse.xtext.naming.IQualifiedNameProvider
import hu.blackbelt.judo.meta.jsl.scoping.JslDslQualifiedNameProvider
import hu.blackbelt.judo.meta.jsl.scoping.JslDslQualifiedNameConverter
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.parser.antlr.ISyntaxErrorMessageProvider
import hu.blackbelt.judo.meta.jsl.errormessages.JslDslSyntaxErrorMessageProvider
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import hu.blackbelt.judo.meta.jsl.scoping.JslDslGlobalScopeProvider
import com.google.inject.Singleton
import org.eclipse.xtext.generator.IOutputConfigurationProvider
import hu.blackbelt.judo.meta.jsl.generator.JslDslOutputConfigurationProvider

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class JslDslRuntimeModule extends AbstractJslDslRuntimeModule {
    
    override Class<? extends IValueConverterService> bindIValueConverterService() {
        return typeof(JslTerminalConverters)
    }
    
    override configureIScopeProviderDelegate(Binder binder) {
		binder.bind(IScopeProvider).annotatedWith(Names.named(AbstractDeclarativeScopeProvider.NAMED_DELEGATE)).to(JslDslImportedNamespaceAwareLocalSocpeProvider);
		binder.bind(IQualifiedNameConverter).to(JslDslQualifiedNameConverter)
		binder.bind(IOutputConfigurationProvider).to(JslDslOutputConfigurationProvider).in(Singleton);
	}
	
	def Class<? extends IDefaultResourceDescriptionStrategy> bindIDefaultResourceDescriptionStrategy() {
		JslResourceDescriptionStrategy;
	}

    override Class<? extends IQualifiedNameProvider> bindIQualifiedNameProvider() {
        JslDslQualifiedNameProvider;
    }

//    override Class<? extends IQualifiedNameConverter> bindIQualifiedNameConverter() {
//        JslDslQualifiedNameConverter;
//    }

	def Class<? extends ISyntaxErrorMessageProvider> bindISyntaxErrorMessageProvider() {
	  JslDslSyntaxErrorMessageProvider;
  	}
  	
  	
    override Class<? extends IGlobalScopeProvider> bindIGlobalScopeProvider() {
        JslDslGlobalScopeProvider
    }
}
