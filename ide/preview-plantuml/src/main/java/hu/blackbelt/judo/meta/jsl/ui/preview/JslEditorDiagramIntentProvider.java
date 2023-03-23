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

import java.util.Collection;
import java.util.Collections;

import org.eclipse.core.runtime.IPath;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;
import org.eclipse.xtext.resource.IResourceServiceProvider;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.ui.editor.XtextEditor;
import org.eclipse.xtext.ui.editor.model.XtextDocument;
import org.eclipse.xtext.util.concurrent.IUnitOfWork;

import hu.blackbelt.judo.meta.jsl.generator.JsldslDefaultPlantUMLDiagramGenerator;
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration;
import net.sourceforge.plantuml.eclipse.utils.WorkbenchPartDiagramIntentProviderContext;
import net.sourceforge.plantuml.text.AbstractDiagramIntentProvider;
import net.sourceforge.plantuml.util.DiagramIntent;

public class JslEditorDiagramIntentProvider extends AbstractDiagramIntentProvider {

    private IUnitOfWork<ModelDeclaration, XtextResource> modelExtractor = new IUnitOfWork<ModelDeclaration, XtextResource>() {
        @Override
        public ModelDeclaration exec(XtextResource state) throws Exception {
            try {
                if (state.getContents().size() > 0 && state.getContents().get(0) instanceof ModelDeclaration) {
                    ModelDeclaration m = (ModelDeclaration) state.getContents().get(0);
                    return m;
                } else {
                    return null;
                }
            } catch (Exception e) {
                e.printStackTrace(System.err);
            }
            return null;
        }
    };

    public JslEditorDiagramIntentProvider() {
        setEditorType(XtextEditor.class);
    }

    @Override
    protected Collection<DiagramIntent> getDiagramInfos(final WorkbenchPartDiagramIntentProviderContext context) {
        if (context.getWorkbenchPart() instanceof XtextEditor) {
            XtextEditor editor = (XtextEditor) context.getWorkbenchPart();
            final IEditorInput editorInput = ((IEditorPart) context.getWorkbenchPart()).getEditorInput();
            XtextDocument document = (XtextDocument) editor.getDocumentProvider().getDocument(editorInput);
            ModelDeclaration model = document.readOnly(modelExtractor);
            JsldslDefaultPlantUMLDiagramGenerator generator =
                    IResourceServiceProvider.Registry.INSTANCE
                    .getResourceServiceProvider(model.eResource().getURI()).get(JsldslDefaultPlantUMLDiagramGenerator.class);

            return Collections.<DiagramIntent>singletonList(new JslDslDiagramIntent(generator, model));
        }
        return null;
    }

    @Override
    protected Boolean supportsPath(final IPath path) {
        return "jsl".equals(path.getFileExtension());
    }
}
