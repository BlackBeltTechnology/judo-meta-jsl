package hu.blackbelt.judo.meta.jsl.util

import hu.blackbelt.judo.meta.jsl.services.JslDslGrammarAccess.SelfElements
import hu.blackbelt.judo.meta.jsl.jsldsl.Expression
import hu.blackbelt.judo.meta.jsl.jsldsl.Self
import hu.blackbelt.judo.meta.jsl.jsldsl.DateLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.TimeStampLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.TimeLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.RawStringLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.EscapedStringLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.DecimalLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.IntegerLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.BooleanLiteral

class JslExpressionToJqlExpression {
	/*
	def ModelDeclaration modelDeclaration(EObject obj) {
		var current = obj
		
		while (current.eContainer !== null) {
			current = current.eContainer
		}
		
		if (current instanceof ModelDeclaration) {
			current as ModelDeclaration
		} else {
			throw new IllegalAccessException("The root container is not ModelDeclaration: " + obj)
		}		
	} */
	
	/*

Expression returns Expression hidden(WS, CONT_NL, SL_COMMENT, ML_COMMENT)
	: SwitchExpression
	;

// right associative rule
SwitchExpression returns Expression
	: ImpliesExpression (=> ({TernaryOperation.condition=current} '?')
	  thenExpression=SwitchExpression ':'
      elseExpression=SwitchExpression)?
    ;

ImpliesExpression returns Expression
	: OrExpression (=> ({BinaryOperation.leftOperand=current} operator='implies') rightOperand=OrExpression)*
	;

OrExpression returns Expression
	: XorExpression (=> ({BinaryOperation.leftOperand=current} operator='or') rightOperand=XorExpression)*
	;

XorExpression returns Expression
	: AndExpression (=> ({BinaryOperation.leftOperand=current} operator='xor') rightOperand=AndExpression)*
	;

AndExpression returns Expression
	: EqualityExpression (=> ({BinaryOperation.leftOperand=current} operator='and') rightOperand=EqualityExpression)*
	;

EqualityExpression returns Expression
	: RelationalExpression (=> ({BinaryOperation.leftOperand=current} operator=('!='|'==')) rightOperand=RelationalExpression)*
	;

RelationalExpression returns Expression
	: AdditiveExpression (=> ({BinaryOperation.leftOperand=current} operator=('>=' | '<=' | '>' | '<')) rightOperand=AdditiveExpression)*
	;

AdditiveExpression returns Expression
	: MultiplicativeExpression (=> ({BinaryOperation.leftOperand=current} operator=('+'|'-')) rightOperand=MultiplicativeExpression)*
	;

MultiplicativeExpression returns Expression
	: ExponentExpression (=> ({BinaryOperation.leftOperand=current} operator=('*' | '/' | 'div' | 'mod')) rightOperand=ExponentExpression)*
	;

ExponentExpression returns Expression
	: SpawnOperation (=> ({BinaryOperation.leftOperand=current} operator='^') rightOperand=SpawnOperation)*
	;

SpawnOperation returns Expression
	: UnaryOperation (=> ({SpawnOperation.operand=current} 'as' type=LocalName))?
	;

UnaryOperation returns Expression
	: {UnaryOperation} operator=('not' | '-') operand=FunctionedExpression
    | FunctionedExpression
    ;

FunctionedExpression returns Expression
	: NavigationExpression ({FunctionedExpression.operand=current} functionCall=FunctionCall)?
	;

NavigationExpression returns Expression
	: PrimaryExpression ({NavigationExpression.base=current} features+=Feature+)?
    | NavigationBase
    ;

// enums as separate literals cause problems with completion and script
NavigationBase returns NavigationExpression
	: {NavigationExpression} qName=LocalName (features+=Feature* | '#' enumValue = ID)
	;

FunctionCall
	: {FunctionCall} '!' function=Function features+=Feature* call=FunctionCall?
	;

Feature
	: {Feature} '.' name=ID ('(' parameters+=QueryParameter (',' parameters+=QueryParameter)* ')')?
	;

QueryParameter
	: name = ID '=' expression=Expression
	;

ParenthesizedExpression returns Expression
	: '(' Expression ')'
	;

PrimaryExpression returns Expression
	: ParenthesizedExpression
	| CreateExpression
	| Literal
	| Self
	;

// Warning: create statement is not allowed in getter!

CreateExpression returns Expression
	: {CreateExpression} 'new'? type=[ClassDeclaration]
	  (   '(' (assignments+=CreateParameter (',' assignments+=CreateParameter)*)? ')'
	  	| '[' (creates += Expression (',' creates += Expression)*)? ']'
	  )
	;

CreateParameter:
    name=ID '=' right=Expression;

Function returns Function
	: name=ID '(' (lambdaArgument=ID '|')? (parameters+=FunctionParameter (',' parameters+=FunctionParameter)*)? ')'
    ;

FunctionParameter
	: {FunctionParameter} expression=Expression
	;




	 */
	 
/*	 
	NavigationExpression
	TernaryOperation
	BinaryOperation
	SpawnOperation
	UnaryOperation
	FunctionedExpression
	CreateExpression
*/
	
//	def String getJql(Expression o) {
//		o.
//	}
	
	def String getJql(Self o) {
		return "self";
	}

	def String getJql(DateLiteral o) {
		return o.value;
	}

	def String getJql(TimeStampLiteral o) {
		return o.value;
	}

	def String getJql(TimeLiteral o) {
		return o.value;
	}

	// TODO: Escaping
	def String getJql(RawStringLiteral o) {
		return o.value;			
	}

	def String getJql(EscapedStringLiteral o) {
		return o.value;			
	}

	def String getJql(DecimalLiteral o) {
		return o.value.toString	
	}

	def String getJql(IntegerLiteral o) {
		return o.value.toString	
	}

	def String getJql(BooleanLiteral o) {
		return o.isIsTrue.toString
	}
	
}