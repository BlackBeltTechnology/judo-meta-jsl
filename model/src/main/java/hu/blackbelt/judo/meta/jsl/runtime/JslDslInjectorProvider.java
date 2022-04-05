package hu.blackbelt.judo.meta.jsl.runtime;

import com.google.inject.Guice;
import com.google.inject.Injector;
import hu.blackbelt.judo.meta.jsl.JslDslRuntimeModule;
import hu.blackbelt.judo.meta.jsl.JslDslStandaloneSetup;

public class JslDslInjectorProvider {

//	protected Injector injector;

	protected Injector internalCreateInjector() {
		return new JslDslStandaloneSetup() {
			@Override
			public Injector createInjector() {
				return Guice.createInjector(createRuntimeModule());
			}
		}.createInjectorAndDoEMFRegistration();
	}

	protected JslDslRuntimeModule createRuntimeModule() {
		// make it work also with Maven/Tycho and OSGI
		// see https://bugs.eclipse.org/bugs/show_bug.cgi?id=493672
		return new JslDslRuntimeModule() {
			@Override
			public ClassLoader bindClassLoaderToInstance() {
				return JslDslInjectorProvider.class
						.getClassLoader();
			}
		};
	}

}
