package hu.blackbelt.judo.meta.jsl.runtime;

import java.util.Arrays;

import hu.blackbelt.judo.meta.jsl.jsldsl.BinaryOperation;
import hu.blackbelt.judo.meta.jsl.jsldsl.BooleanLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.DataTypeDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.DateLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.DecimalLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDerivedDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityFieldDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityIdentifierDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityMemberDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityQueryDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeInjected;
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumLiteralReference;
import hu.blackbelt.judo.meta.jsl.jsldsl.EscapedStringLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.Expression;
import hu.blackbelt.judo.meta.jsl.jsldsl.Feature;
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionOrQueryCall;
import hu.blackbelt.judo.meta.jsl.jsldsl.IntegerLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaCall;
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaVariable;
import hu.blackbelt.judo.meta.jsl.jsldsl.MemberReference;
import hu.blackbelt.judo.meta.jsl.jsldsl.Navigation;
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationBaseDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationBaseDeclarationReference;
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationTarget;
import hu.blackbelt.judo.meta.jsl.jsldsl.ParenthesizedExpression;
import hu.blackbelt.judo.meta.jsl.jsldsl.PrimitiveDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryDeclarationParameter;
import hu.blackbelt.judo.meta.jsl.jsldsl.RawStringLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.SelfExpression;
import hu.blackbelt.judo.meta.jsl.jsldsl.SingleType;
import hu.blackbelt.judo.meta.jsl.jsldsl.TernaryOperation;
import hu.blackbelt.judo.meta.jsl.jsldsl.TimeLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.TimeStampLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.TypeDescription;
import hu.blackbelt.judo.meta.jsl.jsldsl.UnaryOperation;

import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension;

public class TypeInfo {
    private static JslDslModelExtension modelExtension = new JslDslModelExtension();
	
    // PrimitiveType is just for compatibility purpose
    public enum PrimitiveType {BOOLEAN, BINARY, STRING, NUMERIC, DATE, TIME, TIMESTAMP}
    
    private enum BaseType {BOOLEAN, BINARY, STRING, NUMERIC, DATE, TIME, TIMESTAMP, ENUM, ENTITY}

    private enum typeModifier {NONE, LITERAL, COLLECTION, DECLARATION}
    
    // private boolean isLiteral = false;
    // private boolean isCollection = false;
    //private boolean isDeclaration = false;
    private typeModifier modifier = typeModifier.NONE;
	private BaseType baseType;
	private SingleType type;

	public String toString() {
		String result = this.baseType.toString().toLowerCase();
		
		if (this.baseType == BaseType.ENUM) {
			result += "(" + ((EnumDeclaration)this.type).getName() + ")";
		} else if (this.baseType == BaseType.ENTITY) {
			result += "(" + ((EntityDeclaration)this.type).getName() + ")";
		}

		if (this.modifier != null ) {
			result += " " + this.modifier.toString().toLowerCase();
		}
		
		return result;
	}

	public void print() {
		System.out.println("BaseType:     " + this.baseType);
		System.out.println("type: " 		+ this.type);
	}
	
	private TypeInfo(BaseType baseType, boolean isLiteral) {
		if (baseType == BaseType.ENUM || baseType == BaseType.ENTITY) {
			throw new IllegalArgumentException("TypeInfo got illegal argument: " + baseType);
		}
		
		this.modifier = typeModifier.LITERAL;
		this.baseType = baseType;
	}

	private TypeInfo(TypeDescription typeDescription) {
		this.baseType = getBaseType(typeDescription);

		if (typeDescription.isLiteral()) {
			this.modifier = typeModifier.LITERAL;
		} else if (typeDescription.isDeclaration()) {
			this.modifier = typeModifier.DECLARATION;
		} else if (typeDescription.isCollection()) {
			this.modifier = typeModifier.COLLECTION;
		}
	}
	
