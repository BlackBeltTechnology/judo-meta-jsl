package hu.blackbelt.judo.meta.jsl.runtime;

/*-
 * #%L
 * Judo :: Jsl :: Model
 * %%
 * Copyright (C) 2018 - 2022 BlackBelt Technology
 * %%
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 *
 * This Source Code may also be made available under the following Secondary
 * Licenses when the conditions for such availability set forth in the Eclipse
 * Public License, v. 2.0 are satisfied: GNU General Public License, version 2
 * with the GNU Classpath Exception which is
 * available at https://www.gnu.org/software/classpath/license.html.
 *
 * SPDX-License-Identifier: EPL-2.0 OR GPL-2.0 WITH Classpath-exception-2.0
 * #L%
 */

import com.google.inject.Guice;
import com.google.inject.Injector;
import hu.blackbelt.judo.meta.jsl.JslDslRuntimeModule;
import hu.blackbelt.judo.meta.jsl.JslDslStandaloneSetup;
import org.eclipse.xtext.testing.GlobalRegistries;
import org.eclipse.xtext.testing.GlobalRegistries.GlobalStateMemento;
import org.eclipse.xtext.testing.IInjectorProvider;
import org.eclipse.xtext.testing.IRegistryConfigurator;

public class JslDslInjectorProvider implements IInjectorProvider, IRegistryConfigurator {

    protected GlobalStateMemento stateBeforeInjectorCreation;
    protected GlobalStateMemento stateAfterInjectorCreation;
    protected Injector injector;

    static {
        GlobalRegistries.initializeDefaults();
    }

    @Override
    public Injector getInjector() {
        if (injector == null) {
            this.injector = internalCreateInjector();
            stateAfterInjectorCreation = GlobalRegistries.makeCopyOfGlobalState();
        }
        return injector;
    }

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

    @Override
    public void restoreRegistry() {
        stateBeforeInjectorCreation.restoreGlobalState();
        stateBeforeInjectorCreation = null;
    }

    @Override
    public void setupRegistry() {
        stateBeforeInjectorCreation = GlobalRegistries.makeCopyOfGlobalState();
        if (injector == null) {
            getInjector();
        }
        stateAfterInjectorCreation.restoreGlobalState();
    }
}
