package hu.blackbelt.judo.meta.jsl.runtime;

import java.util.Arrays;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.util.EcoreUtil;

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
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityQueryCall;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityQueryDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeInjected;
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumLiteralReference;
import hu.blackbelt.judo.meta.jsl.jsldsl.EscapedStringLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.Expression;
import hu.blackbelt.judo.meta.jsl.jsldsl.Feature;
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionArgument;
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionCall;
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.IntegerLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage;
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaCall;
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaVariable;
import hu.blackbelt.judo.meta.jsl.jsldsl.Literal;
import hu.blackbelt.judo.meta.jsl.jsldsl.MemberReference;
import hu.blackbelt.judo.meta.jsl.jsldsl.Navigation;
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationBase;
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationBaseDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationBaseDeclarationReference;
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationTarget;
import hu.blackbelt.judo.meta.jsl.jsldsl.Parentheses;
import hu.blackbelt.judo.meta.jsl.jsldsl.PrimitiveDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryCall;
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryDeclarationParameter;
import hu.blackbelt.judo.meta.jsl.jsldsl.RawStringLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.Self;
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

    private enum TypeModifier {NONE, CONSTANT, COLLECTION, DECLARATION}
    
    // private boolean isLiteral = false;
    // private boolean isCollection = false;
    //private boolean isDeclaration = false;
    private TypeModifier modifier = TypeModifier.NONE;
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
		
		this.modifier = isLiteral ? TypeModifier.CONSTANT : TypeModifier.NONE;
		this.baseType = baseType;
	}

	private TypeInfo(TypeDescription typeDescription) {
		this.baseType = getBaseType(typeDescription);

		if (typeDescription.isConstant()) {
			this.modifier = TypeModifier.CONSTANT;
		} else if (typeDescription.isDeclaration()) {
			this.modifier = TypeModifier.DECLARATION;
		} else if (typeDescription.isCollection()) {
			this.modifier = TypeModifier.COLLECTION;
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
		if (typeDescription == null) {
			throw new IllegalArgumentException("TypeInfo got illegal argument: " + typeDescription);
		}
		
		BaseType baseType = getBaseType(typeDescription.getType());
		
		if (typeDescription.isCollection() && baseType !=  BaseType.ENTITY) {
			throw new IllegalArgumentException("TypeInfo got illegal argument: " + typeDescription);
		}

		return baseType;
	}

	private TypeInfo(SingleType type, boolean isCollection, boolean isDeclarartion) {
		this.modifier = isDeclarartion ? TypeModifier.DECLARATION : this.modifier;

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
			this.modifier = isCollection ? TypeModifier.COLLECTION : this.modifier;
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
		return this.modifier == TypeModifier.COLLECTION;
	}

	public boolean isDeclaration() {
		return this.modifier == TypeModifier.DECLARATION;
	}

	public boolean isConstant() {
		return this.modifier == TypeModifier.CONSTANT;
	}

	public boolean isBaseCompatible(TypeInfo other) {
		if (this.isCollection() ^ other.isCollection()) {
			return false;
		}
		
		if (this.isDeclaration() ^ other.isDeclaration()) {
			return false;
		}

		return this.baseType == other.baseType;
	}
	
	public boolean isCompatible(TypeInfo other) {
		if (this.isCollection() ^ other.isCollection()) {
			return false;
		}
		
		if (this.isDeclaration() ^ other.isDeclaration()) {
			return false;
		}

		if (this.baseType == BaseType.ENUM && other.baseType == BaseType.ENUM) {
			return  EcoreUtil.equals(this.type, other.type);
		}
		
		if (this.baseType == BaseType.ENTITY && other.baseType == BaseType.ENTITY)
		{
			return EcoreUtil.equals(this.type, other.type) || modelExtension.getSuperEntityTypes((EntityDeclaration)other.type).stream().anyMatch(e -> EcoreUtil.equals(e, this.type));
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
		TypeInfo typeInfo = new TypeInfo(enumReference.getEnumDeclaration(), false, false);
		typeInfo.modifier = TypeModifier.CONSTANT;
		return typeInfo;
	}
	
	private static TypeInfo getTargetType(BinaryOperation binaryOperation) {
		if (Arrays.asList("!=","==",">=","<=",">","<").contains(binaryOperation.getOperator())) {
			return new TypeInfo(BaseType.BOOLEAN, false); 
		}
		
		TypeInfo typeInfo = getTargetType(binaryOperation.getLeftOperand());
		typeInfo.modifier = typeInfo.modifier == TypeModifier.CONSTANT ? TypeModifier.NONE : typeInfo.modifier;
		
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
	
	private static boolean isResolvedReference(EObject object, int featureID) {
		EObject featureObject = (EObject) object.eGet(object.eClass().getEStructuralFeature(featureID), false);
		return !featureObject.eIsProxy();
	}
	
	public static TypeInfo getTargetType(Feature feature) {
		TypeInfo baseTypeInfo;
		Navigation navigation = (Navigation) feature.eContainer();

		int index = navigation.getFeatures().indexOf(feature);
		
		if (index > 0) {
			baseTypeInfo = getTargetType( navigation.getFeatures().get(index - 1) );
		} else {
			baseTypeInfo = getTargetType( navigation.getBase() );
		}

		baseTypeInfo.modifier = baseTypeInfo.modifier == TypeModifier.CONSTANT ? TypeModifier.NONE : baseTypeInfo.modifier;
			
		if (feature instanceof MemberReference) {
			// System.out.println("MemberReference:"+feature.eGet(feature.eClass().getEStructuralFeature(JsldslPackage.MEMBER_REFERENCE__MEMBER), false));
			if (!isResolvedReference(feature, JsldslPackage.MEMBER_REFERENCE__MEMBER)) {
				return baseTypeInfo;
			}
			TypeInfo typeInfo = getTargetType( ((MemberReference) feature).getMember() );
			typeInfo.modifier = typeInfo.modifier == TypeModifier.COLLECTION ? TypeModifier.COLLECTION : baseTypeInfo.modifier;
			return typeInfo;
		} else if (feature instanceof EntityQueryCall) {
			if (!isResolvedReference(feature, JsldslPackage.ENTITY_QUERY_CALL__DECLARATION)) {
				return baseTypeInfo;
			}
			TypeInfo typeInfo = getTargetType( ((EntityQueryCall)feature).getDeclaration() );
			typeInfo.modifier = typeInfo.modifier == TypeModifier.COLLECTION ? TypeModifier.COLLECTION : baseTypeInfo.modifier;
			return typeInfo;
		
		} else if (feature instanceof FunctionCall) {
			if (!isResolvedReference(feature, JsldslPackage.FUNCTION_CALL__DECLARATION)) {
				return baseTypeInfo;
			}
			FunctionCall functionCall = (FunctionCall)feature;
			FunctionDeclaration functionDeclaration = functionCall.getDeclaration();
			TypeInfo functionBaseTypeInfo = getTargetType(functionDeclaration.getBaseType());
			TypeInfo functionReturnTypeInfo = getTargetType(functionDeclaration.getReturnType());

			if (functionReturnTypeInfo.isEntity()) {
				functionReturnTypeInfo.type = baseTypeInfo.type;
			}
			
			if (functionCall.getArguments().size() > 0) {
				FunctionArgument argument = functionCall.getArguments().get(0);
				TypeInfo argumentTypeInfo = TypeInfo.getTargetType(argument.getExpression());
				
				if (argumentTypeInfo.isEntity() && argumentTypeInfo.isDeclaration())
				{
					functionReturnTypeInfo.type =  argumentTypeInfo.getEntity();
				}
			}

			if (!functionBaseTypeInfo.isCollection() && !functionBaseTypeInfo.isDeclaration()) {
				functionReturnTypeInfo.modifier = baseTypeInfo.modifier;
			}
			
			return functionReturnTypeInfo;
			
		} else if (feature instanceof LambdaCall) {
			if (!isResolvedReference(feature, JsldslPackage.LAMBDA_CALL__DECLARATION)) {
				return baseTypeInfo;
			}
			TypeInfo typeInfo = getTargetType( ((LambdaCall) feature).getDeclaration().getReturnType() );
			typeInfo.type = baseTypeInfo.type;
			return typeInfo;
		}
		
		throw new IllegalArgumentException("Could not determinate feature return type: " + feature);
	}
	
	private static TypeInfo getTargetType(Navigation navigation) {
		int size = navigation.getFeatures().size();
		if (size > 0) {
			return getTargetType(navigation.getFeatures().get(size - 1));
		} else {
			return getTargetType( navigation.getBase() );
		}
	}
	
	public static TypeInfo getTargetType(NavigationBase navigationBase) {
		if (navigationBase instanceof Self) {
			return getTargetType( (Self) navigationBase );
		} else if (navigationBase instanceof Parentheses) {
			return getTargetType( (Parentheses) navigationBase);
		} else if (navigationBase instanceof NavigationBaseDeclarationReference) {
			return getTargetType( (NavigationBaseDeclarationReference) navigationBase);
		} else if (navigationBase instanceof QueryCall) {
			return getTargetType( (QueryCall) navigationBase);
		} else if (navigationBase instanceof Literal) {
			return getTargetType( (Literal) navigationBase);
		}

		throw new IllegalArgumentException("Could not determinate type for navigationBase: " + navigationBase);
	}
	
	private static TypeInfo getTargetType(LambdaVariable lambdaVariable) {
		LambdaCall lambdaCall = modelExtension.parentContainer(lambdaVariable, LambdaCall.class);
		
		while (!EcoreUtil.equals(lambdaCall.getVariable(), lambdaVariable)) {
			lambdaCall = modelExtension.parentContainer(lambdaCall, LambdaCall.class);			
		}
		
		Navigation navigation = (Navigation) lambdaCall.eContainer();
		int index = navigation.getFeatures().indexOf(lambdaCall);
		
		TypeInfo typeInfo;
		
		if (index > 0) {
			typeInfo = getTargetType( navigation.getFeatures().get(index - 1) );
		} else {
			typeInfo = getTargetType( navigation.getBase() );
		}

		typeInfo.modifier = TypeModifier.NONE;

		// System.out.println(typeInfo);
		
		return typeInfo;
	}
		
	private static TypeInfo getTargetType(QueryCall queryCall) {
		QueryDeclaration queryDeclaration = queryCall.getDeclaration();
		return new TypeInfo(queryDeclaration.getReferenceType(), queryDeclaration.isIsMany(), false);
	}
	
	private static TypeInfo getTargetType(NavigationBaseDeclarationReference navigationBaseDeclarationReference) {
		TypeInfo typeInfo;
		NavigationBaseDeclaration navigationBaseReference = navigationBaseDeclarationReference.getReference();

		if (navigationBaseReference instanceof EntityDeclaration) {
			typeInfo = new TypeInfo((EntityDeclaration) navigationBaseReference, false, true);
		} else if (navigationBaseReference instanceof LambdaVariable) {
			typeInfo = getTargetType((LambdaVariable) navigationBaseReference);
		} else if (navigationBaseReference instanceof QueryDeclarationParameter) {
			typeInfo = new TypeInfo( ((QueryDeclarationParameter) navigationBaseReference).getReferenceType(), false, false);
			typeInfo.modifier = TypeModifier.CONSTANT;
		} else if (navigationBaseReference instanceof PrimitiveDeclaration) {
			typeInfo = new TypeInfo((SingleType) navigationBaseReference, false, true);
		} else {
			throw new IllegalArgumentException("Could not determinate type for navigation base reference.");
		}

		return typeInfo;
	}
	
	private static TypeInfo getTargetType(Self self) {
		TypeInfo typeInfo = new TypeInfo(modelExtension.parentContainer(self, EntityDeclaration.class), false, false);
		return typeInfo;
	}
	
	private static TypeInfo getTargetType(NavigationTarget navigationTarget) {
		if (navigationTarget instanceof EntityMemberDeclaration) {
			return getTargetType((EntityMemberDeclaration)navigationTarget);
		} else if (navigationTarget instanceof EntityRelationOppositeInjected) {
			return new TypeInfo((EntityDeclaration) navigationTarget.eContainer().eContainer(), ((EntityRelationOppositeInjected) navigationTarget).isIsMany(), false);
		}

		throw new IllegalArgumentException("Could not determinate type for navigation target:" + navigationTarget);
	}
	
	public static TypeInfo getTargetType(TypeDescription typeDescription) {
		return new TypeInfo(typeDescription);
	}
	
	public static TypeInfo getTargetType(EntityMemberDeclaration entityMemberDeclaration) {
		if (entityMemberDeclaration instanceof EntityFieldDeclaration) {
			EntityFieldDeclaration entityFieldDeclaration = (EntityFieldDeclaration)entityMemberDeclaration;
			return new TypeInfo(entityFieldDeclaration.getReferenceType(), entityFieldDeclaration.isIsMany(), false);
		} else if (entityMemberDeclaration instanceof EntityIdentifierDeclaration) {
			EntityIdentifierDeclaration entityIdentifierDeclaration = (EntityIdentifierDeclaration)entityMemberDeclaration;
			return new TypeInfo(entityIdentifierDeclaration.getReferenceType(), false, false);
		} else if (entityMemberDeclaration instanceof EntityRelationDeclaration) {
			EntityRelationDeclaration entityRelationDeclaration = (EntityRelationDeclaration)entityMemberDeclaration;
			return new TypeInfo(entityRelationDeclaration.getReferenceType(), entityRelationDeclaration.isIsMany(), false);
		} else if (entityMemberDeclaration instanceof EntityDerivedDeclaration) {
			EntityDerivedDeclaration entityDerivedDeclaration = (EntityDerivedDeclaration)entityMemberDeclaration;
			return new TypeInfo(entityDerivedDeclaration.getReferenceType(), entityDerivedDeclaration.isIsMany(), false);
		} else if (entityMemberDeclaration instanceof EntityQueryDeclaration) {
			EntityQueryDeclaration entityQueryDeclaration = (EntityQueryDeclaration)entityMemberDeclaration;
			return new TypeInfo(entityQueryDeclaration.getReferenceType(), entityQueryDeclaration.isIsMany(), false);
		}
		
		throw new IllegalArgumentException("Could not determinate type for entity member");
	}

	private static TypeInfo getTargetType(Parentheses parentheses) {
		TypeInfo typeInfo = getTargetType( parentheses.getExpression() );
		typeInfo.modifier = typeInfo.modifier == TypeModifier.CONSTANT ? TypeModifier.NONE : typeInfo.modifier;
		return typeInfo;
	}
	
	private static TypeInfo getTargetType(TernaryOperation expression) {
		TypeInfo typeInfo = getTargetType( expression.getThenExpression() );
		typeInfo.modifier = typeInfo.modifier == TypeModifier.CONSTANT ? TypeModifier.NONE : typeInfo.modifier;
		return typeInfo;
	}

	public static TypeInfo getTargetType(Literal litreal) {
	  	if (litreal instanceof IntegerLiteral) {
			return new TypeInfo(BaseType.NUMERIC, true);
		} else if (litreal instanceof DecimalLiteral) {
			return new TypeInfo(BaseType.NUMERIC, true);
		} else if (litreal instanceof BooleanLiteral) {
			return new TypeInfo(BaseType.BOOLEAN, true);
		} else if (litreal instanceof EscapedStringLiteral) {
			return new TypeInfo(BaseType.STRING, true);
		} else if (litreal instanceof RawStringLiteral) {
			return new TypeInfo(BaseType.STRING, true);
		} else if (litreal instanceof DateLiteral) {
			return new TypeInfo(BaseType.DATE, true);
		} else if (litreal instanceof TimeLiteral) {
			return new TypeInfo(BaseType.TIME, true);
		} else if (litreal instanceof TimeStampLiteral) {
			return new TypeInfo(BaseType.TIMESTAMP, true);
		} else if (litreal instanceof EnumLiteralReference) {
			return getTargetType( (EnumLiteralReference) litreal);
		}

	  	throw new IllegalArgumentException("Could not determinate type for expression: " + litreal);
	}
	
	public static TypeInfo getTargetType(Expression expression) {
		if (expression instanceof TernaryOperation) {
			return getTargetType( (TernaryOperation) expression );
		} else if (expression instanceof BinaryOperation) {
			return getTargetType( (BinaryOperation) expression);
		} else if (expression instanceof UnaryOperation) {
			return new TypeInfo(BaseType.BOOLEAN, false);
		} else if (expression instanceof Navigation) {
			return getTargetType( (Navigation) expression);
		}		

		throw new IllegalArgumentException("Could not determinate type for expression: " + expression);
	}
}