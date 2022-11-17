package hu.blackbelt.judo.meta.jsl.runtime;

import java.util.Arrays;

import org.eclipse.emf.common.util.EList;
 
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
import hu.blackbelt.judo.meta.jsl.jsldsl.Function;
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionBaseType;
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionCall;
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionParameterType;
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionReturnType;
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionedExpression;
import hu.blackbelt.judo.meta.jsl.jsldsl.IntegerLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaFunction;
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaVariable;
import hu.blackbelt.judo.meta.jsl.jsldsl.LiteralFunction;
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationBaseExpression;
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationBaseReference;
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationTarget;
import hu.blackbelt.judo.meta.jsl.jsldsl.ParenthesizedExpression;
import hu.blackbelt.judo.meta.jsl.jsldsl.PrimitiveDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryCallExpression;
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryDeclarationParameter;
import hu.blackbelt.judo.meta.jsl.jsldsl.RawStringLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.SelfExpression;
import hu.blackbelt.judo.meta.jsl.jsldsl.SingleType;
import hu.blackbelt.judo.meta.jsl.jsldsl.TernaryOperation;
import hu.blackbelt.judo.meta.jsl.jsldsl.TimeLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.TimeStampLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.UnaryOperation;

import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension;

public class TypeInfo {
    private static JslDslModelExtension modelExtension = new JslDslModelExtension();
	
    // PrimitiveType is just for compatibility purpose
    public enum PrimitiveType {BOOLEAN, BINARY, STRING, NUMERIC, DATE, TIME, TIMESTAMP}
    
    private enum BaseType {BOOLEAN, BINARY, STRING, NUMERIC, DATE, TIME, TIMESTAMP, ENUM, ENTITY}
    
    private boolean isLiteral = false;
	private boolean isCollection = false;
	private BaseType baseType;
	private SingleType type;

	public String toString() {
		switch (this.baseType) {
			case ENUM:
				return ((EnumDeclaration)this.type).getName() + (this.isLiteral ? " literal" : "");
			case ENTITY:
				return ((EntityDeclaration)this.type).getName() + (this.isCollection ? " collection" : "");
			default:
				return this.baseType.toString().toLowerCase() + (this.isLiteral ? " literal" : "");
		}
	}

	public void print() {
		System.out.println("BaseType:     " + this.baseType);
		System.out.println("isCollection: " + this.isCollection);
		System.out.println("type: " 		+ this.type);
	}
	
	private TypeInfo(BaseType baseType, boolean isLiteral) {
		if (baseType == BaseType.ENUM || baseType == BaseType.ENTITY) {
			throw new IllegalArgumentException("TypeInfo got illegal argument: " + baseType);
		}
		
		this.isLiteral = isLiteral;
		this.baseType = baseType;
	}

	private TypeInfo(SingleType type, boolean isCollection) {
		if (type instanceof DataTypeDeclaration) {
			this.type = type;

			DataTypeDeclaration dataType = (DataTypeDeclaration) type;
			
			if (dataType.getPrimitive().equals("boolean")) {
				this.baseType = BaseType.BOOLEAN;
			} else if (dataType.getPrimitive().equals("binary")) {
				this.baseType = BaseType.BINARY;
			} else if (dataType.getPrimitive().equals("string")) {
				this.baseType = BaseType.STRING;
			} else if (dataType.getPrimitive().equals("numeric")) {
				this.baseType = BaseType.NUMERIC;
			} else if (dataType.getPrimitive().equals("date")) {
				this.baseType = BaseType.DATE;
			} else if (dataType.getPrimitive().equals("time")) {
				this.baseType = BaseType.TIME;
			} else if (dataType.getPrimitive().equals("timestamp")) {
				this.baseType = BaseType.TIMESTAMP;
			} else {
				throw new IllegalArgumentException("TypeInfo got illegal primitive argument: " + dataType.getPrimitive());
			}			
		} else if (type instanceof EnumDeclaration) {
			this.type = type;
			this.baseType = BaseType.ENUM;
		} else if (type instanceof EntityDeclaration) {
			this.isCollection = isCollection;
			this.type = type;
			this.baseType = BaseType.ENTITY;
		}
	}

	private TypeInfo(SingleType type) {
		this(type, true);
	}

	public boolean isEntity() {
		return this.baseType == BaseType.ENTITY;
	}

	public boolean isEnum() {
		return this.baseType == BaseType.ENUM;
	}

	public boolean isPrimitive() {
		return !this.isEntity();
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
		return this.isCollection;
	}

	public boolean isLiteral() {
		return this.isLiteral;
	}