	private static BaseType getBaseType(String type) {
		switch (type) {
			case "boolean":		return BaseType.BOOLEAN; 
			case "binary":		return BaseType.BINARY;
			case "string":		return BaseType.STRING;
			case "numeric":		return BaseType.NUMERIC;
			case "date":		return BaseType.DATE;
			case "time":		return BaseType.TIME;
			case "timestamp":	return BaseType.TIMESTAMP;
			case "enum":		return BaseType.ENUM;
			case "entity":		return BaseType.ENTITY;
		}

		throw new IllegalArgumentException("TypeInfo got illegal argument: " + type);
	}
	
	private static BaseType getBaseType(TypeDescription typeDescription) {
		BaseType baseType = getBaseType(typeDescription.getType());
		
		if (typeDescription.isCollection() && baseType !=  BaseType.ENTITY) {
			throw new IllegalArgumentException("TypeInfo got illegal argument: " + typeDescription);
		}

		return baseType;
	}

	private TypeInfo(SingleType type, boolean isCollection) {
		if (type instanceof DataTypeDeclaration) {
			this.type = type;
			this.baseType = getBaseType(((DataTypeDeclaration) type).getPrimitive());
			
			if (isCollection) {
				throw new IllegalArgumentException("DataTypeDeclaration is collection");
			}
		} else if (type instanceof EnumDeclaration) {
			this.type = type;
			this.baseType = BaseType.ENUM;

			if (isCollection) {
				throw new IllegalArgumentException("DataTypeDeclaration is collection");
			}
		} else if (type instanceof EntityDeclaration) {
			this.type = type;
			this.baseType = BaseType.ENTITY;
			this.modifier = isCollection ? typeModifier.COLLECTION : typeModifier.NONE;
		}
	}

	public boolean isEntity() {
		return this.baseType == BaseType.ENTITY;
	}

	public boolean isEnum() {
		return this.baseType == BaseType.ENUM;
	}

	public boolean isPrimitive() {
		return !this.isEntity() && !this.isDeclaration();
	}

	public boolean isDataType() {
		return this.isPrimitive() && !this.isEnum();
	}

	public boolean isBoolean() {
		return this.baseType == BaseType.BOOLEAN;
	}
	
	public boolean isBinary() {
		return this.baseType == BaseType.BINARY;
	}

	public boolean isNumeric() {
		return this.baseType == BaseType.NUMERIC;
	}

	public boolean isString() {
		return this.baseType == BaseType.STRING;
	}

	public boolean isDate() {
		return this.baseType == BaseType.DATE;
	}

	public boolean isTime() {
		return this.baseType == BaseType.TIME;
	}

	public boolean isTimestamp() {
		return this.baseType == BaseType.TIMESTAMP;
	}

	public boolean isCollection() {
		return this.modifier == typeModifier.COLLECTION;
	}

	public boolean isDeclaration() {
		return this.modifier == typeModifier.COLLECTION;
	}

	public boolean isLiteral() {
		return this.modifier == typeModifier.LITERAL;
	}

	public boolean isCompatible(TypeInfo other) {
		if (this.isCollection() ^ other.isCollection()) {
			return false;
		}
		
		if (this.isDeclaration() ^ other.isDeclaration()) {
			return false;
		}

		if (this.baseType == BaseType.ENUM && other.baseType == BaseType.ENUM) {
			return ((EnumDeclaration)this.type).equals(((EnumDeclaration)other.type));
		}
		
		if (this.baseType == BaseType.ENTITY && other.baseType == BaseType.ENTITY)
		{
			return this.type.equals(other.type) || modelExtension.getSuperEntityTypes((EntityDeclaration)other.type).contains((EntityDeclaration)this.type);
		}

		return this.baseType == other.baseType;
	}

