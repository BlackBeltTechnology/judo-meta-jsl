/*
 * generated by Xtext 2.18.0
 */
package hu.blackbelt.judo.meta.jsl.formatting2

import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.jsldsl.BinaryOperation
import hu.blackbelt.judo.meta.jsl.jsldsl.TernaryOperation
import hu.blackbelt.judo.meta.jsl.services.JslDslGrammarAccess
import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.IFormattableDocument

class JslDslFormatter extends AbstractFormatter2 {
	
	@Inject extension JslDslGrammarAccess

	def dispatch void format(TernaryOperation ternaryOperation, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		ternaryOperation.thenExpression.format
		ternaryOperation.elseExpression.format
		ternaryOperation.condition.format
	}

	def dispatch void format(BinaryOperation binaryOperation, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		binaryOperation.rightOperand.format
		binaryOperation.leftOperand.format
	}
		// TODO: implement for UnaryOperation, JslExpression, FunctionCall, FunctionParameter, MeasuredLiteral, EnumLiteral, NavigationExpression, Feature
}
