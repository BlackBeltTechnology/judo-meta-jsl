package hu.blackbelt.judo.meta.jsl.runtime;

import java.util.Arrays;

import com.google.common.collect.ImmutableMap;

import hu.blackbelt.judo.meta.jsl.jsldsl.AnnotationParameterType;
import hu.blackbelt.judo.meta.jsl.jsldsl.Argument;
import hu.blackbelt.judo.meta.jsl.jsldsl.BinaryOperation;
import hu.blackbelt.judo.meta.jsl.jsldsl.BooleanLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.DataTypeDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.DateLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityMapDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityMemberDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeInjected;
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumLiteralReference;
import hu.blackbelt.judo.meta.jsl.jsldsl.EscapedStringLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.Expression;
import hu.blackbelt.judo.meta.jsl.jsldsl.Feature;
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionOrQueryCall;
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionOrQueryDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionParameterDeclaration;
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
import hu.blackbelt.judo.meta.jsl.jsldsl.NumberLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.ParameterDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.Parentheses;
import hu.blackbelt.judo.meta.jsl.jsldsl.Persistable;
import hu.blackbelt.judo.meta.jsl.jsldsl.PrimitiveDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryParameterDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.RawStringLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.Self;
import hu.blackbelt.judo.meta.jsl.jsldsl.TernaryOperation;
import hu.blackbelt.judo.meta.jsl.jsldsl.TimeLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.TimestampLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferDataDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferFieldDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferRelationDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.TypeDescription;
import hu.blackbelt.judo.meta.jsl.jsldsl.UnaryOperation;
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewTextDeclaration;
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension;


public class TypeInfo {
	private static JslDslModelExtension modelExtension = new JslDslModelExtension();
	
    // PrimitiveType is just for compatibility purpose
    public enum PrimitiveType {BOOLEAN, BINARY, STRING, NUMERIC, DATE, TIME, TIMESTAMP}
    
    private enum BaseType {UNDEFINED, BOOLEAN, BINARY, STRING, NUMERIC, DATE, TIME, TIMESTAMP, ENUM, ENTITY}

    private enum TypeModifier {NONE, CONSTANT, COLLECTION, DECLARATION}
    
    private boolean isLiteral = false;

    private TypeModifier modifier = TypeModifier.NONE;
	private BaseType baseType;
	private Persistable type;

