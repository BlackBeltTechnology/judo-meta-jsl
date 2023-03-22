package hu.blackbelt.judo.meta.jsl.ui.preview;

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

import hu.blackbelt.judo.meta.jsl.generator.JsldslDefaultPlantUMLDiagramGenerator;
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration;
import net.sourceforge.plantuml.text.AbstractDiagramIntent;

public class JslDslDiagramIntent extends AbstractDiagramIntent<ModelDeclaration> {

    private JsldslDefaultPlantUMLDiagramGenerator generator;

    public JslDslDiagramIntent(JsldslDefaultPlantUMLDiagramGenerator generator, ModelDeclaration source) {
        super(source);
        this.generator = generator;
    }

    public JslDslDiagramIntent(JsldslDefaultPlantUMLDiagramGenerator generator, ModelDeclaration source, String label) {
        super(source, label);
        this.generator = generator;
    }

    @Override
    public String getDiagramText() {
        try {
            return String.valueOf(generator.generate(this.getSource(), null));
        } catch (Exception e) {
            e.printStackTrace(System.err);
        }
        return null;
    }

}
