/*
 * generated by Xtext 2.25.0
 */
package hu.blackbelt.judo.meta.jsl.web;

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

import com.google.inject.Injector;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import org.eclipse.xtext.util.DisposableRegistry;
import org.eclipse.xtext.web.servlet.XtextServlet;

/**
 * Deploy this class into a servlet container to enable DSL-specific services.
 */
@WebServlet(name = "XtextServices", urlPatterns = "/xtext-service/*")
public class JslDslServlet extends XtextServlet {
	
	private static final long serialVersionUID = 1L;
	
	DisposableRegistry disposableRegistry;
	
	public void init() throws ServletException {
		super.init();
		Injector injector = new JslDslWebSetup().createInjectorAndDoEMFRegistration();
		this.disposableRegistry = injector.getInstance(DisposableRegistry.class);
	}
	
	public void destroy() {
		if (disposableRegistry != null) {
			disposableRegistry.dispose();
			disposableRegistry = null;
		}
		super.destroy();
	}
	
}
