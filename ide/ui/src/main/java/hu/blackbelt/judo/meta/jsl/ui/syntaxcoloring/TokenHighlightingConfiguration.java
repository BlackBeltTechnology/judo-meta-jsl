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

import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultAntlrTokenToAttributeIdMapper;

import com.google.inject.Singleton;

@Singleton
public class TokenHighlightingConfiguration extends
        DefaultAntlrTokenToAttributeIdMapper {

    static String[] operators = {
            "RULE_SC",
            "'('",
            "')'",
            "'{'",
            "'}'",
            "'.'",
            "','",
            "'::'",
            "'['",
            "']'",
            "'[]'",
            "'='",
            "'<'",
            "'>'",
            "'?'",
            "':'",
            "'!='",
            "'=='",
            "'>='",
            "'<='",
            "'=>'",
            "'+'",
            "'-'",
            "'*'",
            "'/'",
            "'^'",
            "'!'",
            "'|'",
            "'implies'",
            "'or'",
            "'xor'",
            "'and'",
            "'div'",
            "'mod'",
            "'not'"
    };

    @Override
    protected String calculateId(String tokenName, int tokenType) {
        if (Arrays.stream(operators).anyMatch(tokenName::equals)) {
            return HighlightingConfiguration.OPERATOR_ID;
        }

        return HighlightingConfiguration.DEFAULT_ID;
    }

}
