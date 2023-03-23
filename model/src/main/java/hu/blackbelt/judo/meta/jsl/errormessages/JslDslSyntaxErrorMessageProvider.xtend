package hu.blackbelt.judo.meta.jsl.errormessages

import org.eclipse.xtext.parser.antlr.ISyntaxErrorMessageProvider
import org.eclipse.xtext.parser.antlr.ISyntaxErrorMessageProvider.IParserErrorContext
import org.eclipse.xtext.parser.antlr.ISyntaxErrorMessageProvider.IValueConverterErrorContext
import org.eclipse.xtext.conversion.ValueConverterWithValueException
import org.eclipse.xtext.nodemodel.SyntaxErrorMessage
import static org.eclipse.xtext.diagnostics.Diagnostic.SYNTAX_DIAGNOSTIC_WITH_RANGE
import static org.eclipse.xtext.diagnostics.Diagnostic.SYNTAX_DIAGNOSTIC

class JslDslSyntaxErrorMessageProvider implements ISyntaxErrorMessageProvider {

    override SyntaxErrorMessage getSyntaxErrorMessage(IParserErrorContext context) {
        return new SyntaxErrorMessage(context.getDefaultMessage(), SYNTAX_DIAGNOSTIC);
    }


    override SyntaxErrorMessage getSyntaxErrorMessage(IValueConverterErrorContext context) {
        val cause = context.getValueConverterException();
        if (cause instanceof ValueConverterWithValueException) {
            val casted = cause;
            if (casted.hasRange()) {
                return createRangedSyntaxErrorMessage(context, casted.getOffset(), casted.getLength());
            }
        }
        new SyntaxErrorMessage(context.getDefaultMessage(), SYNTAX_DIAGNOSTIC);
    }

    def SyntaxErrorMessage createRangedSyntaxErrorMessage(IValueConverterErrorContext context, int offset,
            int length) {
        val range = offset + ":" + length;
        new SyntaxErrorMessage(context.getDefaultMessage(), SYNTAX_DIAGNOSTIC_WITH_RANGE, #[ range ]);
    }

}
