package hu.blackbelt.judo.meta.jsl.util

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
import hu.blackbelt.judo.meta.jsl.jsldsl.CreateExpression
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionedExpression
import hu.blackbelt.judo.meta.jsl.jsldsl.TernaryOperation
import hu.blackbelt.judo.meta.jsl.jsldsl.BinaryOperation
import hu.blackbelt.judo.meta.jsl.jsldsl.SpawnOperation
import hu.blackbelt.judo.meta.jsl.jsldsl.UnaryOperation
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationExpression
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionCall
import hu.blackbelt.judo.meta.jsl.jsldsl.Feature
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryParameter
import hu.blackbelt.judo.meta.jsl.jsldsl.Function
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionParameter
import hu.blackbelt.judo.meta.jsl.jsldsl.ParenthesizedExpression

class JslExpressionToJqlExpression {

	/*
	Expression returns Expression hidden(WS, CONT_NL, SL_COMMENT, ML_COMMENT)
		: SwitchExpression
		;
	
	*/
	def static String getJql(Expression it) { getJqlDispacher }
 
	/*
	// right associative rule
	SwitchExpression returns Expression
		: ImpliesExpression (=> ({TernaryOperation.condition=current} '?')
		  thenExpression=SwitchExpression ':'
	      elseExpression=SwitchExpression)?
	    ;
	*/
	static def dispatch String getJqlDispacher(TernaryOperation it) {
		it !== null 
			? it.condition.jql + '?' + it.thenExpression.jql + ':' + it.elseExpression.jql 
			: null
	}


	/*
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
	*/

	static def dispatch String getJqlDispacher(BinaryOperation it) {
		it !== null 
			? it.leftOperand.jql + it.operator + it.rightOperand.jql 
			: null
	}

	/*
	SpawnOperation returns Expression
		: UnaryOperation (=> ({SpawnOperation.operand=current} 'as' type=LocalName))?
		;
	*/
	static def dispatch String getJqlDispacher(SpawnOperation it) {
		it !== null 
			? it.operand.jql + ' as ' + it.type 
			: null
	}


	/*
	UnaryOperation returns Expression
		: {UnaryOperation} operator=('not' | '-') operand=FunctionedExpression
	    | FunctionedExpression
	    ;
	*/	
	static def dispatch String getJqlDispacher(UnaryOperation it) {
		it !== null 
			? it.operator + it.operand.jql 
			: null
	}

	/*
	FunctionedExpression returns Expression
		: NavigationExpression ({FunctionedExpression.operand=current} functionCall=FunctionCall)?
		;
	*/
	static def dispatch String getJqlDispacher(FunctionedExpression it) {
		it !== null 
			? it.operand.jql + it.functionCall.jql 
			: null
	}


	/*
	NavigationExpression returns Expression
		: PrimaryExpression ({NavigationExpression.base=current} features+=Feature+)?
	    | NavigationBase
	    ;
	// enums as separate literals cause problems with completion and script
	NavigationBase returns NavigationExpression
		: {NavigationExpression} qName=LocalName (features+=Feature* | '#' enumValue = ID)
		;

	*/
	static def dispatch String getJqlDispacher(NavigationExpression it) {
		it !== null 
			? it.base !== null 
				? it.base.jql + it.features.map[Feature p | p.jql].join() 
				: it.QName + (it.enumValue !== null 
					? "#" + it.enumValue 
					: it.features.map[Feature p | p.jql].join())
			: ""
	}


	/*
	FunctionCall
		: {FunctionCall} '!' function=Function features+=Feature* call=FunctionCall?
		;
	*/ 
	static def String getJql(FunctionCall it) {
		it !== null 
			? '!' + it.function.jql + 
				(
					it.call !== null 
						? it.call.jql 
						: ""
				) 
			: null
	}

	/*
	Feature
		: {Feature} '.' name=ID ('(' parameters+=QueryParameter (',' parameters+=QueryParameter)* ')')?
		;
	*/
	static def String getJql(Feature it) {
		it !== null 
			? '.' + it.name + 
				(
					it.parameters.size > 0 
						? "(" +  it.parameters.map[p | p.jql].join(", ") + ")" 
						: ""
				) 
			: null
	}


