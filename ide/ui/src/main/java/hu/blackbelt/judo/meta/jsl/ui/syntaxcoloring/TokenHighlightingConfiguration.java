package hu.blackbelt.judo.meta.jsl.ui.syntaxcoloring;

import java.util.Arrays;

import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultAntlrTokenToAttributeIdMapper;

import com.google.inject.Singleton;

@Singleton
public class TokenHighlightingConfiguration extends
        DefaultAntlrTokenToAttributeIdMapper {

    @Override
    protected String calculateId(String tokenName, int tokenType) {
    	String[] operators = {
    			"RULE_NL",
    			"'='",
    			"'+='",
    			"'-='",
    			"'<'",
    			"'>'",
    			"'?'",
    			"'!='",
    			"'=='",
    			"'>='",
    			"'<='",
    			"'+'",
    			"'-'",
    			"'*'",
    			"'/'",
    			"'^'",
    			"'!'",
    			"'|'"};

    	String[] commands = {
    			"'var'",
    			"'construct'",
    			"'destruct'",
    			"'save'",
    			"'load'",
    			"'if'",
    			"'else'",
    			"'for'",
    			"'in'",
    			"'while'",
    			"'validate'",
    			"'unset'",
    			"'delete'",
    			"'return'",
    			"'break'",
    			"'continue'",
    			"'new'",
    			"'implies'",
    			"'or'",
    			"'xor'",
    			"'and'",
    			"'div'",
    			"'mod'",
    			"'not'",
    			"'throw'",
    			"'try'",
    			"'catch'",
    			"'self'"};

    	String[] numConstants = {
    			"RULE_INTEGER",
    			"RULE_DECIMAL",
    			"RULE_DIGIT",
    			"'true'",
    			"'false'"};

    	String[] stringConstants = {
    			"RULE_STRING",
    			"RULE_RAW_STRING",
    			"RULE_MIME_TYPE",
    			"RULE_DATE",
    			"RULE_TIMESTAMP",
    			"RULE_TIME"};

    	String[] types = {
    			"'actor'",
    			"'username'",
    			"'principal'",
    			"'boolean'",
    			"'binary'",
    			"'string'",
    			"'numeric'",
    			"'date'",
    			"'time'",
    			"'timestamp'",
    			"'mapped'",
    			"'as'",
    			"'abstract'",
    			"'extends'",
    			"'model'",
    			"'annotate'",
    			"'diagram'",
    			"'entity'",
    			"'transfer'",
    			"'type'",
    			"'union'",
    			"'error'",
    			"'enum'"};

    	String[] features = {
    			"'authorize'",
    			"'stage'",
    			"'table'",
    			"'column'",
    			"'layout'",
    			"'constraint'",
    			"'field'",
    			"'identifier'",
    			"'derived'",
    			"'relation'",
    			"'action'",
    			"'static'",
    			"'throws'",
    			"'group'",
    			"'package'",
    			"'widget'"};

    	String[] parameters = {
    			"'void'",
    			"'override'",
    			"'onerror'",
    			"'class'",
    			"'horizontal'",
    			"'vertical'",
    			"'hide-attributes'",
    			"'hide-actions'",
    			"'hide-relations'",
    			"'expression'",
    			"'opposite'",
    			"'opposite-add'",
    			"'read-only'",
    			"'max-length'",
    			"'mime-types'",
    			"'max-file-size'",
    			"'regex'",
    			"'precision'",
    			"'required'",
    			"'cascade'",
    			"'scale'",
    			"'frame'",
    			"'label'",
    			"'icon'",
    			"'stretch-horizontal'",
    			"'stretch-vertical'",
    			"'stretch-both'",
    			"'width'",
    			"'height'"};

    	if (Arrays.stream(types).anyMatch(tokenName::equals)) {
            return HighlightingConfiguration.TYPE_ID;
        } else if (Arrays.stream(features).anyMatch(tokenName::equals)) {
        	return HighlightingConfiguration.FEATURE_ID;
        } else if (Arrays.stream(parameters).anyMatch(tokenName::equals)) {
            return HighlightingConfiguration.PARAMETER_ID;
        } else if (Arrays.stream(commands).anyMatch(tokenName::equals)) {
            return HighlightingConfiguration.COMMAND_ID;
        } else if (Arrays.stream(numConstants).anyMatch(tokenName::equals)) {
            return HighlightingConfiguration.NUM_CONSTANT_ID;
        } else if (Arrays.stream(stringConstants).anyMatch(tokenName::equals)) {
            return HighlightingConfiguration.STRING_CONSTANT_ID;
        } else if (Arrays.stream(operators).anyMatch(tokenName::equals)) {
            return HighlightingConfiguration.OPERATOR_ID;
        }
        
        return super.calculateId(tokenName, tokenType);
    }

}