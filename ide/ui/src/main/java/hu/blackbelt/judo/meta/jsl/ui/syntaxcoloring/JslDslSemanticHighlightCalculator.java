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

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.Keyword;
import org.eclipse.xtext.ParserRule;
import org.eclipse.xtext.TerminalRule;
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor;
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.util.CancelIndicator;

import hu.blackbelt.judo.meta.jsl.jsldsl.AnnotationMark;
import hu.blackbelt.judo.meta.jsl.jsldsl.Literal;

public class JslDslSemanticHighlightCalculator implements ISemanticHighlightingCalculator {

    @Override
    public void provideHighlightingFor(XtextResource resource, IHighlightedPositionAcceptor acceptor, CancelIndicator cancelIndicator) {
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

                    if (node.getSemanticElement() instanceof AnnotationMark) {
                        acceptor.addPosition(node.getOffset(), node.getParent().getLength(),
                                HighlightingConfiguration.ANNOTATION_ID);
                        continue;
                    }

                    if (keyword.eContainer() instanceof ParserRule) {
                        ParserRule parserRule = (ParserRule) keyword.eContainer();

                        if (parserRule.getName().startsWith("KW_")) {
	                        acceptor.addPosition(node.getOffset(), node.getText().length(),
	                        HighlightingConfiguration.KEYWORD_ID);
	                        continue;
                        }

                        if (parserRule.getName().startsWith("FEAT_")) {
	                        acceptor.addPosition(node.getOffset(), node.getText().length(),
	                        HighlightingConfiguration.FEATURE_ID);
	                        continue;
                        }

                        if (parserRule.getName().startsWith("ATTR_")) {
	                        acceptor.addPosition(node.getOffset(), node.getText().length(),
	                        HighlightingConfiguration.ATTRIBUTE_ID);
	                        continue;
                        }

                        if (parserRule.getName().startsWith("CONST_")) {
	                        acceptor.addPosition(node.getOffset(), node.getText().length(),
	                        HighlightingConfiguration.CONSTANT_ID);
	                        continue;
                        }
                    }
                }
            }
        }
    }
}