	public boolean isCompatible(TypeInfo other) {
		if (this.isLiteral && !other.isLiteral) {
			return false;
		}
		
		if (this.baseType == BaseType.ENUM && other.baseType == BaseType.ENUM) {
			return ((EnumDeclaration)this.type).equals(((EnumDeclaration)other.type));
		}
		
		if (this.baseType == BaseType.ENTITY && other.baseType == BaseType.ENTITY) {
			if (this.isCollection ^ other.isCollection) return false;
			
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
	
	public static TypeInfo getTargetType(FunctionParameterType functionParameterType) {
		switch (functionParameterType) {
			case PT_BOOLEAN_INSTANCE:   return new TypeInfo(BaseType.BOOLEAN, false);
			case PT_BINARY_INSTANCE:    return new TypeInfo(BaseType.BINARY, false);
			case PT_STRING_INSTANCE:    return new TypeInfo(BaseType.STRING, false);
			case PT_NUMERIC_INSTANCE:   return new TypeInfo(BaseType.NUMERIC, false);
			case PT_DATE_INSTANCE:      return new TypeInfo(BaseType.DATE, false);
			case PT_TIME_INSTANCE:      return new TypeInfo(BaseType.TIME, false);
			case PT_TIMESTAMP_INSTANCE: return new TypeInfo(BaseType.TIMESTAMP, false);

			case PT_BOOLEAN_LITERAL:    return new TypeInfo(BaseType.BOOLEAN, true);
			case PT_BINARY_LITERAL:     return new TypeInfo(BaseType.BINARY, true);
			case PT_STRING_LITERAL:     return new TypeInfo(BaseType.STRING, true);
			case PT_NUMERIC_LITERAL:    return new TypeInfo(BaseType.NUMERIC, true);
			case PT_DATE_LITERAL:       return new TypeInfo(BaseType.DATE, true);
			case PT_TIME_LITERAL:       return new TypeInfo(BaseType.TIME, true);
			case PT_TIMESTAMP_LITERAL:  return new TypeInfo(BaseType.TIMESTAMP, true);

			default:
				throw new IllegalArgumentException("Could not determinate function parameter type: " + functionParameterType.getName());
		}
	}
	
	public FunctionBaseType getFunctionBaseType() {
		switch (this.baseType) {
			case BOOLEAN:   return FunctionBaseType.BT_BOOLEAN_INSTANCE;
			case BINARY:    return FunctionBaseType.BT_BINARY_INSTANCE;
			case STRING:    return FunctionBaseType.BT_STRING_INSTANCE;
			case NUMERIC:   return FunctionBaseType.BT_NUMERIC_INSTANCE;
			case DATE:      return FunctionBaseType.BT_DATE_INSTANCE;
			case TIME:      return FunctionBaseType.BT_TIME_INSTANCE;
			case TIMESTAMP: return FunctionBaseType.BT_TIMESTAMP_INSTANCE;

			default:
				throw new IllegalArgumentException("Could not determinate function base type");
		}
	}

	private static TypeInfo getTargetType(EnumLiteralReference enumReference) {
		TypeInfo typeInfo = new TypeInfo(enumReference.getEnumDeclaration());
		typeInfo.isLiteral = true;
		return typeInfo;
	}
	
	private static TypeInfo getTargetType(BinaryOperation binaryOperation) {
		if (Arrays.asList("!=","==",">=","<=",">","<").contains(binaryOperation.getOperator())) {
			return new TypeInfo(BaseType.BOOLEAN, false); 
		}
		
		TypeInfo typeInfo = getTargetType(binaryOperation.getLeftOperand());
		typeInfo.isLiteral = false;
		
		return typeInfo;
	}

	private static TypeInfo getTargetType(FunctionedExpression functionedExpression) {
		return getTargetType(functionedExpression.getFunctionCall(), getTargetType(functionedExpression.getOperand()));
	}

	private static TypeInfo getTargetType(Function function, TypeInfo typeInfo) {
		FunctionReturnType functionReturnType = null;
		
		if (function instanceof LiteralFunction) {
			LiteralFunction literalFunction = (LiteralFunction)function;
			functionReturnType = literalFunction.getFunctionDeclarationReference().getReturnTypes().get(0);

			if (functionReturnType == FunctionReturnType.RT_ENTITY_INSTANCE) {
				if (literalFunction.getParameters().size() > 0) {
					typeInfo.type = (EntityDeclaration)((NavigationBaseExpression)literalFunction.getParameters().get(0).getExpression()).getNavigationBaseType();
				}
				typeInfo.baseType = BaseType.ENTITY;
				typeInfo.isCollection = false;
				return typeInfo;
			} else if (functionReturnType == FunctionReturnType.RT_ENTITY_COLLECTION) {
				if (literalFunction.getParameters().size() > 0) {
					typeInfo.type = (EntityDeclaration)((NavigationBaseExpression)literalFunction.getParameters().get(0).getExpression()).getNavigationBaseType();
				}
				typeInfo.baseType = BaseType.ENTITY;
				typeInfo.isCollection = true;
				return typeInfo;
			}
		} else if (function instanceof LambdaFunction) {
			LambdaFunction lambdaFunction = (LambdaFunction)function;
			functionReturnType = lambdaFunction.getFunctionDeclarationReference().getReturnTypes().get(0);
		}

		if (functionReturnType == FunctionReturnType.RT_INPUT_SAME) {
			return typeInfo;
		} else if (functionReturnType == FunctionReturnType.RT_BASE_TYPE_INSTANCE) {
			typeInfo.isCollection = false;
			return typeInfo;
		} else if (functionReturnType == FunctionReturnType.RT_BASE_TYPE_COLLECTION) {
			throw new IllegalArgumentException("Invalid function return type:RT_BASE_TYPE_COLLECTION");
		} else if (functionReturnType == FunctionReturnType.RT_BOOLEAN_INSTANCE) {
			return new TypeInfo(BaseType.BOOLEAN, false);
		} else if (functionReturnType == FunctionReturnType.RT_BINARY_INSTANCE) {
			return new TypeInfo(BaseType.BINARY, false);
		} else if (functionReturnType == FunctionReturnType.RT_STRING_INSTANCE) {
			return new TypeInfo(BaseType.STRING, false);
		} else if (functionReturnType == FunctionReturnType.RT_NUMERIC_INSTANCE) {
			return new TypeInfo(BaseType.NUMERIC, false);
		} else if (functionReturnType == FunctionReturnType.RT_DATE_INSTANCE) {
			return new TypeInfo(BaseType.DATE, false);
		} else if (functionReturnType == FunctionReturnType.RT_TIME_INSTANCE) {
			return new TypeInfo(BaseType.TIME, false);
		} else if (functionReturnType == FunctionReturnType.RT_TIMESTAMP_INSTANCE) {
			return new TypeInfo(BaseType.TIMESTAMP, false);
		}

		throw new IllegalArgumentException("Could not determinate function return type: " + functionReturnType.getName());
	}
	
	private static TypeInfo getTargetType(EList<Feature> features, TypeInfo typeInfo) {
		boolean isCollection = typeInfo != null ? typeInfo.isCollection : false;
		
		if (features.size() > 0) {
			typeInfo = getTargetType(features.get(features.size() - 1).getNavigationTargetType());
			typeInfo.isCollection = isCollection || features.stream().anyMatch(f -> isMany(f.getNavigationTargetType()));
		}
		
		return typeInfo;
	}

	private static TypeInfo getTargetType(FunctionCall functionCall, TypeInfo typeInfo) {
		typeInfo.isLiteral = false;
		
		typeInfo = getTargetType(functionCall.getFunction(), typeInfo);
		typeInfo = getTargetType(functionCall.getFeatures(), typeInfo);
		
		if (functionCall.getCall() != null) {
			typeInfo = getTargetType(functionCall.getCall(), typeInfo);
		}
		
		return typeInfo;
	}

	private static TypeInfo getTargetType(LambdaVariable lambdaVariable) {
		FunctionCall functionCall = modelExtension.parentContainer(lambdaVariable, FunctionCall.class);
		
		while (functionCall.getFunction() instanceof LiteralFunction || !((LambdaFunction)functionCall.getFunction()).getLambdaArgument().getName().equals(lambdaVariable.getName())) {
			functionCall = modelExtension.parentContainer(functionCall, FunctionCall.class);			
		}
		
		TypeInfo typeInfo = getTargetType(modelExtension.parentContainer(functionCall, FunctionedExpression.class));
		typeInfo.isCollection = false;

		return typeInfo;
	}
	
	private static TypeInfo getTargetType(NavigationBaseExpression navigationBaseExpression) {
		TypeInfo typeInfo;
		NavigationBaseReference navigationBaseReference = navigationBaseExpression.getNavigationBaseType();

		if (navigationBaseReference instanceof EntityDeclaration) {
			typeInfo = new TypeInfo((EntityDeclaration) navigationBaseReference);
		} else if (navigationBaseReference instanceof QueryDeclaration) {
			QueryDeclaration queryDeclaration = (QueryDeclaration)navigationBaseReference;
			typeInfo = new TypeInfo(queryDeclaration.getReferenceType(), queryDeclaration.isIsMany());
		} else if (navigationBaseReference instanceof LambdaVariable) {
			typeInfo = getTargetType((LambdaVariable) navigationBaseReference);
		} else if (navigationBaseReference instanceof QueryDeclarationParameter) {
			typeInfo = new TypeInfo( ((QueryDeclarationParameter) navigationBaseReference).getReferenceType());
		} else if (navigationBaseReference instanceof PrimitiveDeclaration) {
			typeInfo = new TypeInfo((SingleType) navigationBaseReference);
		} else {
			throw new IllegalArgumentException("Could not determinate type for navigation base reference.");
		}

		return getTargetType(navigationBaseExpression.getFeatures(), typeInfo);
	}

	private static TypeInfo getTargetType(QueryCallExpression queryCallExpression) {
		TypeInfo typeInfo = new TypeInfo(queryCallExpression.getQueryDeclarationType().getReferenceType());
		return getTargetType(queryCallExpression.getFeatures(), typeInfo);
	}

	
	private static TypeInfo getTargetType(SelfExpression selfExpression) {
		TypeInfo typeInfo = getTargetType(modelExtension.parentContainer(selfExpression, EntityDeclaration.class));
		typeInfo.isCollection = false;
		return getTargetType(selfExpression.getFeatures(), typeInfo);
	}

	private static boolean isMany(NavigationTarget navigationTarget) {
		if (navigationTarget instanceof EntityFieldDeclaration) {
			return ((EntityFieldDeclaration)navigationTarget).isIsMany();
		} else if (navigationTarget instanceof EntityRelationDeclaration) {
			return ((EntityRelationDeclaration)navigationTarget).isIsMany();
		} else if (navigationTarget instanceof EntityDerivedDeclaration) {
			return ((EntityDerivedDeclaration)navigationTarget).isIsMany();
		} else if (navigationTarget instanceof EntityQueryDeclaration) {
			return ((EntityQueryDeclaration)navigationTarget).isIsMany();
		} else if (navigationTarget instanceof EntityRelationOppositeInjected) {
			return ((EntityRelationOppositeInjected)navigationTarget).isIsMany();
		}
		return false;
	}
	
	private static TypeInfo getTargetType(NavigationTarget navigationTarget) {
		if (navigationTarget instanceof EntityMemberDeclaration) {
			return getTargetType((EntityMemberDeclaration)navigationTarget);
		} else if (navigationTarget instanceof EntityDeclaration) {
			return new TypeInfo((EntityDeclaration)navigationTarget);
		} else if (navigationTarget instanceof EntityRelationOppositeInjected) {
			return new TypeInfo((EntityDeclaration) navigationTarget.eContainer().eContainer(), ((EntityRelationOppositeInjected) navigationTarget).isIsMany());
		}

		throw new IllegalArgumentException("Could not determinate type for navigation target:" + navigationTarget);
	}
	
	public static TypeInfo getParentFunctionCallReturnType(FunctionCall functionCall) {
		if (functionCall.eContainer() instanceof FunctionedExpression) {
			return getTargetType(((FunctionedExpression) functionCall.eContainer()).getOperand());
		} else if (functionCall.eContainer() instanceof FunctionCall) {
			TypeInfo typeInfo = getTargetType(((FunctionCall) functionCall.eContainer()).getFeatures(), null);
			return typeInfo != null ? typeInfo : getParentFunctionCallReturnType((FunctionCall) functionCall.eContainer());
		} 
		throw new IllegalArgumentException("Could not determinate function call return type: " + functionCall);		
	}

	public static TypeInfo getTargetType(EntityMemberDeclaration entityMemberDeclaration) {
		if (entityMemberDeclaration instanceof EntityFieldDeclaration) {
			EntityFieldDeclaration entityFieldDeclaration = (EntityFieldDeclaration)entityMemberDeclaration;
			return new TypeInfo(entityFieldDeclaration.getReferenceType(), entityFieldDeclaration.isIsMany());
		} else if (entityMemberDeclaration instanceof EntityIdentifierDeclaration) {
			EntityIdentifierDeclaration entityIdentifierDeclaration = (EntityIdentifierDeclaration)entityMemberDeclaration;
			return new TypeInfo(entityIdentifierDeclaration.getReferenceType());
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
		typeInfo.isLiteral = false;
		return typeInfo;
	}
	
	private static TypeInfo getTargetType(TernaryOperation expression) {
		TypeInfo typeInfo = getTargetType( expression.getThenExpression() );
		typeInfo.isLiteral = false;
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
		} else if (expression instanceof FunctionedExpression) {
			return getTargetType( (FunctionedExpression) expression);
		} else if (expression instanceof SelfExpression) {
			return getTargetType( (SelfExpression) expression);
		} else if (expression instanceof NavigationBaseExpression) {
			return getTargetType( (NavigationBaseExpression) expression);
		} else if (expression instanceof QueryCallExpression) {
			return getTargetType( (QueryCallExpression) expression);
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