	/*
	QueryParameter
		: name = ID '=' expression=Expression
		;
	*/
	static def String getJql(QueryParameter it) {
		it !== null 
			? it.name + "=" + it.expression.jql 
			: null
	}

	/*
	ParenthesizedExpression returns Expression
		: '(' Expression ')'
		;
		*/
		
	static def dispatch String getJqlDispacher(ParenthesizedExpression it) {
		it !== null 
			?  "(" + it.expression.jql + ")" 
			: null
	}
	
	/*
	PrimaryExpression returns Expression
		: ParenthesizedExpression
		| CreateExpression
		| Literal
		| Self
		;
	*/


	/*
	// Warning: create statement is not allowed in getter!
	CreateExpression returns Expression
		: {CreateExpression} 'new'? type=[ClassDeclaration]
		  (   '(' (assignments+=CreateParameter (',' assignments+=CreateParameter)*)? ')'
		  	| '[' (creates += Expression (',' creates += Expression)*)? ']'
		  )
		;
	
	CreateParameter:
	    name=ID '=' right=Expression;
	*/
	// TODO: Implement
	static dispatch def String getJqlDispacher(CreateExpression it) {
		it !== null 
			?  "" 
			: null
	}


	/*
	Function returns Function
		: name=ID '(' (lambdaArgument=ID '|')? (parameters+=FunctionParameter (',' parameters+=FunctionParameter)*)? ')'
	    ;
	*/
	static def String getJql(Function it) {
		it !== null 
			? it.name + '(' + 
				(
					it.lambdaArgument !== null 
						? it.lambdaArgument + "|" 
						: ""
				) + it.parameters.map[p | p.jql].join(",") + ")" 
			: null
	}

	/*
	FunctionParameter
		: {FunctionParameter} expression=Expression
		;
	*/
	static def String getJql(FunctionParameter it) {
		it !== null 
			? it.expression.jql 
			: null
	}

	/*
	Literal returns Expression
		: BooleanLiteral
		| NumberLiteral
		| StringLiteral
		| TemporalLiteral
		;
	
	BooleanLiteral returns Expression
		: {BooleanLiteral} ('false' | isTrue?='true')
		;
	
	NumberLiteral returns Expression
		: {IntegerLiteral} value=INTEGER
		| {DecimalLiteral} value=DECIMAL
		;
	
	StringLiteral returns Expression
		: {EscapedStringLiteral} value=STRING
		| {RawStringLiteral} value=RAW_STRING
		;
	
	TemporalLiteral returns Expression
		: {DateLiteral} value=DATE
		| {TimeStampLiteral} value=TIMESTAMP
		| {TimeLiteral} value=TIME
		;
	*/
	static dispatch def String getJqlDispacher(DateLiteral it) {
		it !== null 
			? it.value 
			: null
	}

	static dispatch def String getJqlDispacher(TimeStampLiteral it) {
		it !== null 
			? it.value 
			: null
	}

	static dispatch def String getJqlDispacher(TimeLiteral it) {
		it !== null 
			? it.value 
			: null
	}

	// TODO: Escaping
	static dispatch def String getJqlDispacher(RawStringLiteral it) {
		it !== null 
			? "\"" + it.value + "\"" 
			: null
	}

	static dispatch def String getJqlDispacher(EscapedStringLiteral it) {
		it !== null 
			? "\"" + it.value + "\"" 
			: null
	}

	static dispatch def String getJqlDispacher(DecimalLiteral it) {
		it !== null 
			? it.value.toString 
			: null
	}

	static dispatch def String getJqlDispacher(IntegerLiteral it) {
		it !== null 
			? it.value.toString 
			: null
	}

	static dispatch def String getJqlDispacher(BooleanLiteral it) {
		it !== null 
			? it.isIsTrue.toString 
			: null
	}


	/*
	Self returns Expression
		: {Self} 'self'
		;
	 
	*/
	static dispatch def String getJqlDispacher(Self it) {
		it !== null 
			?  "self" 
			: null
	}
	
}