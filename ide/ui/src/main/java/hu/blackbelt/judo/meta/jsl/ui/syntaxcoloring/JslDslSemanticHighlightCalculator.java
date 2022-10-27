package hu.blackbelt.judo.meta.jsl.ui.syntaxcoloring;

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

import java.util.Arrays;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.Keyword;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.TerminalRule;
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor;
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.util.CancelIndicator;

public class JslDslSemanticHighlightCalculator implements ISemanticHighlightingCalculator {

	@Override
	public void provideHighlightingFor(XtextResource resource, IHighlightedPositionAcceptor acceptor,
			CancelIndicator cancelIndicator) {
    	String[] primitiveDeclarations = {
    			"BooleanPrimitive",
    			"BinaryPrimitive",
    			"StringPrimitive",
    			"NumericPrimitive",
    			"DatePrimitive",
    			"TimePrimitive",
    			"TimestampPrimitive"
    	};
		
    	String[] modifiers = {
    			"ModifierMaxSize",
    			"ModifierMinSize",
    			"ModifierRegex",
    			"ModifierPrecision",
    			"ModifierScale",
    			"ModifierMimeTypes",
    			"ModifierMaxFileSize"
	    	};
    	
    	String[] QueryDeclaration = {
    			"EntityQueryDeclaration"
	    	};

    	if (resource == null) return;

		for(INode node : resource.getParseResult().getRootNode().getAsTreeIterable()) {
			EObject nodeGElem = node.getGrammarElement();
			if (nodeGElem != null) {
				
				if (nodeGElem instanceof TerminalRule) {
					TerminalRule terminal = (TerminalRule)nodeGElem;

					switch (terminal.getName()) {
					
					case "SL_COMMENT":
					case "ML_COMMENT":
						acceptor.addPosition(node.getOffset(), node.getText().length(),
								HighlightingConfiguration.COMMENT_ID);
						continue;
					}
				}
				
				if (nodeGElem instanceof Keyword) {
					Keyword keyword = (Keyword)nodeGElem;
					
					switch (keyword.getValue()) {

					
					case "model":
					case "import":
					case "error":
					case "type":
					case "entity":
					case "enum":
					case "as":
					case "abstract":
					case "extends":
						acceptor.addPosition(node.getOffset(), node.getText().length(),
								HighlightingConfiguration.KEYWORD_ID);
						continue;

					case "query":
						boolean highlighted=false;
						if (node.getParent().getGrammarElement() instanceof RuleCall) {
							RuleCall parent = (RuleCall)node.getParent().getGrammarElement();
							if (Arrays.stream(QueryDeclaration).anyMatch(parent.getRule().getName()::equals)) {	
								acceptor.addPosition(node.getOffset(), node.getText().length(),
										HighlightingConfiguration.FEATURE_ID);
								highlighted=true;
							}
						}
						if(!highlighted) {
							acceptor.addPosition(node.getOffset(), node.getText().length(),
									HighlightingConfiguration.KEYWORD_ID);
						}
						continue;
					case "constraint":
					case "field":
					case "identifier":
					case "derived":
					case "relation":
						acceptor.addPosition(node.getOffset(), node.getText().length(),
								HighlightingConfiguration.FEATURE_ID);
						continue;

					case "onerror":
					case "required":
					case "opposite":
					case "opposite-add":
						acceptor.addPosition(node.getOffset(), node.getText().length(),
								HighlightingConfiguration.FEATURE_ID);
						continue;

					case "regex":
					case "precision":
					case "scale":
					case "min-size":
					case "max-size":
					case "mime-types":
					case "max-file-size":					
						if (node.getParent().getGrammarElement() instanceof RuleCall) {
							RuleCall parent = (RuleCall)node.getParent().getGrammarElement();

							if (Arrays.stream(modifiers).anyMatch(parent.getRule().getName()::equals)) {	
								acceptor.addPosition(node.getOffset(), node.getText().length(),
										HighlightingConfiguration.FEATURE_ID);
								continue;
							}
						}
						break;
						
					case "boolean":
					case "binary":
					case "string":
					case "numeric":
					case "date":
					case "time":
					case "timestamp":
						if (node.getParent().getGrammarElement() instanceof RuleCall) {
							RuleCall parent = (RuleCall)node.getParent().getGrammarElement();
							
							if (Arrays.stream(primitiveDeclarations).anyMatch(parent.getRule().getName()::equals)) {	
								acceptor.addPosition(node.getOffset(), node.getText().length(),
										HighlightingConfiguration.FEATURE_ID);
								continue;
							}
						}
						break;
					}
				}
			}
		}	
	}
}
