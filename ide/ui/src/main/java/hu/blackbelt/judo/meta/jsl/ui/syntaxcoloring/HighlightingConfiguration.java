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

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfiguration;
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfigurationAcceptor;
import org.eclipse.xtext.ui.editor.utils.TextStyle;

public class HighlightingConfiguration implements IHighlightingConfiguration {

    public static final String DEFAULT_ID = "Default";

    public static final String KEYWORD_ID = "Keyword";

    public final static String FEATURE_ID = "Feature";

    public final static String ATTRIBUTE_ID = "Attribute";

    public final static String OPERATOR_ID = "Operator";

    public final static String CONSTANT_ID = "Constant";

    public static final String COMMENT_ID = "Comment";

    public static final String ANNOTATION_ID = "Annotation";

    @Override
    public void configure(IHighlightingConfigurationAcceptor acceptor) {
        acceptor.acceptDefaultHighlighting(DEFAULT_ID, "Default", defaultTextStyle());
        acceptor.acceptDefaultHighlighting(KEYWORD_ID, "Keyword", keywordTextStyle());
        acceptor.acceptDefaultHighlighting(FEATURE_ID, "Feature", featureTextStyle());
        acceptor.acceptDefaultHighlighting(ATTRIBUTE_ID, "Attribute", attributeTextStyle());
        acceptor.acceptDefaultHighlighting(OPERATOR_ID, "Operator", operatorTextStyle());
        acceptor.acceptDefaultHighlighting(CONSTANT_ID, "Constant", constantTextStyle());
        acceptor.acceptDefaultHighlighting(COMMENT_ID, "Comment", commentTextStyle());
        acceptor.acceptDefaultHighlighting(ANNOTATION_ID, "Annotation", annotationTextStyle());
    }

    
    public TextStyle defaultTextStyle() {
        TextStyle textStyle = new TextStyle();
        return textStyle;
    }

    public TextStyle keywordTextStyle() {
        TextStyle textStyle = defaultTextStyle().copy();
        textStyle.setColor(new RGB(0x87, 0x00, 0x5f));
        textStyle.setStyle(SWT.BOLD);
        return textStyle;
    }

    public TextStyle featureTextStyle() {
        TextStyle textStyle = defaultTextStyle().copy();
        textStyle.setColor(new RGB(0x87, 0x00, 0x5f));
        return textStyle;
    }

    public TextStyle attributeTextStyle() {
        TextStyle textStyle = defaultTextStyle().copy();
        textStyle.setColor(new RGB(0x00, 0x57, 0x46));
        return textStyle;
    }

    public TextStyle operatorTextStyle() {
        TextStyle textStyle = defaultTextStyle().copy();
        textStyle.setColor(new RGB(0x1a, 0x6d, 0xc3));
        textStyle.setStyle(SWT.BOLD);
        return textStyle;
    }

    public TextStyle constantTextStyle() {
        TextStyle textStyle = defaultTextStyle().copy();
        textStyle.setColor(new RGB(0xcf, 0x43, 0x15));
        return textStyle;
    }

    public TextStyle commentTextStyle() {
        TextStyle textStyle = defaultTextStyle().copy();
        textStyle.setColor(new RGB(0x8c, 0x8c, 0x8c));
        textStyle.setStyle(SWT.ITALIC);
        return textStyle;
    }

    public TextStyle annotationTextStyle() {
        TextStyle textStyle = defaultTextStyle().copy();
        textStyle.setColor(new RGB(0x64, 0x64, 0x64));
        return textStyle;
    }
}