	public PrimitiveType getPrimitive() {
		if (isEntity()) {
			throw new IllegalStateException("Type is entity");
		}

		// BOOLEAN, BINARY, STRING, NUMERIC, DATE, TIME, TIMESTAMP
		if (isBoolean()) return PrimitiveType.BOOLEAN;
		if (isBinary()) return PrimitiveType.BINARY;
		if (isString()) return PrimitiveType.STRING;
		if (isNumeric()) return PrimitiveType.NUMERIC;
		if (isDate()) return PrimitiveType.DATE;
		if (isTime()) return PrimitiveType.TIME;
		if (isTimestamp()) return PrimitiveType.TIMESTAMP;
		
		throw new IllegalStateException("Type is unknown");
	}

	public EntityDeclaration getEntity() {
		if (isPrimitive()) {
			throw new IllegalStateException("Type is primitive");
		}
		if (isDataType()) {
			throw new IllegalStateException("Type is data type");
		}
		return (EntityDeclaration) type;
	}

	public DataTypeDeclaration getDataType() {
		if (isEntity()) {
			throw new IllegalStateException("Type is entity");
		}
		return (DataTypeDeclaration) type;
	}

	public Object getType() {
		return type;
	}
		
	private static TypeInfo getTargetType(EnumLiteralReference enumReference) {
		TypeInfo typeInfo = new TypeInfo(enumReference.getEnumDeclaration(), false);
		typeInfo.modifier = typeModifier.LITERAL;
		return typeInfo;
	}
	
	private static TypeInfo getTargetType(BinaryOperation binaryOperation) {
		if (Arrays.asList("!=","==",">=","<=",">","<").contains(binaryOperation.getOperator())) {
			return new TypeInfo(BaseType.BOOLEAN, false); 
		}
		
		TypeInfo typeInfo = getTargetType(binaryOperation.getLeftOperand());
		
		return typeInfo;
	}

	/*
	private static TypeInfo getTargetType(LambdaVariable lambdaVariable) {
		FunctionCall functionCall = modelExtension.parentContainer(lambdaVariable, FunctionCall.class);
		
		while (functionCall.getFunction() instanceof LiteralFunction || !((LambdaFunction)functionCall.getFunction()).getLambdaArgument().getName().equals(lambdaVariable.getName())) {
			functionCall = modelExtension.parentContainer(functionCall, FunctionCall.class);			
		}
		
		TypeInfo typeInfo = getTargetType(modelExtension.parentContainer(functionCall, FunctionedExpression.class));
		typeInfo.isCollection = false;

		return typeInfo;
	}
	*/
	
	private static TypeInfo getTargetType(Feature feature) {		
		Navigation navigation = (Navigation) feature.eContainer();
		TypeInfo baseTypeInfo = getTargetType( navigation.getBase() );
		
		if (feature instanceof MemberReference) {
			TypeInfo typeInfo = getTargetType( ((MemberReference) feature).getMember() );
			typeInfo.modifier = typeInfo.modifier == typeModifier.COLLECTION ? typeModifier.COLLECTION : baseTypeInfo.modifier;
			return typeInfo;
		} else if (feature instanceof FunctionOrQueryCall) {
			FunctionOrQueryCall functionOrQueryCall = (FunctionOrQueryCall)feature;
			
			if (functionOrQueryCall.getDeclaration() instanceof EntityQueryDeclaration) {
				EntityQueryDeclaration entityQueryDeclaration = (EntityQueryDeclaration)functionOrQueryCall.getDeclaration();
				TypeInfo typeInfo = getTargetType(entityQueryDeclaration);
				typeInfo.modifier = typeInfo.modifier == typeModifier.COLLECTION ? typeModifier.COLLECTION : baseTypeInfo.modifier;
				return typeInfo;
			} else if (functionOrQueryCall.getDeclaration() instanceof FunctionDeclaration) {
				FunctionDeclaration functionDeclaration = (FunctionDeclaration)functionOrQueryCall.getDeclaration();
				baseTypeInfo.baseType = getBaseType( functionDeclaration.getReturnType() );
				return baseTypeInfo;
			}
			
		} else if (feature instanceof LambdaCall) {
			baseTypeInfo.baseType = getBaseType( ((LambdaCall) feature).getDeclaration().getReturnType() );
			return baseTypeInfo;
		}
		
		throw new IllegalArgumentException("Could not determinate feature return type: " + feature);
	}
	
