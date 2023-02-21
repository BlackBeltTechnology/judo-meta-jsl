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
import org.eclipse.xtext.ParserRule;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.TerminalRule;
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor;
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.util.CancelIndicator;

import hu.blackbelt.judo.meta.jsl.jsldsl.ActorDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.AnnotationDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityMapDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.Literal;
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.ServiceDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewGroupDeclaration;

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

					continue;
				}

				if (node.getSemanticElement() instanceof Literal) {
					acceptor.addPosition(node.getOffset(), node.getText().length(),
							HighlightingConfiguration.CONSTANT_ID);
					continue;
				}
				
				if (nodeGElem instanceof Keyword) {
					Keyword keyword = (Keyword)nodeGElem;

					if (keyword.eContainer().eContainer() instanceof ParserRule) {
						ParserRule parserRule = (ParserRule) keyword.eContainer().eContainer();
						if (parserRule.getName().equals("JSLID")) continue;
					}
					
					switch (keyword.getValue()) {
					
					case "@":
						acceptor.addPosition(node.getOffset(), node.getParent().getLength(),
								HighlightingConfiguration.ANNOTATION_ID);
						continue;
					
					case "model": 
						if (node.getSemanticElement() instanceof ModelDeclaration) {
							acceptor.addPosition(node.getOffset(), node.getText().length(),
								HighlightingConfiguration.KEYWORD_ID);
						}
						continue;

					case "view":
					case "row":
					case "actor":
					case "realm":
					case "identity":
					case "type":
					case "import":
					case "maps":
					case "as":
					case "error":
					case "entity":
					case "enum":
					case "abstract":
					case "extends":
					case "exports":
					case "service":
					case "transfer":
					case "annotation":
					case "on":
					case "automap":
						if (node.getSemanticElement().eContainer() instanceof ModelDeclaration || node.getSemanticElement() instanceof EntityMapDeclaration) {
							acceptor.addPosition(node.getOffset(), node.getText().length(),
								HighlightingConfiguration.KEYWORD_ID);
						}
						continue;
					
					case "left":
					case "right":
					case "center":
					case "top":
					case "bottom":
					case "stretch":
						if (node.getSemanticElement().eContainer() instanceof ViewGroupDeclaration) {
							acceptor.addPosition(node.getOffset(), node.getText().length(),
									HighlightingConfiguration.CONSTANT_ID);
						}
						continue;
					
					case "widget":
					case "group":
					case "tab":
					case "horizontal":
					case "vertical":
					case "frame":

					case "table":
					case "action":
					case "column":
					case "caption":
					case "icon":
					case "enabled":
					case "width":
					case "height":
					
					case "boolean":
					case "binary":
					case "string":
					case "numeric":
					case "date":
					case "time":
					case "timestamp":

					case "get":
					case "create":
					case "update":
					case "delete":
					case "insert":
					case "remove":

					case "function":
					case "options":
					case "operation":
					case "static":
					case "constraint":
					case "field":
					case "identifier":
					case "derived":
					case "relation":
					case "onerror":
					case "required":
					case "opposite":
					case "opposite-add":
					case "void":
						if (!(node.getSemanticElement().eContainer() instanceof AnnotationDeclaration)) {
							acceptor.addPosition(node.getOffset(), node.getText().length(),
									HighlightingConfiguration.FEATURE_ID);
						}
						continue;
						
					case "query":
						if (node.getSemanticElement().eContainer() instanceof ModelDeclaration) {
							acceptor.addPosition(node.getOffset(), node.getText().length(),
								HighlightingConfiguration.KEYWORD_ID);
						} else {
							acceptor.addPosition(node.getOffset(), node.getText().length(),
									HighlightingConfiguration.FEATURE_ID);
						}
						continue;

					case "guard":
						if (node.getSemanticElement() instanceof ActorDeclaration || node.getSemanticElement() instanceof ServiceDeclaration) {
							acceptor.addPosition(node.getOffset(), node.getText().length(),
								HighlightingConfiguration.KEYWORD_ID);
						} else {
							acceptor.addPosition(node.getOffset(), node.getText().length(),
									HighlightingConfiguration.FEATURE_ID);
						}
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
					}
				}
			}
		}	
	}
}
