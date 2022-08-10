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
import org.eclipse.xtext.ide.editor.syntaxcoloring.HighlightingStyles;
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfiguration;
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfigurationAcceptor;
import org.eclipse.xtext.ui.editor.utils.TextStyle;

public class HighlightingConfiguration implements IHighlightingConfiguration {
	
	public static final String KEYWORD_ID = HighlightingStyles.KEYWORD_ID;
	
	public static final String PUNCTUATION_ID = HighlightingStyles.PUNCTUATION_ID;

	public static final String COMMENT_ID = HighlightingStyles.COMMENT_ID;

	public static final String STRING_ID = HighlightingStyles.STRING_ID;

	public static final String NUMBER_ID = HighlightingStyles.NUMBER_ID;

	public static final String DEFAULT_ID = HighlightingStyles.DEFAULT_ID;

	public static final String INVALID_TOKEN_ID = HighlightingStyles.INVALID_TOKEN_ID;
	
	public final static String TYPE_ID = "Type";
	public final static String FEATURE_ID = "Feature";
	public final static String IDENTIFIER_ID = "ID";
	public final static String PARAMETER_ID = "Parameter";
	public final static String COMMAND_ID = "Command";
	public final static String NUM_CONSTANT_ID = "NumericConstant";
	public final static String STRING_CONSTANT_ID = "StringConstant";
	public final static String OPERATOR_ID = "Operator";

	public static final String TASK_ID = HighlightingStyles.TASK_ID;

	@Override
	public void configure(IHighlightingConfigurationAcceptor acceptor) {
		acceptor.acceptDefaultHighlighting(KEYWORD_ID, "Keyword", keywordTextStyle());
		
		acceptor.acceptDefaultHighlighting(TYPE_ID, "Type", typeTextStyle());
		acceptor.acceptDefaultHighlighting(FEATURE_ID, "Feature", featureTextStyle());
		acceptor.acceptDefaultHighlighting(IDENTIFIER_ID, "ID", identifierTextStyle());
		acceptor.acceptDefaultHighlighting(PARAMETER_ID, "Parameter", parameterTextStyle());
		acceptor.acceptDefaultHighlighting(COMMAND_ID, "Command", commandConstTextStyle());
		acceptor.acceptDefaultHighlighting(NUM_CONSTANT_ID, "NumericConstant", numConstTextStyle());
		acceptor.acceptDefaultHighlighting(STRING_CONSTANT_ID, "StringConstant", stringConstTextStyle());
		acceptor.acceptDefaultHighlighting(OPERATOR_ID, "Operator", operatorConstTextStyle());

		acceptor.acceptDefaultHighlighting(PUNCTUATION_ID, "Punctuation character", punctuationTextStyle());
		acceptor.acceptDefaultHighlighting(COMMENT_ID, "Comment", commentTextStyle());
		acceptor.acceptDefaultHighlighting(TASK_ID, "Task Tag", taskTextStyle());
		acceptor.acceptDefaultHighlighting(STRING_ID, "String", stringTextStyle());
		acceptor.acceptDefaultHighlighting(NUMBER_ID, "Number", numberTextStyle());
		acceptor.acceptDefaultHighlighting(DEFAULT_ID, "Default", defaultTextStyle());
		acceptor.acceptDefaultHighlighting(INVALID_TOKEN_ID, "Invalid Symbol", errorTextStyle());
	}
	
	public TextStyle defaultTextStyle() {
		TextStyle textStyle = new TextStyle();
		return textStyle;
	}
	
	public TextStyle errorTextStyle() {
		TextStyle textStyle = defaultTextStyle().copy();
		return textStyle;
	}
	
	public TextStyle numberTextStyle() {
		TextStyle textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(125, 125, 125));
		return textStyle;
	}

	public TextStyle stringTextStyle() {
		TextStyle textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(42, 0, 255));
		return textStyle;
	}

	public TextStyle taskTextStyle() {
		TextStyle textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(127, 159, 191));
		textStyle.setStyle(SWT.BOLD);
		return textStyle;
	}

	public TextStyle keywordTextStyle() {
		TextStyle textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(127, 0, 85));
		textStyle.setStyle(SWT.BOLD);
		return textStyle;
	}

	public TextStyle punctuationTextStyle() {
		TextStyle textStyle = defaultTextStyle().copy();
		return textStyle;
	}

	public TextStyle identifierTextStyle() {
		TextStyle textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(21, 101, 192));
		// textStyle.setStyle(SWT.BOLD);
		return textStyle;
	}

	public TextStyle commentTextStyle() {
		TextStyle textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(158, 158, 158));
		// textStyle.setStyle(SWT.BOLD);
		return textStyle;
	}

	public TextStyle parameterTextStyle() {
		TextStyle textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(156, 0, 176));
		// textStyle.setStyle(SWT.BOLD);
		return textStyle;
	}

	public TextStyle typeTextStyle() {
		TextStyle textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(156, 0, 176));
		textStyle.setStyle(SWT.BOLD);
		return textStyle;
	}

	public TextStyle featureTextStyle() {
		TextStyle textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(156, 0, 176));
		// textStyle.setStyle(SWT.BOLD);
		return textStyle;
	}

	public TextStyle numConstTextStyle() {
		TextStyle textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(192, 57, 43));
		// textStyle.setStyle(SWT.BOLD);
		return textStyle;
	}

	public TextStyle stringConstTextStyle() {
		TextStyle textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(168, 96, 26));
		// textStyle.setStyle(SWT.BOLD);
		return textStyle;
	}
	
	public TextStyle commandConstTextStyle() {
		TextStyle textStyle = defaultTextStyle().copy();
		// textStyle.setColor(new RGB(156, 0, 176));
		textStyle.setColor(new RGB(21, 101, 192));
		// textStyle.setStyle(SWT.BOLD);
		return textStyle;
	}
	
	public TextStyle operatorConstTextStyle() {
		TextStyle textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(21, 101, 192));
		textStyle.setStyle(SWT.BOLD);
		return textStyle;
	}
}
