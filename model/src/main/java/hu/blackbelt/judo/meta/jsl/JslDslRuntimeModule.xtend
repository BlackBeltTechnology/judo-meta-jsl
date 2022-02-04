package hu.blackbelt.judo.meta.jsl

import hu.blackbelt.judo.meta.jsl.runtime.JslTerminalConverters
import org.eclipse.xtext.conversion.IValueConverterService

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class JslDslRuntimeModule extends AbstractJslDslRuntimeModule {
    
    override Class<? extends IValueConverterService> bindIValueConverterService() {
        return typeof(JslTerminalConverters)
    }
    
}
