package hu.blackbelt.judo.meta.jsl.ui.syntaxcoloring;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor;
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultHighlightingConfiguration;
import org.eclipse.xtext.util.CancelIndicator;

public class JslDslSemanticHighlightCalculator implements ISemanticHighlightingCalculator {

	@Override
	public void provideHighlightingFor(XtextResource resource, IHighlightedPositionAcceptor acceptor,
			CancelIndicator cancelIndicator) {
		if (resource == null) return;

		for(INode node : resource.getParseResult().getRootNode().getAsTreeIterable()) {
			EObject nodeGElem = node.getGrammarElement();
			if (nodeGElem != null)
				if (nodeGElem instanceof RuleCall) 
					if ( ((RuleCall)nodeGElem).getRule().getName().equals("JslID") ) {						
						acceptor.addPosition(node.getOffset(), node.getLength(),
								DefaultHighlightingConfiguration.DEFAULT_ID);
					}
		}
		
	}
	
}