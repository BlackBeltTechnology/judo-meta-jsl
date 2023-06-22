package hu.blackbelt.judo.meta.jsl.ui.syntaxcoloring;

import java.util.Arrays;
import java.util.Iterator;

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

import hu.blackbelt.judo.meta.jsl.jsldsl.AnnotationMark;
import hu.blackbelt.judo.meta.jsl.jsldsl.Literal;

public class JslDslSemanticHighlightCalculator implements ISemanticHighlightingCalculator {
	static String[] symbols = {"SC", "BLOCK_START", "BLOCK_END",
			                   "LP", "RP", "DOT", "COMMA", "LB", "RB", "LRB", "ASSIGN", "LT", "GT", "QM", "COLON",
			                   "NEQ", "EQ", "GTE", "LTE", "MAP", "PLUS", "MINUS", "MUL", "DIV", "EXP", "EXCL", "PIPE"
	};

	static String[] operators = {"KW_NOT", "KW_IMPLIES", "KW_OR", "KW_XOR", "KW_AND", "KW_DIV", "KW_MOD"};

	static String[] constants = {"KW_BINARY", "KW_BOOLEAN", "KW_BOTTOM", "KW_CENTER", "KW_COLLECTION", "KW_CONSTANT", "KW_DATE", "KW_DECLARATION", "KW_FALSE", "KW_LEFT",
    							 "KW_NUMERIC", "KW_RIGHT", "KW_STRING", "KW_TIME", "KW_TIMESTAMP", "KW_TOP", "KW_TRUE", "KW_VOID",
    							 "KW_KB", "KW_MB", "KW_GB", "KW_KIB", "KW_MIB", "KW_GIB"
    };

    static String[] features = {"KW_ACCESS", "KW_ACTION", "KW_COLUMN", "KW_CONSTRAINT", "KW_CONSTRUCTOR", "KW_CREATE", "KW_DELETE", "KW_DESTRUCTOR",
    							"KW_FIELD", "KW_GROUP", "KW_HORIZONTAL", "KW_IDENTIFIER", "KW_INITIALIZER", "KW_LINK", "KW_LITERAL",
    							"KW_MENU", "KW_RELATION", "KW_SUBMIT", "KW_TABLE", "KW_TABS", "KW_TEXT", "KW_UPDATE", "KW_VERTICAL"
    };

    static String[] attributes = {"KW_CHOICES", "KW_CLAIM", "KW_DETAIL", "KW_ENABLED", "KW_FRAME", "KW_GUARD", "KW_HIDDEN", "KW_HALIGN", "KW_ICON",
    							  "KW_IDENTITY", "KW_LABEL", "KW_MAXFILESIZE", "KW_MAXSIZE", "KW_MINSIZE", "KW_MIMETYPE", "KW_OPPOSITE", "KW_OPPOSITEADD",
    							  "KW_PRECISION", "KW_REALM", "KW_REGEX", "KW_REQUIRED", "KW_ROWS", "KW_SCALE", "KW_STRETCH", "KW_THROW", "KW_VALIGN", "KW_WIDTH"
    };

    static String[] specials = {"KW_CREATE", "KW_DELETE", "KW_UPDATE"};
    
    @Override
    public void provideHighlightingFor(XtextResource resource, IHighlightedPositionAcceptor acceptor, CancelIndicator cancelIndicator) {
        if (resource == null) return;

        Iterator<INode> iterator = resource.getParseResult().getRootNode().getAsTreeIterable().iterator();
        
        while (iterator.hasNext()) {
        	INode node = iterator.next();

            EObject nodeGElem = node.getGrammarElement();
            
            if (nodeGElem != null) {
            	if (nodeGElem instanceof RuleCall) {
            		RuleCall rc = (RuleCall)nodeGElem;

            		if (rc.getRule() instanceof ParserRule) {
                        ParserRule parserRule = (ParserRule) rc.getRule();

                        if (parserRule.getName().equals("JSLID")) {
                			// skip the rest of the tree
                        	iterator.next();
                        	iterator.next();
                        	continue;
                        }
            		}

            		if (rc.getRule() instanceof TerminalRule) {
                        TerminalRule terminalRule = (TerminalRule) rc.getRule();

                        if (terminalRule.getName().equals("NUMBER")) {
                            acceptor.addPosition(node.getOffset(), node.getText().length(),
                            HighlightingConfiguration.CONSTANT_ID);
                            continue;
                        }

	                    if (terminalRule.getName().startsWith("KW_")) {
	                        if (Arrays.stream(specials).anyMatch(terminalRule.getName()::equals)) {
		                    	if (rc.eContainer().eContainer() instanceof ParserRule) {
		                    		ParserRule containerRule = (ParserRule)rc.eContainer().eContainer();
		                    		if (containerRule.getName().endsWith("Modifier")) {
				                    	acceptor.addPosition(node.getOffset(), node.getText().length(),
		    	                        HighlightingConfiguration.ATTRIBUTE_ID);
		    	                        continue;
		                    		}
		                    	}
		                    }

		                    if (Arrays.stream(operators).anyMatch(terminalRule.getName()::equals)) {
		                    	acceptor.addPosition(node.getOffset(), node.getText().length(),
	   	                        HighlightingConfiguration.OPERATOR_ID);
	   	                        continue;
		                    }

	                        if (Arrays.stream(constants).anyMatch(terminalRule.getName()::equals)) {
    	                    	acceptor.addPosition(node.getOffset(), node.getText().length(),
    	                        HighlightingConfiguration.CONSTANT_ID);
    	                        continue;
	                    	}
	                    	
	                    	if (Arrays.stream(features).anyMatch(terminalRule.getName()::equals)) {
		                    	acceptor.addPosition(node.getOffset(), node.getText().length(),
    	                        HighlightingConfiguration.FEATURE_ID);
    	                        continue;
	                    	}

	                    	if (Arrays.stream(attributes).anyMatch(terminalRule.getName()::equals)) {
		                    	acceptor.addPosition(node.getOffset(), node.getText().length(),
    	                        HighlightingConfiguration.ATTRIBUTE_ID);
    	                        continue;
	                    	}

	                    	acceptor.addPosition(node.getOffset(), node.getText().length(),
	                        HighlightingConfiguration.KEYWORD_ID);
	                        continue;
	                    }
	                    
	                    if (Arrays.stream(symbols).anyMatch(terminalRule.getName()::equals)) {
	                    	acceptor.addPosition(node.getOffset(), node.getText().length(),
   	                        HighlightingConfiguration.OPERATOR_ID);
   	                        continue;
	                    }
            		}
            	}

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
                    if (node.getSemanticElement() instanceof AnnotationMark) {
                        acceptor.addPosition(node.getOffset(), node.getParent().getLength(),
                        HighlightingConfiguration.ANNOTATION_ID);
                        continue;
                    }
                }
            }
        }
    }
}
