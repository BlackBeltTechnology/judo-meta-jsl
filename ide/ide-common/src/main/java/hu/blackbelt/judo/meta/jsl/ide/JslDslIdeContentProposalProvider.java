package hu.blackbelt.judo.meta.jsl.ide;

import com.google.common.collect.ImmutableSet;
import com.google.inject.Inject;

import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.Expression;
import hu.blackbelt.judo.meta.jsl.services.JslDslGrammarAccess;
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension;

import java.util.Set;

import org.eclipse.xtext.*;
import org.eclipse.xtext.ide.editor.contentassist.ContentAssistContext;
import org.eclipse.xtext.ide.editor.contentassist.IIdeContentProposalAcceptor;
import org.eclipse.xtext.ide.editor.contentassist.IdeContentProposalProvider;
import org.eclipse.xtext.xbase.lib.Extension;


public class JslDslIdeContentProposalProvider extends IdeContentProposalProvider {

  @Inject
  JslDslGrammarAccess grammarAccess;
	
  public static Set<TerminalRule> FILTERED_KEYWORDS;
  public static Set<TerminalRule> FILTERED_TERMINALS;

  @Inject
  @Extension
  JslDslModelExtension extension;
  
  @Override
  protected void _createProposals(RuleCall ruleCall, ContentAssistContext context,
                                  IIdeContentProposalAcceptor acceptor) {

	if (FILTERED_KEYWORDS == null) {
		FILTERED_KEYWORDS = ImmutableSet.<TerminalRule>builder()
				.add(grammarAccess.getKW_LAMBDARule())
				.add(grammarAccess.getKW_FUNCTIONRule())
				.build();
	}

	if (FILTERED_TERMINALS == null) {
		FILTERED_TERMINALS = ImmutableSet.<TerminalRule>builder()
				.add(grammarAccess.getBLOCK_STARTRule())
				.add(grammarAccess.getBLOCK_ENDRule())
				.add(grammarAccess.getSCRule())
				.add(grammarAccess.getLPRule())
				.add(grammarAccess.getRPRule())
				.add(grammarAccess.getPLUSRule())
				.add(grammarAccess.getMINUSRule())
				.add(grammarAccess.getMULRule())
				.add(grammarAccess.getDIVRule())
				.add(grammarAccess.getKW_ANDRule())
				.add(grammarAccess.getKW_DIVRule())
				.add(grammarAccess.getKW_IMPLIESRule())
				.add(grammarAccess.getKW_MODRule())
				.add(grammarAccess.getKW_ORRule())
				.add(grammarAccess.getKW_XORRule())
				.build();
	}
	  
    if (ruleCall.getRule() instanceof TerminalRule) {
      TerminalRule terminalRule = (TerminalRule) ruleCall.getRule();
      if (terminalRule.getAlternatives() instanceof Keyword) {
        Keyword keyword = (Keyword) terminalRule.getAlternatives();

        if (FILTERED_KEYWORDS.contains(terminalRule) || FILTERED_TERMINALS.contains(terminalRule)) {
            // don't propose keyword
            return;        	
          }

        if (keyword.getValue().equals("self") &&
        		extension.parentContainer(context.getCurrentNode().getSemanticElement(), Expression.class) != null &&
        				extension.parentContainer(context.getCurrentNode().getSemanticElement(), EntityDeclaration.class) == null) {
            // don't propose keyword
            return;
        }

        super._createProposals(keyword, context, acceptor);
      }
    }
  }
}