	private static TypeInfo getTargetType(Navigation navigation) {
		if (navigation.getFeature() != null) {
			return getTargetType(navigation.getFeature());
		} else {
			return getTargetType(navigation.getBase());
		}
	}
	
	private static TypeInfo getTargetType(LambdaVariable lambdaVariable) {
		LambdaCall lambdaCall = modelExtension.parentContainer(lambdaVariable, LambdaCall.class);
		
		while (!lambdaCall.getVariable().getName().equals(lambdaVariable.getName())) {
			lambdaCall = modelExtension.parentContainer(lambdaCall, LambdaCall.class);			
		}
		
		TypeInfo typeInfo = getTargetType(lambdaCall);

		return typeInfo;
	}
	
	private static TypeInfo getTargetType(NavigationBaseDeclarationReference navigationBaseDeclarationReference) {
		TypeInfo typeInfo;
		NavigationBaseDeclaration navigationBaseReference = navigationBaseDeclarationReference.getReference();

		if (navigationBaseReference instanceof EntityDeclaration) {
			typeInfo = new TypeInfo((EntityDeclaration) navigationBaseReference, true);
		} else if (navigationBaseReference instanceof QueryDeclaration) {
			QueryDeclaration queryDeclaration = (QueryDeclaration)navigationBaseReference;
			typeInfo = new TypeInfo(queryDeclaration.getReferenceType(), queryDeclaration.isIsMany());
		} else if (navigationBaseReference instanceof LambdaVariable) {
			typeInfo = getTargetType((LambdaVariable) navigationBaseReference);
		} else if (navigationBaseReference instanceof QueryDeclarationParameter) {
			typeInfo = new TypeInfo( ((QueryDeclarationParameter) navigationBaseReference).getReferenceType(), false);
		} else if (navigationBaseReference instanceof PrimitiveDeclaration) {
			typeInfo = new TypeInfo((SingleType) navigationBaseReference, false);
		} else {
			throw new IllegalArgumentException("Could not determinate type for navigation base reference.");
		}

		return typeInfo;
	}
	
	private static TypeInfo getTargetType(SelfExpression selfExpression) {
		TypeInfo typeInfo = new TypeInfo(modelExtension.parentContainer(selfExpression, EntityDeclaration.class), false);
		return typeInfo;
	}
	
	private static TypeInfo getTargetType(NavigationTarget navigationTarget) {
		if (navigationTarget instanceof EntityMemberDeclaration) {
			return getTargetType((EntityMemberDeclaration)navigationTarget);
		} else if (navigationTarget instanceof EntityRelationOppositeInjected) {
			return new TypeInfo((EntityDeclaration) navigationTarget.eContainer().eContainer(), ((EntityRelationOppositeInjected) navigationTarget).isIsMany());
		}

		throw new IllegalArgumentException("Could not determinate type for navigation target:" + navigationTarget);
	}
	
	public static TypeInfo getTargetType(TypeDescription typeDescription) {
		return new TypeInfo(typeDescription);
	}
	
