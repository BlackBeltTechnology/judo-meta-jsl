package hu.blackbelt.judo.meta.jsl.osgi;

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

import hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel;
import hu.blackbelt.osgi.utils.osgi.api.BundleCallback;
import hu.blackbelt.osgi.utils.osgi.api.BundleTrackerManager;
import hu.blackbelt.osgi.utils.osgi.api.BundleUtil;
import lombok.extern.slf4j.Slf4j;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.osgi.framework.VersionRange;
import org.osgi.service.component.ComponentContext;
import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Deactivate;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.metatype.annotations.AttributeDefinition;
import org.osgi.service.metatype.annotations.Designate;
import org.osgi.service.metatype.annotations.ObjectClassDefinition;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.function.Predicate;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel.LoadArguments.jslDslLoadArgumentsBuilder;
import static hu.blackbelt.judo.meta.jsl.jsldsl.runtime.JslDslModel.loadJslDslModel;
import static java.util.Optional.ofNullable;

@Component(immediate = true)
@Slf4j
public class JslDslModelBundleTracker {

    public static final String JSLDSL_MODELS = "JslDsl-Models";

    @Reference
    BundleTrackerManager bundleTrackerManager;

    Map<String, ServiceRegistration<JslDslModel>> jslModelRegistrations = new ConcurrentHashMap<>();

    Map<String, JslDslModel> jslModels = new HashMap<>();

    @Activate
    public void activate(final ComponentContext componentContext) {
        bundleTrackerManager.registerBundleCallback(this.getClass().getName(),
                new JslDslRegisterCallback(componentContext.getBundleContext()),
                new JslDslUnregisterCallback(),
                new JslDslBundlePredicate());
    }

    @Deactivate
    public void deactivate(final ComponentContext componentContext) {
        bundleTrackerManager.unregisterBundleCallback(this.getClass().getName());
    }

    private static class JslDslBundlePredicate implements Predicate<Bundle> {
        @Override
        public boolean test(Bundle trackedBundle) {
            return BundleUtil.hasHeader(trackedBundle, JSLDSL_MODELS);
        }
    }

    private class JslDslRegisterCallback implements BundleCallback {

        BundleContext bundleContext;

        public JslDslRegisterCallback(BundleContext bundleContext) {
            this.bundleContext = bundleContext;
        }


        @Override
        public void accept(Bundle trackedBundle) {
            List<Map<String, String>> entries = BundleUtil.getHeaderEntries(trackedBundle, JSLDSL_MODELS);


            for (Map<String, String> params : entries) {
                String key = params.get(JslDslModel.NAME);
                if (jslModelRegistrations.containsKey(key)) {
                    log.error("JslDsl model already loaded: " + key);
                } else {
                    // Unpack model
                    try {
                        JslDslModel jslModel = loadJslDslModel(jslDslLoadArgumentsBuilder()
                                .inputStream(trackedBundle.getEntry(params.get("file")).openStream())
                                .name(params.get(JslDslModel.NAME))
                                .version(trackedBundle.getVersion().toString()));

                        log.info("Registering JslDsl model: " + jslModel);

                        ServiceRegistration<JslDslModel> modelServiceRegistration = bundleContext.registerService(JslDslModel.class, jslModel, jslModel.toDictionary());
                        jslModels.put(key, jslModel);
                        jslModelRegistrations.put(key, modelServiceRegistration);

                    } catch (IOException | JslDslModel.JslDslValidationException e) {
                        log.error("Could not load JslDsl model: " + params.get(JslDslModel.NAME) + " from bundle: " + trackedBundle.getBundleId(), e);
                    }
                }
            }
        }

        @Override
        public Thread process(Bundle bundle) {
            return null;
        }
    }

    private class JslDslUnregisterCallback implements BundleCallback {

        @Override
        public void accept(Bundle trackedBundle) {
            List<Map<String, String>> entries = BundleUtil.getHeaderEntries(trackedBundle, JSLDSL_MODELS);
            for (Map<String, String> params : entries) {
                String key = params.get(JslDslModel.NAME);

                if (jslModels.containsKey(key)) {
                    ServiceRegistration<JslDslModel> modelServiceRegistration = jslModelRegistrations.get(key);

                    if (modelServiceRegistration != null) {
                        log.info("Unregistering JslDsl model: " + jslModels.get(key));
                        modelServiceRegistration.unregister();
                        jslModelRegistrations.remove(key);
                        jslModels.remove(key);
                    }
                } else {
                    log.error("JslDsl Model is not registered: " + key);
                }
            }
        }

        @Override
        public Thread process(Bundle bundle) {
            return null;
        }
    }

}
