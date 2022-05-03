package hu.blackbelt.judo.meta.jsl.ui.preview;

import java.util.Collection;
import java.util.Collections;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.xtext.resource.IResourceServiceProvider;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.ui.editor.XtextEditor;
import org.eclipse.xtext.ui.editor.model.XtextDocument;
import org.eclipse.xtext.ui.resource.IResourceSetProvider;
import org.eclipse.xtext.util.concurrent.IUnitOfWork;

import hu.blackbelt.judo.meta.jsl.ide.contentassist.antlr.JslDslParser;
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration;
import hu.blackbelt.judo.meta.jsl.runtime.JslParser;
import net.sourceforge.plantuml.eclipse.utils.WorkbenchPartDiagramIntentProviderContext;
import net.sourceforge.plantuml.eclipse.utils.WorkspaceDiagramIntentProviderContext;
import net.sourceforge.plantuml.text.AbstractDiagramIntentProvider;
import net.sourceforge.plantuml.util.DiagramIntent;
import net.sourceforge.plantuml.util.DiagramIntentContext;
import net.sourceforge.plantuml.util.DiagramIntentProvider;

public class JslEditorDiagramIntentProvider extends AbstractDiagramIntentProvider {

    private JslParser parser = new JslParser();
	
	private IUnitOfWork<ModelDeclaration, XtextResource> modelExtractor = new IUnitOfWork<ModelDeclaration, XtextResource>() {

		@Override
		public ModelDeclaration exec(XtextResource state) throws Exception {
			if (state.getContents().size() > 0 && state.getContents().get(0) instanceof ModelDeclaration) {
				return (ModelDeclaration) state.getContents().get(0);						
			} else {
				return null;
			}
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
			return Collections.<DiagramIntent>singletonList(new JslDslDiagramIntent(parser, model));
		}
		return null;
	}

	@Override
	protected Boolean supportsPath(final IPath path) {
		return "jsl".equals(path.getFileExtension());
	}

	private Collection<DiagramIntent> getDiagramInfos(final IFile file) {
		if (file != null && supportsPath(file.getFullPath())) {
			IProject project = file.getProject();
			URI uri = URI.createPlatformResourceURI(file.getFullPath().toString(), true);
			ResourceSet rs = IResourceServiceProvider.Registry.INSTANCE
					.getResourceServiceProvider(uri).get(IResourceSetProvider.class).get(project);
			XtextResource r = (XtextResource)rs.getResource(uri, true);
			
			ModelDeclaration model = null;
			try {
				model = modelExtractor.exec(r);
			} catch (Exception e) {
				e.printStackTrace(System.out);
			}
			return Collections.<DiagramIntent>singletonList(new JslDslDiagramIntent(parser, model));
		}
		return null;
	}

	@Override
	protected Collection<DiagramIntent> getDiagramInfos(final WorkspaceDiagramIntentProviderContext context) {
		final IFile file = ResourcesPlugin.getWorkspace().getRoot().getFile(context.getPath());
		return getDiagramInfos(file);
	}

}