	public static TypeInfo getTargetType(EntityMemberDeclaration entityMemberDeclaration) {
		if (entityMemberDeclaration instanceof EntityFieldDeclaration) {
			EntityFieldDeclaration entityFieldDeclaration = (EntityFieldDeclaration)entityMemberDeclaration;
			return new TypeInfo(entityFieldDeclaration.getReferenceType(), entityFieldDeclaration.isIsMany());
		} else if (entityMemberDeclaration instanceof EntityIdentifierDeclaration) {
			EntityIdentifierDeclaration entityIdentifierDeclaration = (EntityIdentifierDeclaration)entityMemberDeclaration;
			return new TypeInfo(entityIdentifierDeclaration.getReferenceType(), false);
		} else if (entityMemberDeclaration instanceof EntityRelationDeclaration) {
			EntityRelationDeclaration entityRelationDeclaration = (EntityRelationDeclaration)entityMemberDeclaration;
			return new TypeInfo(entityRelationDeclaration.getReferenceType(), entityRelationDeclaration.isIsMany());
		} else if (entityMemberDeclaration instanceof EntityDerivedDeclaration) {
			EntityDerivedDeclaration entityDerivedDeclaration = (EntityDerivedDeclaration)entityMemberDeclaration;
			return new TypeInfo(entityDerivedDeclaration.getReferenceType(), entityDerivedDeclaration.isIsMany());
		} else if (entityMemberDeclaration instanceof EntityQueryDeclaration) {
			EntityQueryDeclaration entityQueryDeclaration = (EntityQueryDeclaration)entityMemberDeclaration;
			return new TypeInfo(entityQueryDeclaration.getReferenceType(), entityQueryDeclaration.isIsMany());
		}
		
		throw new IllegalArgumentException("Could not determinate type for entity member");
	}

	private static TypeInfo getTargetType(ParenthesizedExpression expression) {
		TypeInfo typeInfo = getTargetType( expression.getExpression() );
		typeInfo.modifier = typeInfo.modifier == typeModifier.LITERAL ? typeModifier.NONE : typeInfo.modifier;
		return typeInfo;
	}
	
	private static TypeInfo getTargetType(TernaryOperation expression) {
		TypeInfo typeInfo = getTargetType( expression.getThenExpression() );
		typeInfo.modifier = typeInfo.modifier == typeModifier.LITERAL ? typeModifier.NONE : typeInfo.modifier;
		return typeInfo;
	}

	public static TypeInfo getTargetType(Expression expression) {
		if (expression instanceof ParenthesizedExpression) {
			return getTargetType( (ParenthesizedExpression) expression );
		} else if (expression instanceof TernaryOperation) {
			return getTargetType( (TernaryOperation) expression );
		} else if (expression instanceof BinaryOperation) {
			return getTargetType( (BinaryOperation) expression);
		} else if (expression instanceof UnaryOperation) {
			return new TypeInfo(BaseType.BOOLEAN, false);
	
		} else if (expression instanceof Navigation) {
			return getTargetType( (Navigation) expression);
		} else if (expression instanceof SelfExpression) {
			return getTargetType( (SelfExpression) expression);
		} else if (expression instanceof NavigationBaseDeclarationReference) {
			return getTargetType( (NavigationBaseDeclarationReference) expression);
			
		} else if (expression instanceof IntegerLiteral) {
			return new TypeInfo(BaseType.NUMERIC, true);
		} else if (expression instanceof DecimalLiteral) {
			return new TypeInfo(BaseType.NUMERIC, true);
		} else if (expression instanceof BooleanLiteral) {
			return new TypeInfo(BaseType.BOOLEAN, true);
		} else if (expression instanceof EscapedStringLiteral) {
			return new TypeInfo(BaseType.STRING, true);
		} else if (expression instanceof RawStringLiteral) {
			return new TypeInfo(BaseType.STRING, true);
		} else if (expression instanceof DateLiteral) {
			return new TypeInfo(BaseType.DATE, true);
		} else if (expression instanceof TimeLiteral) {
			return new TypeInfo(BaseType.TIME, true);
		} else if (expression instanceof TimeStampLiteral) {
			return new TypeInfo(BaseType.TIMESTAMP, true);
		} else if (expression instanceof EnumLiteralReference) {
			return getTargetType( (EnumLiteralReference) expression);
		}
		
		throw new IllegalArgumentException("Could not determinate type for expression: " + expression);
	}
}