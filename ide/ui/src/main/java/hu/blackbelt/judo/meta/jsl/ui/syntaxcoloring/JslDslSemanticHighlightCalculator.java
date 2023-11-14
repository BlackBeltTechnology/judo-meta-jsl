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

import java.util.Set;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.Assignment;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.TerminalRule;
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor;
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator;
import org.eclipse.xtext.nodemodel.BidiTreeIterator;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.util.CancelIndicator;

import com.google.common.collect.Sets;

import hu.blackbelt.judo.meta.jsl.jsldsl.AnnotationMark;
import hu.blackbelt.judo.meta.jsl.jsldsl.Literal;

public class JslDslSemanticHighlightCalculator implements ISemanticHighlightingCalculator {
	static Set<String> symbols = Sets.newHashSet("SC", "BLOCK_START", "BLOCK_END",
			                   "LP", "RP", "DOT", "COMMA", "LB", "RB", "LRB", "ASSIGN", "LT", "GT", "QM", "COLON",
			                   "NEQ", "EQ", "GTE", "LTE", "MAP", "PLUS", "MINUS", "MUL", "DIV", "EXP", "EXCL", "PIPE");

	static Set<String> declarartions = Sets.newHashSet("KW_ABSTRACT", "KW_ACTOR", "KW_ANNOTATION", "KW_AS", "KW_ENTITY", "KW_ENUM", "KW_ERROR",
								 "KW_EXTENDS", "KW_FUNCTION", "KW_IMPORT", "KW_LAMBDA", "KW_MAPS", "KW_MODEL", "KW_ON",
								 "KW_QUERY", "KW_ROW", "KW_TRANSFER", "KW_TYPE", "KW_VIEW");
	
	static Set<String> operators = Sets.newHashSet("KW_NOT", "KW_IMPLIES", "KW_OR", "KW_XOR", "KW_AND", "KW_DIV", "KW_MOD");

	static Set<String> constants = Sets.newHashSet("KW_BINARY", "KW_BOOLEAN", "KW_BOTTOM", "KW_CENTER", "KW_COLLECTION", "KW_CONSTANT", "KW_DATE",
								 "KW_DECLARATION", "KW_FALSE", "KW_LEFT",
    							 "KW_NUMERIC", "KW_RIGHT", "KW_STRING", "KW_TIME", "KW_TIMESTAMP", "KW_TOP", "KW_TRUE", "KW_VOID",
    							 "KW_KB", "KW_MB", "KW_GB", "KW_KIB", "KW_MIB", "KW_GIB");

    static Set<String> features = Sets.newHashSet("KW_ACCESS", "KW_ACTION", "KW_AFTER", "KW_BEFORE", "KW_COLUMN", "KW_CONSTRAINT", "KW_EVENT",
    							"KW_FIELD", "KW_GROUP", "KW_HORIZONTAL", "KW_IDENTIFIER", "KW_INSTEAD", "KW_LINK", "KW_LITERAL",
    							"KW_MENU", "KW_RELATION", "KW_SUBMIT", "KW_TABLE", "KW_TABS", "KW_TEXT", "KW_THROWS", "KW_VERTICAL");

    static Set<String> attributes = Sets.newHashSet("KW_CHOICES", "KW_CLAIM", "KW_DEFAULT", "KW_DETAIL", "KW_EAGER", "KW_ENABLED", "KW_FRAME", "KW_GUARD", "KW_HIDDEN",
    							  "KW_INPUT", "KW_HALIGN", "KW_ICON", "KW_IDENTITY", "KW_LABEL", "KW_MAXFILESIZE", "KW_MAXSIZE", "KW_MINSIZE", "KW_MIMETYPE",
    							  "KW_OPPOSITE", "KW_OPPOSITEADD", "KW_PRECISION", "KW_REALM", "KW_REDIRECT", "KW_REGEX", "KW_REQUIRED", "KW_ROWS", "KW_SCALE",
    							  "KW_STRETCH", "KW_THROW", "KW_VALIGN", "KW_WIDTH");

    static Set<String> specials = Sets.newHashSet("KW_CREATE", "KW_DELETE", "KW_UPDATE");

    @Override
    public void provideHighlightingFor(XtextResource resource, IHighlightedPositionAcceptor acceptor, CancelIndicator cancelIndicator) {
        if (resource == null) return;

        BidiTreeIterator<INode> iterator = resource.getParseResult().getRootNode().getAsTreeIterable().iterator();
        
        while (iterator.hasNext()) {
        	INode node = iterator.next();

            if (node.getSemanticElement() instanceof Literal) {
                acceptor.addPosition(node.getOffset(), node.getLength(),
                HighlightingConfiguration.CONSTANT_ID);
                continue;
            }

        	if (node.getSemanticElement() instanceof AnnotationMark) {
                acceptor.addPosition(node.getOffset(), node.getParent().getLength(),
                HighlightingConfiguration.ANNOTATION_ID);
            	iterator.prune();
                continue;
            }

            EObject nodeGElem = node.getGrammarElement();
            
            if (nodeGElem instanceof TerminalRule) {
                switch (((TerminalRule)nodeGElem).getName()) {
                    case "SL_COMMENT":
                    case "ML_COMMENT":
                        acceptor.addPosition(node.getOffset(), node.getLength(),
                        HighlightingConfiguration.COMMENT_ID);
                        continue;
                }
            }

        	if (nodeGElem instanceof RuleCall) {
        		String ruleName = ((RuleCall)nodeGElem).getRule().getName();
        		
                if (ruleName.equals("JSLID")) {
        			// skip the rest of the tree
                	iterator.prune();
                	continue;
                }

                if (ruleName.equals("NUMBER")) {
        			// skip the rest of the tree
                    acceptor.addPosition(node.getOffset(), node.getLength(),
                    HighlightingConfiguration.CONSTANT_ID);
                    continue;
                }

            	if (symbols.contains(ruleName)) {
                	acceptor.addPosition(node.getOffset(), node.getLength(),
                        HighlightingConfiguration.OPERATOR_ID);
                        continue;
                }

            	if (ruleName.startsWith("KW_")) {
                	if (specials.contains(ruleName)) {
                    	if (nodeGElem.eContainer() instanceof Assignment) {
                    		Assignment assignment = (Assignment)nodeGElem.eContainer();
                    		if (assignment.getFeature().equals("type")) {
		                    	acceptor.addPosition(node.getOffset(), node.getLength(),
    	                        HighlightingConfiguration.ATTRIBUTE_ID);
    	                        continue;
                    		}
                    	}
                    }

                	if (operators.contains(ruleName)) {
                    	acceptor.addPosition(node.getOffset(), node.getLength(),
                        HighlightingConfiguration.OPERATOR_ID);
                        continue;
                    }

                	if (declarartions.contains(ruleName)) {
                    	acceptor.addPosition(node.getOffset(), node.getLength(),
                        HighlightingConfiguration.KEYWORD_ID);
                        continue;
                	}

                	if (constants.contains(ruleName)) {
                    	acceptor.addPosition(node.getOffset(), node.getLength(),
                        HighlightingConfiguration.CONSTANT_ID);
                        continue;
                	}
                	
                	if (features.contains(ruleName)) {
                    	acceptor.addPosition(node.getOffset(), node.getLength(),
                        HighlightingConfiguration.FEATURE_ID);
                        continue;
                	}

                	if (attributes.contains(ruleName)) {
                    	acceptor.addPosition(node.getOffset(), node.getLength(),
                        HighlightingConfiguration.ATTRIBUTE_ID);
                        continue;
                	}
            	}
        	}
        }
    }
}