	public String toString() {
		String result = this.baseType.toString().toLowerCase();

		if (this.baseType == BaseType.ENUM) {
			result += "(" + ((EnumDeclaration) this.type).getName() + ")";
		} else if (this.baseType == BaseType.ENTITY) {
			result += "(" + ((EntityDeclaration) this.type).getName() + ")";
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
		
		this.isLiteral = isLiteral;
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

	private TypeInfo(AnnotationParameterType annotationParameterType) {
		this.baseType = getBaseType(annotationParameterType);
		this.isLiteral = true;
		this.modifier = TypeModifier.CONSTANT;
	}

	private static final ImmutableMap<String, BaseType> baseTypeMap =
       new ImmutableMap.Builder<String, BaseType>()
           .put("boolean", BaseType.BOOLEAN)
           .put("binary", BaseType.BINARY)
           .put("string", BaseType.STRING)
           .put("numeric", BaseType.NUMERIC)
           .put("date", BaseType.DATE)
           .put("time", BaseType.TIME)
           .put("timestamp", BaseType.TIMESTAMP)
           .put("enum", BaseType.ENUM)
           .put("entity", BaseType.ENTITY)
           .build();

	private static BaseType getBaseType(String type) {
		return baseTypeMap.get(type);
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

	private static BaseType getBaseType(AnnotationParameterType annotationParameterType) {
		if (annotationParameterType == null) {
			throw new IllegalArgumentException("TypeInfo got illegal argument: " + annotationParameterType);
		}
		
		return getBaseType(annotationParameterType.getType());
	}

	private TypeInfo(Persistable type, boolean isCollection, boolean isDeclarartion) {
		this.modifier = isDeclarartion ? TypeModifier.DECLARATION : this.modifier;

		if (type instanceof DataTypeDeclaration) {
			this.type = type;
			this.baseType = getBaseType(((DataTypeDeclaration) type).getPrimitive());
			
			if (isCollection) {
				this.baseType = BaseType.UNDEFINED;
			}
		} else if (type instanceof EnumDeclaration) {
			this.type = type;
			this.baseType = BaseType.ENUM;

			if (isCollection) {
				this.baseType = BaseType.UNDEFINED;
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

	public boolean isLiteral() {
		return this.isConstant() && this.isLiteral;
	}

	public boolean isOrderable() {
		return !(this.isEntity() || this.isBinary());
	}

	public boolean isBaseCompatible(TypeInfo other) {
		if (this.baseType == BaseType.UNDEFINED || other.baseType == BaseType.UNDEFINED) {
			return false;
		}

		if (this.isCollection() ^ other.isCollection()) {
			return false;
		}
		
		if (this.isDeclaration() ^ other.isDeclaration()) {
			return false;
		}

		return this.baseType == other.baseType;
	}
	
	public boolean isCompatible(TypeInfo other) {
		if (this.baseType == BaseType.UNDEFINED || other.baseType == BaseType.UNDEFINED) {
			return false;
		}
		
		if (this.isCollection() ^ other.isCollection()) {
			return false;
		}
		
		if (this.isDeclaration() ^ other.isDeclaration()) {
			return false;
		}

		if (this.baseType == BaseType.ENUM && other.baseType == BaseType.ENUM) {
			return modelExtension.isEqual(this.type, other.type);
		}
		
		if (this.baseType == BaseType.ENTITY && other.baseType == BaseType.ENTITY)
		{
			return modelExtension.isEqual(this.type, other.type)
					|| modelExtension.getSuperEntityTypes((EntityDeclaration)other.type).stream()
						.anyMatch(e -> modelExtension.isEqual(e, this.type));
		}

		return this.baseType == other.baseType;
	}

	public boolean isInstanceOf(TypeInfo other) {
		if (!other.isEntity() || !other.isDeclaration() || other.isCollection()) {
			return false;
		}
		
		if (!this.isEntity() || this.isDeclaration() || this.isCollection()) {
			return false;
		}
		
		if (this.baseType == BaseType.UNDEFINED || other.baseType == BaseType.UNDEFINED) {
			return false;
		}

		return modelExtension.isEqual(this.type, other.type)
				|| modelExtension.getSuperEntityTypes((EntityDeclaration)this.type).stream()
				.anyMatch(e -> modelExtension.isEqual(e, other.type));
	}
	
	public boolean isCompatibleCollection(TypeInfo other) {
		if (this.baseType == BaseType.UNDEFINED || other.baseType == BaseType.UNDEFINED) {
			return false;
		}

		if (!other.isCollection()) {
			return false;
		}
		
		if (other.isDeclaration()) {
			return false;
		}
		
		if (this.baseType == BaseType.ENTITY && other.baseType == BaseType.ENTITY)
		{
			return modelExtension.isEqual(this.type, other.type)
					|| modelExtension.getSuperEntityTypes((EntityDeclaration)other.type).stream()
						.anyMatch(e -> modelExtension.isEqual(e, this.type));
		} else {
			return false;
		}
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
		typeInfo.isLiteral = true;
		return typeInfo;
	}
	
	private static TypeInfo getTargetType(BinaryOperation binaryOperation) {
		if (Arrays.asList("!=", "==", ">=", "<=", ">", "<").contains(binaryOperation.getOperator())) {
			return new TypeInfo(BaseType.BOOLEAN, false); 
		}
		
		TypeInfo typeInfo = getTargetType(binaryOperation.getLeftOperand());
		typeInfo.modifier = typeInfo.modifier == TypeModifier.CONSTANT ? TypeModifier.NONE : typeInfo.modifier;
		
		return typeInfo;
	}
	
	public static TypeInfo getTargetType(Persistable type) {
		return new TypeInfo(type, false, true);
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
			if (!modelExtension.isResolvedReference(feature, JsldslPackage.MEMBER_REFERENCE__MEMBER)) {
				return baseTypeInfo;
			}
			TypeInfo typeInfo = getTargetType( ((MemberReference) feature).getMember() );
			typeInfo.modifier = typeInfo.modifier == TypeModifier.COLLECTION ? TypeModifier.COLLECTION : baseTypeInfo.modifier;
			return typeInfo;
		}
		 
		else if (feature instanceof FunctionOrQueryCall) {
			if (!modelExtension.isResolvedReference(feature, JsldslPackage.FUNCTION_OR_QUERY_CALL__DECLARATION)) {
				return baseTypeInfo;
			}
			FunctionOrQueryCall functionCall = (FunctionOrQueryCall)feature;
			FunctionOrQueryDeclaration functionOrQueryDeclaration = functionCall.getDeclaration();

			if (functionOrQueryDeclaration instanceof FunctionDeclaration) {
				FunctionDeclaration functionDeclaration = (FunctionDeclaration)functionOrQueryDeclaration;
				
				TypeInfo functionReturnTypeInfo = getTargetType(functionDeclaration.getReturnType());
	
				if (functionReturnTypeInfo.isEntity()) {
					functionReturnTypeInfo.type = baseTypeInfo.type;
	
					if (functionCall.getArguments().size() > 0) {
						Argument argument = functionCall.getArguments().get(0);
						TypeInfo argumentTypeInfo = TypeInfo.getTargetType(argument.getExpression());
						
						if (argumentTypeInfo.isEntity())
						{
							functionReturnTypeInfo.type =  argumentTypeInfo.getEntity();
						}
					}
				}
	
				return functionReturnTypeInfo;
		 	} else if (functionOrQueryDeclaration instanceof QueryDeclaration) {
				QueryDeclaration queryDeclaration = (QueryDeclaration)functionOrQueryDeclaration;
				return new TypeInfo(queryDeclaration.getReferenceType(), queryDeclaration.isMany(), false);
		 	}
			
		}

		else if (feature instanceof LambdaCall) {
			if (!modelExtension.isResolvedReference(feature, JsldslPackage.LAMBDA_CALL__DECLARATION)) {
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
	
	private static TypeInfo getTargetType(NavigationBase navigationBase) {
		if (navigationBase == null) {
			return new TypeInfo(BaseType.UNDEFINED, false);
		}

		if (navigationBase instanceof Self) {
			return getTargetType( (Self) navigationBase );
		} else if (navigationBase instanceof Parentheses) {
			return getTargetType( (Parentheses) navigationBase);
		} else if (navigationBase instanceof NavigationBaseDeclarationReference) {
			return getTargetType( (NavigationBaseDeclarationReference) navigationBase);
		} else if (navigationBase instanceof Literal) {
			return getTargetType( (Literal) navigationBase);
		} else if (navigationBase instanceof FunctionOrQueryCall) {
			if (!modelExtension.isResolvedReference(navigationBase, JsldslPackage.FUNCTION_OR_QUERY_CALL__DECLARATION)) {
				return new TypeInfo(BaseType.UNDEFINED, false);
			}

			FunctionOrQueryDeclaration declaration = ((FunctionOrQueryCall) navigationBase).getDeclaration();
			if (declaration  instanceof QueryDeclaration) {
				QueryDeclaration queryDeclaration = (QueryDeclaration)declaration;
				return new TypeInfo(queryDeclaration.getReferenceType(), queryDeclaration.isMany(), false);
		 	}
		} 

		throw new IllegalArgumentException("Could not determinate type for navigationBase: " + navigationBase);
	}
	
	private static TypeInfo getTargetType(LambdaVariable lambdaVariable) {
		LambdaCall lambdaCall = modelExtension.parentContainer(lambdaVariable, LambdaCall.class);
		
		while (!modelExtension.isEqual(lambdaCall.getVariable(), lambdaVariable)) {
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
		
		return typeInfo;
	}
	
	private static TypeInfo getTargetType(NavigationBaseDeclarationReference navigationBaseDeclarationReference) {
		TypeInfo typeInfo;
		NavigationBaseDeclaration navigationBaseReference = navigationBaseDeclarationReference.getReference();

		if (navigationBaseReference instanceof EntityDeclaration) {
			typeInfo = new TypeInfo((EntityDeclaration) navigationBaseReference, false, true);
		} else if (navigationBaseReference instanceof EntityMapDeclaration) {
			typeInfo = new TypeInfo( ((EntityMapDeclaration) navigationBaseReference).getEntity(), false, false);
		} else if (navigationBaseReference instanceof LambdaVariable) {
			typeInfo = getTargetType((LambdaVariable) navigationBaseReference);
		} else if (navigationBaseReference instanceof QueryParameterDeclaration) {
			typeInfo = new TypeInfo( ((QueryParameterDeclaration) navigationBaseReference).getReferenceType(), false, false);
			typeInfo.modifier = TypeModifier.CONSTANT;
		} else if (navigationBaseReference instanceof PrimitiveDeclaration) {
			typeInfo = new TypeInfo((Persistable) navigationBaseReference, false, true);
		} else {
			typeInfo = new TypeInfo(BaseType.UNDEFINED, false);
			// throw new IllegalArgumentException("Could not determinate type for navigation base reference.");
		}

		return typeInfo;
	}
	
	public static TypeInfo getTargetType(Self self) {
		TypeInfo typeInfo = new TypeInfo(modelExtension.parentContainer(self, EntityDeclaration.class), false, false);
		
		// probably we are in a query
		if (!typeInfo.isEntity()) {
			QueryDeclaration query = modelExtension.parentContainer(self, QueryDeclaration.class);
			
			if (query != null) {
				typeInfo = new TypeInfo(query.getEntity(), false, false);
			}
		}
		
		return typeInfo;
	}
	
	private static TypeInfo getTargetType(NavigationTarget navigationTarget) {
		if (navigationTarget instanceof EntityMemberDeclaration) {
			return getTargetType((EntityMemberDeclaration)navigationTarget);
		} else if (navigationTarget instanceof EntityRelationOppositeInjected) {
			return new TypeInfo((EntityDeclaration) navigationTarget.eContainer().eContainer(), ((EntityRelationOppositeInjected) navigationTarget).isMany(), false);
		}

		throw new IllegalArgumentException("Could not determinate type for navigation target:" + navigationTarget);
	}
	
	public static TypeInfo getTargetType(TypeDescription typeDescription) {
		if (typeDescription == null) {
			return new TypeInfo(BaseType.UNDEFINED, false);
		}

		return new TypeInfo(typeDescription);
	}
	
	public static TypeInfo getTargetType(AnnotationParameterType annotationParameterType) {
		if (annotationParameterType == null) {
			return new TypeInfo(BaseType.UNDEFINED, false);
		}
			
		return new TypeInfo(annotationParameterType);
	}

	public static TypeInfo getTargetType(TransferDataDeclaration transferDataDeclaration) {
		if (transferDataDeclaration instanceof TransferFieldDeclaration) {
			return getTargetType((TransferFieldDeclaration) transferDataDeclaration);
		} else if (transferDataDeclaration instanceof TransferRelationDeclaration) {
			return getTargetType((TransferRelationDeclaration) transferDataDeclaration);
		}

		return new TypeInfo(BaseType.UNDEFINED, false);
	}
	
	public static TypeInfo getTargetType(TransferFieldDeclaration transferFieldDeclaration) {
		if (transferFieldDeclaration == null) {
			return new TypeInfo(BaseType.UNDEFINED, false);
		}

		if (transferFieldDeclaration instanceof ViewTextDeclaration) {
			return new TypeInfo(BaseType.STRING, false);
		}
		
		return new TypeInfo(transferFieldDeclaration.getReferenceType(), false, false);
	}

	public static TypeInfo getTargetType(TransferRelationDeclaration transferRelationDeclaration) {
		if (transferRelationDeclaration == null ||
			transferRelationDeclaration.getReferenceType() == null ||
			transferRelationDeclaration.getReferenceType().getMap() == null ||
			transferRelationDeclaration.getReferenceType().getMap().getEntity() == null)
		{
			return new TypeInfo(BaseType.UNDEFINED, false);
		}

		EntityDeclaration entityDeclaration = transferRelationDeclaration.getReferenceType().getMap().getEntity();
		return new TypeInfo(entityDeclaration, transferRelationDeclaration.isMany(), false);
	}
	
	public static TypeInfo getTargetType(EntityMemberDeclaration entityMemberDeclaration) {
		if (entityMemberDeclaration == null) {
			return new TypeInfo(BaseType.UNDEFINED, false);
		}

		return new TypeInfo(entityMemberDeclaration.getReferenceType(), entityMemberDeclaration.isMany(), false);
	}

	public static TypeInfo getTargetType(QueryDeclaration queryDeclaration) {
		if (queryDeclaration == null) {
			return new TypeInfo(BaseType.UNDEFINED, false);
		}

		return new TypeInfo(queryDeclaration.getReferenceType(), queryDeclaration.isMany(), false);
	}

	public static TypeInfo getTargetType(FunctionDeclaration functionDeclaration) {
		if (functionDeclaration == null) {
			return new TypeInfo(BaseType.UNDEFINED, false);
		}

		return new TypeInfo(functionDeclaration.getReturnType());
	}

	public static TypeInfo getTargetType(Argument argument) {
		if (argument == null) {
			return new TypeInfo(BaseType.UNDEFINED, false);
		}

		ParameterDeclaration parameter = argument.getDeclaration();
		
		if (parameter instanceof FunctionParameterDeclaration) {
			return new TypeInfo( ((FunctionParameterDeclaration) parameter).getDescription());			
		}

		return new TypeInfo(BaseType.UNDEFINED, false);
	}

	private static TypeInfo getTargetType(Parentheses parentheses) {
		TypeInfo typeInfo = getTargetType( parentheses.getExpression() );
		typeInfo.modifier = typeInfo.modifier == TypeModifier.CONSTANT ? TypeModifier.NONE : typeInfo.modifier;
		return typeInfo;
	}
	
	private static TypeInfo getTargetType(TernaryOperation expression) {
		if (expression == null) {
			return new TypeInfo(BaseType.UNDEFINED, false);
		}

		TypeInfo typeInfo = getTargetType( expression.getThenExpression() );
		typeInfo.modifier = typeInfo.modifier == TypeModifier.CONSTANT ? TypeModifier.NONE : typeInfo.modifier;
		return typeInfo;
	}

	public static TypeInfo getTargetType(QueryParameterDeclaration queryParameterDeclaration) {
		if (queryParameterDeclaration == null) {
			return new TypeInfo(BaseType.UNDEFINED, false);
		}

		TypeInfo typeInfo = new TypeInfo(queryParameterDeclaration.getReferenceType(), false, false);
		typeInfo.modifier = TypeModifier.CONSTANT;
		return typeInfo;
	}
	
	public static TypeInfo getTargetType(Literal litreal) {
		if (litreal == null) {
			return new TypeInfo(BaseType.UNDEFINED, false);
		}

		if (litreal instanceof NumberLiteral) {
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
		} else if (litreal instanceof TimestampLiteral) {
			return new TypeInfo(BaseType.TIMESTAMP, true);
		} else if (litreal instanceof EnumLiteralReference) {
			return getTargetType( (EnumLiteralReference) litreal);
		}

	  	throw new IllegalArgumentException("Could not determinate type for expression: " + litreal);
	}
	
	public static TypeInfo getTargetType(Expression expression) {
		if (expression == null) {
			return new TypeInfo(BaseType.UNDEFINED, false);
		}

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