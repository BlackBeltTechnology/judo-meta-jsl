/*
 * generated by Xtext 2.31.0
 */
package hu.blackbelt.judo.meta.jsl.web

import com.google.inject.Guice
import com.google.inject.Injector
import hu.blackbelt.judo.meta.jsl.JslDslRuntimeModule
import hu.blackbelt.judo.meta.jsl.JslDslStandaloneSetup
import hu.blackbelt.judo.meta.jsl.ide.JslDslIdeModule
import org.eclipse.xtext.util.Modules2

/**
 * Initialization support for running Xtext languages in web applications.
 */
class JslDslWebSetup extends JslDslStandaloneSetup {
	
	override Injector createInjector() {
		return Guice.createInjector(Modules2.mixin(new JslDslRuntimeModule, new JslDslIdeModule, new JslDslWebModule))
	}
	
}
