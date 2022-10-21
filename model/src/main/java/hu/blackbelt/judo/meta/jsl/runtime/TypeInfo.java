package hu.blackbelt.judo.meta.jsl.runtime;

import java.util.List;

import org.eclipse.emf.ecore.EObject;

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
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOpposite;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeInjected;
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeReferenced;
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.EscapedStringLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.Expression;
import hu.blackbelt.judo.meta.jsl.jsldsl.Feature;
import hu.blackbelt.judo.meta.jsl.jsldsl.Function;
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionBaseType;
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionCall;
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionReturnType;
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionedExpression;
import hu.blackbelt.judo.meta.jsl.jsldsl.IntegerLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaFunction;
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaFunctionDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaVariable;
import hu.blackbelt.judo.meta.jsl.jsldsl.LiteralFunction;
import hu.blackbelt.judo.meta.jsl.jsldsl.LiteralFunctionDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.LiteralFunctionParameter;
import hu.blackbelt.judo.meta.jsl.jsldsl.Named;
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationBaseExpression;
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationBaseReference;
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationExpression;
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationTarget;
import hu.blackbelt.judo.meta.jsl.jsldsl.PrimitiveDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryCallExpression;
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryDeclaration;
import hu.blackbelt.judo.meta.jsl.jsldsl.RawStringLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.SelfExpression;
import hu.blackbelt.judo.meta.jsl.jsldsl.TimeLiteral;
import hu.blackbelt.judo.meta.jsl.jsldsl.TimeStampLiteral;

public class TypeInfo {
	
	public enum PrimitiveType {
		BOOLEAN, BINARY, STRING, NUMERIC, DATE, TIME, TIMESTAMP 
	}

	boolean isCollection = false;
	boolean isInstance = true;	
	Object type;

	public TypeInfo(Object type, boolean isCollection, boolean isInstance) {
		this.isCollection = isCollection;
		this.type = type;
		this.isInstance = isInstance;
	}

	public boolean isCollection() {
		return isCollection;
	}
	
	public boolean isPrimitive() {
		return (type instanceof PrimitiveType) || (type instanceof DataTypeDeclaration);
	}

	public boolean isEntity() {
		return type instanceof EntityDeclaration;
	}

	public boolean isDataType() {
		return type instanceof DataTypeDeclaration;
	}
	
	public String toString() {
		return "Type: " + type + " Collection: " + isCollection + " Instance: " + isInstance;
	}
	
	public PrimitiveType getPrimitive() {
		if (isEntity()) {
			throw new IllegalStateException("Type is entity");
		}
		if (isDataType()) {
			if (getDataType().getPrimitive().equals("boolean")) {
				return PrimitiveType.BOOLEAN;
			} else if (getDataType().getPrimitive().equals("date")) {
				return PrimitiveType.DATE;
			} else if (getDataType().getPrimitive().equals("time")) {
				return PrimitiveType.TIME;
			} else if (getDataType().getPrimitive().equals("timestamp")) {
				return PrimitiveType.TIMESTAMP;
			} else if (getDataType().getPrimitive().equals("numeric")) {
				return PrimitiveType.NUMERIC;
			} else if (getDataType().getPrimitive().equals("string")) {
				return PrimitiveType.STRING;
			} else if (getDataType().getPrimitive().equals("binary")) {
				return PrimitiveType.BINARY;
			}
			throw new IllegalStateException("Unknown primitive datatype: " + getDataType());
			
		}
		return (PrimitiveType) type;
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

    @SuppressWarnings("unchecked")
	static <T> T parentContainer(EObject from, Class<T> type) {
        T found = null;
        EObject current = from;
        while (found == null && current != null) {
            if (type.isAssignableFrom(current.getClass())) {
                found = (T) current;
            }
            if (current.eContainer() != null) {
                current = current.eContainer();
            } else {
                current = null;
            }
        }
        return found;
    }

	public static String getName(EObject object) {
		if (object == null) {
			return null;
		}
		if (object instanceof Named) {
			return ((Named) object).getName();
		} else {
			throw new IllegalArgumentException("Object is not Named: " + object);
		}
	}
	
	// TODO: JNG-4185

	/*
	enum FunctionBaseType
		: BT_ENTITY_INSTANCE
		| BT_ENTITY_COLLECTION
		| BT_ENUM_LITERAL
		| BT_BOOLEAN_INSTANCE
		| BT_BINARY_INSTANCE
		| BT_STRING_INSTANCE
		| BT_NUMERIC_INSTANCE
		| BT_DATE_INSTANCE
		| BT_TIME_INSTANCE
		| BT_TIMESTAMP_INSTANCE
		| BT_BOOLEAN_TYPE
		| BT_BINARY_TYPE 
		| BT_STRING_TYPE
		| BT_NUMERIC_TYPE
		| BT_DATE_TYPE
		| BT_TIME_TYPE
		| BT_TIMESTAMP_TYPE
		;
	 */
	public static FunctionBaseType getFunctionBaseType(TypeInfo typeInfo) {
		if (typeInfo.isEntity()) {
			if (typeInfo.isCollection) {
				return FunctionBaseType.BT_ENTITY_COLLECTION;
			} else {
				return FunctionBaseType.BT_ENTITY_INSTANCE;								
			}
		} else if (typeInfo.isPrimitive() || typeInfo.isDataType()) {
			if (typeInfo.isInstance) { // || returnType == FunctionReturnType.RT_BASE_TYPE_INSTANCE) {
				if (typeInfo.getPrimitive() == PrimitiveType.BOOLEAN) {
					return FunctionBaseType.BT_BOOLEAN_INSTANCE;
				} else if (typeInfo.getPrimitive() == PrimitiveType.DATE) {
					return FunctionBaseType.BT_DATE_INSTANCE;				
				} else if (typeInfo.getPrimitive() == PrimitiveType.TIME) {
					return FunctionBaseType.BT_TIME_INSTANCE;
				} else if (typeInfo.getPrimitive() == PrimitiveType.TIMESTAMP) {
					return FunctionBaseType.BT_TIMESTAMP_INSTANCE;				
				} else if (typeInfo.getPrimitive() == PrimitiveType.NUMERIC) {
					return FunctionBaseType.BT_NUMERIC_INSTANCE;
				} else if (typeInfo.getPrimitive() == PrimitiveType.STRING) {
					return FunctionBaseType.BT_STRING_INSTANCE;				
				} else if (typeInfo.getPrimitive() == PrimitiveType.BINARY) {
					return FunctionBaseType.BT_BINARY_INSTANCE;				
				}				
			} else if (!typeInfo.isInstance) {
				if (typeInfo.getPrimitive() == PrimitiveType.BOOLEAN) {
					return FunctionBaseType.BT_BOOLEAN_TYPE;
				} else if (typeInfo.getPrimitive() == PrimitiveType.DATE) {
					return FunctionBaseType.BT_DATE_TYPE;				
				} else if (typeInfo.getPrimitive() == PrimitiveType.TIME) {
					return FunctionBaseType.BT_TIME_TYPE;
				} else if (typeInfo.getPrimitive() == PrimitiveType.TIMESTAMP) {
					return FunctionBaseType.BT_TIMESTAMP_TYPE;				
				} else if (typeInfo.getPrimitive() == PrimitiveType.NUMERIC) {
					return FunctionBaseType.BT_NUMERIC_TYPE;
				} else if (typeInfo.getPrimitive() == PrimitiveType.STRING) {
					return FunctionBaseType.BT_STRING_TYPE;				
				} else if (typeInfo.getPrimitive() == PrimitiveType.BINARY) {
					return FunctionBaseType.BT_BINARY_TYPE;				
				}				
			}
		}
		throw new IllegalStateException("Could not determinate function base type: " + typeInfo);		
	}

	/*
	enum FunctionReturnType
		: RT_ENTITY_INSTANCE
		| RT_ENTITY_COLLECTION
		| RT_BASE_TYPE_INSTANCE
		| RT_BASE_TYPE_COLLECTION
		| RT_ENUM_LITERAL
		| RT_BOOLEAN_INSTANCE
		| RT_BINARY_INSTANCE
		| RT_STRING_INSTANCE
		| RT_NUMERIC_INSTANCE
		| RT_DATE_INSTANCE
		| RT_TIME_INSTANCE
		| RT_TIMESTAMP_INSTANCE
		| RT_INPUT_SAME
		;	
	 */
	public static TypeInfo getTargetType(TypeInfo baseTypeInfo, FunctionReturnType functionReturnType) {
		if (functionReturnType == FunctionReturnType.RT_INPUT_SAME) {
			return baseTypeInfo;
		} else if (functionReturnType == FunctionReturnType.RT_ENTITY_INSTANCE) {
			return new TypeInfo(baseTypeInfo.getEntity(), false, true);
		} else if (functionReturnType == FunctionReturnType.RT_ENTITY_COLLECTION) {
			return new TypeInfo(baseTypeInfo.getEntity(), true, true);
		} else if (functionReturnType == FunctionReturnType.RT_BASE_TYPE_INSTANCE) {
			return new TypeInfo(baseTypeInfo.getType(), false, true);
		} else if (functionReturnType == FunctionReturnType.RT_BASE_TYPE_COLLECTION) {
			return new TypeInfo(baseTypeInfo.getType(), true, true);
		} else if (functionReturnType == FunctionReturnType.RT_BOOLEAN_INSTANCE) {
			return new TypeInfo(PrimitiveType.BOOLEAN, false, true);
		} else if (functionReturnType == FunctionReturnType.RT_BINARY_INSTANCE) {
			return new TypeInfo(PrimitiveType.BINARY, false, true);
		} else if (functionReturnType == FunctionReturnType.RT_STRING_INSTANCE) {
			return new TypeInfo(PrimitiveType.STRING, false, true);
		} else if (functionReturnType == FunctionReturnType.RT_NUMERIC_INSTANCE) {
			return new TypeInfo(PrimitiveType.NUMERIC, false, true);
		} else if (functionReturnType == FunctionReturnType.RT_DATE_INSTANCE) {
			return new TypeInfo(PrimitiveType.DATE, false, true);
		} else if (functionReturnType == FunctionReturnType.RT_TIME_INSTANCE) {
			return new TypeInfo(PrimitiveType.TIME, false, true);
		} else if (functionReturnType == FunctionReturnType.RT_TIMESTAMP_INSTANCE) {
			return new TypeInfo(PrimitiveType.TIMESTAMP, false, true);
		}
		throw new IllegalArgumentException("Could not determinate function return type: " + functionReturnType.getName());
	}

	public static TypeInfo getTargetType(EntityFieldDeclaration entityFieldDeclaration) {
		return new TypeInfo(entityFieldDeclaration.getReferenceType(), entityFieldDeclaration.isIsMany(), true);
	}

	public static TypeInfo getTargetType(EntityIdentifierDeclaration entityFieldDeclaration) {
		return new TypeInfo(entityFieldDeclaration.getReferenceType(), false, true);
	}

	public static TypeInfo getTargetType(EntityRelationDeclaration entityRelationDeclaration) {
		return new TypeInfo(entityRelationDeclaration.getReferenceType(), entityRelationDeclaration.isIsMany(), true);
	}

	public static TypeInfo getTargetType(EntityDerivedDeclaration entityDerivedDeclaration) {
		return new TypeInfo(entityDerivedDeclaration.getReferenceType(), entityDerivedDeclaration.isIsMany(), true);
	}

	public static TypeInfo getTargetType(EntityQueryDeclaration entityQueryDeclaration) {
		return new TypeInfo(entityQueryDeclaration.getReferenceType(), entityQueryDeclaration.isIsMany(), true);
	}

	public static TypeInfo getTargetType(QueryDeclaration queryDeclaration) {
		return new TypeInfo(queryDeclaration.getReferenceType(), queryDeclaration.isIsMany(), true);
	}

	public static TypeInfo getTargetType(EnumDeclaration enumDeclaration, boolean isType) {
		return new TypeInfo(enumDeclaration, false, isType);
	}

	public static TypeInfo getTargetType(DataTypeDeclaration dataTypeDeclaration, boolean isType) {
		return new TypeInfo(dataTypeDeclaration, false, isType);
	}

	/*
	EntityMemberDeclaration
		: (EntityFieldDeclaration
		| EntityIdentifierDeclaration
		| EntityRelationDeclaration
		| EntityDerivedDeclaration
		| EntityQueryDeclaration
		| ConstraintDeclaration)
		  ';'*
		;
	*/
	public static TypeInfo getTargetType(EntityMemberDeclaration entityMemberDeclaration) {
		if (entityMemberDeclaration instanceof EntityFieldDeclaration) {
			return getTargetType((EntityFieldDeclaration) entityMemberDeclaration);
		} else if (entityMemberDeclaration instanceof EntityIdentifierDeclaration) {
			return getTargetType((EntityIdentifierDeclaration) entityMemberDeclaration);
		} else if (entityMemberDeclaration instanceof EntityRelationDeclaration) {
			return getTargetType((EntityRelationDeclaration) entityMemberDeclaration);
		} else if (entityMemberDeclaration instanceof EntityDerivedDeclaration) {
			return getTargetType((EntityDerivedDeclaration) entityMemberDeclaration);
		} else if (entityMemberDeclaration instanceof EntityQueryDeclaration) {
			return getTargetType((EntityQueryDeclaration) entityMemberDeclaration);
		}
		throw new IllegalArgumentException("Could not determinate type for entity member: " + getName(entityMemberDeclaration));
	}

	
	/*
		EntityRelationOppositeInjected
			: 'opposite-add' Named Cardinality?
			;
	 */
	public static TypeInfo getTargetType(EntityRelationOppositeInjected entityRelationOppositeInjected, boolean isMany) {
		return new TypeInfo((EntityDeclaration) entityRelationOppositeInjected.eContainer(), isMany, true);
	}
	
	/*
		EntityRelationOppositeReferenced
			: 'opposite' oppositeType = [EntityRelationDeclaration | LocalName]
			;
	 */
	public static TypeInfo getTargetType(EntityRelationOppositeReferenced entityRelationOppositeReferenced, boolean isMany) {
		return new TypeInfo(entityRelationOppositeReferenced.getOppositeType(), isMany, true);
	}

	/*
		EntityRelationOpposite
			: EntityRelationOppositeInjected
			| EntityRelationOppositeReferenced
			;
	 */
	public static TypeInfo getTargetType(EntityRelationOpposite entityRelationOpposite, boolean isMany) {
		if (entityRelationOpposite instanceof EntityRelationOppositeInjected) {
			return getTargetType((EntityRelationOppositeInjected) entityRelationOpposite);
		} else if (entityRelationOpposite instanceof EntityRelationOppositeInjected) {
			return getTargetType((EntityRelationOppositeInjected) entityRelationOpposite);			
		}
		throw new IllegalArgumentException("Could not determinate type for entity relation opposite: " + getName(entityRelationOpposite));
	}
	
	public static TypeInfo getTargetType(EntityDeclaration entityDeclaration, boolean isMany, boolean isType) {
		return new TypeInfo(entityDeclaration, isMany, isType);
	}
	
	/*
		NavigationTarget
		    : EntityMemberDeclaration
		    | EntityDeclaration
		    | EntityRelationOppositeInjected
		    ;
	*/	
	public static TypeInfo getTargetType(NavigationTarget navigationTarget) {
		if (navigationTarget instanceof EntityMemberDeclaration) {
			return getTargetType((EntityMemberDeclaration) navigationTarget);
		} else if (navigationTarget instanceof EntityDeclaration) {
			return getTargetType((EntityDeclaration) navigationTarget, false, false);
		} else if (navigationTarget instanceof EntityRelationOppositeInjected) {
			return getTargetType((EntityRelationOppositeInjected) navigationTarget, false);			
		}
		throw new IllegalArgumentException("Could not determinate type for navigation target: " + getName(navigationTarget));
	}

	/*
		PrimitiveDeclaration
			: EnumDeclaration
			| DataTypeDeclaration
		    ;
	 */
	public static TypeInfo getTargetType(PrimitiveDeclaration primitiveDeclaration, boolean isType) {
		if (primitiveDeclaration instanceof EnumDeclaration) {
			return getTargetType((EnumDeclaration) primitiveDeclaration, isType);
		} else if (primitiveDeclaration instanceof DataTypeDeclaration) {
			return getTargetType((DataTypeDeclaration) primitiveDeclaration, isType);
		}
		throw new IllegalArgumentException("Could not determinate type for primitive declaration: " + getName(primitiveDeclaration));
	}
	
	/*
		NavigationBaseReference
			: EntityDeclaration
			| QueryDeclaration
			| LambdaVariable
			| QueryDeclarationParameter
			| PrimitiveDeclaration
			;	
	 */
	public static TypeInfo getTargetType(NavigationBaseReference navigationBaseReference) {
		if (navigationBaseReference instanceof EntityDeclaration) {
			return getTargetType((EntityDeclaration) navigationBaseReference, true, true);
		} else if (navigationBaseReference instanceof QueryDeclaration) {
			return getTargetType((QueryDeclaration) navigationBaseReference);
		} else if (navigationBaseReference instanceof LambdaVariable) {
			return getTargetType(parentContainer(navigationBaseReference, FunctionCall.class));
//		} else if (navigationBaseReference instanceof QueryDeclarationParameter) {
//			return getTargetType(parentContainer(navigationBaseReference, FunctionCall.class));
		} else if (navigationBaseReference instanceof PrimitiveDeclaration) {
			return getTargetType((PrimitiveDeclaration) navigationBaseReference, false);
		}
		throw new IllegalArgumentException("Could not determinate type for navigation base reference: " + getName(navigationBaseReference));
	}
	
	public static TypeInfo getParentFunctionCallReturnType(FunctionCall functionCall) {
		if (functionCall.eContainer() instanceof FunctionedExpression) {
			return getTargetType(((FunctionedExpression) functionCall.eContainer()).getOperand());
		} else if (functionCall.eContainer() instanceof FunctionCall) {
			return getLastFeatureTargetType(functionCall.eContainer(), ((FunctionCall) functionCall.eContainer()).getFeatures(), false);
		} 
		throw new IllegalArgumentException("Could not determinate function call return type: " + functionCall);		
	}
	
	public static TypeInfo getTargetType(LiteralFunction literalFunction) {
		FunctionCall functionCall = (FunctionCall) literalFunction.eContainer();
		TypeInfo baseType = getParentFunctionCallReturnType(functionCall);
		
		LiteralFunctionDeclaration spec = literalFunction.getFunctionDeclarationReference();

		FunctionBaseType functionBaseType = getFunctionBaseType(baseType);		
		if (!spec.getAcceptedBaseTypes().contains(functionBaseType)) {
			throw new IllegalArgumentException("Given base type is not accepted: " + functionBaseType);			
		}

		if (spec.getName().equals("asType")) {
			LiteralFunctionParameter functionParameter = literalFunction.getParameters().stream()
				.filter(p -> p.getDeclaration().getName().equals("entityType")).findFirst()
				.orElseThrow(() -> new IllegalArgumentException("Function asType does not have entityType parameter"));
			return getTargetType(functionParameter.getExpression());
		} else {
			// Return type can be collection?
			FunctionReturnType returnType = spec.getReturnTypes().get(0);
			return getTargetType(baseType, returnType);
		}

	}

	public static TypeInfo getTargetType(LambdaFunction lambdaFunction) {
		FunctionCall functionCall = (FunctionCall) lambdaFunction.eContainer();
		TypeInfo baseType = getParentFunctionCallReturnType(functionCall);	

		LambdaFunctionDeclaration spec = lambdaFunction.getFunctionDeclarationReference();

		FunctionBaseType functionBaseType = getFunctionBaseType(baseType);		
		if (!spec.getAcceptedBaseTypes().contains(functionBaseType)) {
			throw new IllegalArgumentException("Given base type is not accepted: " + functionBaseType);			
		}

		// Return type can be collection?
		FunctionReturnType returnType = spec.getReturnTypes().get(0);
		return getTargetType(baseType, returnType);
	}


	/*
	Function
		: LiteralFunction
		| LambdaFunction
		;
	*/
	public static TypeInfo getTargetType(Function function) {
		if (function instanceof LiteralFunction) {		
			return getTargetType((LiteralFunction) function);
		} else if (function instanceof LambdaFunction) {
			return getTargetType((LambdaFunction) function);
		}
		throw new IllegalArgumentException("Could not determinate type for function: " + getName(function));
	}
	
	
	/*
	FunctionCall
		: {FunctionCall} '!' function=Function features+=Feature* call=FunctionCall?
	
	*/
	public static TypeInfo getTargetType(FunctionCall functionCall) {
		if (functionCall.getCall() != null) {
			return getTargetType(functionCall.getCall());			
		} else {
			return getTargetType(functionCall.getFunction());
		}
	}

				
//	public static TypeInfo getEntityMemberDeclarationReferences(EntityMemberDeclaration entityMemberDeclaration) {
//		return getTargetType(entityMemberDeclaration);
//	}


//	public static TypeInfo getTargetType(QueryDeclaration queryDeclaration) {
//		return new TypeInfo(queryDeclaration.getReferenceType(), queryDeclaration.isIsMany());
//	}

	
	public static TypeInfo getTargetType(QueryCallExpression queryCallExpression) {
		return getTargetType(queryCallExpression.getQueryDeclarationType());
	}

	public static TypeInfo getTargetType(SelfExpression selfExpression) {
		return getTargetType((EntityDeclaration) parentContainer(selfExpression, EntityDeclaration.class), false, true);
	}

	/*
	NavigationExpression returns Expression
		: SelfExpression
		| NavigationBaseExpression
		| QueryCallExpression
		;
	 */	
	public static TypeInfo getTargetType(NavigationExpression navigationExpression) {
		if (navigationExpression instanceof SelfExpression) {
			SelfExpression selfExpression = (SelfExpression) navigationExpression;
			return getLastFeatureTargetType(selfExpression, selfExpression.getFeatures(), true);
		} else if (navigationExpression instanceof NavigationBaseExpression) {
			NavigationBaseExpression navigationBase = (NavigationBaseExpression) navigationExpression;
			return getLastFeatureTargetType(navigationBase, navigationBase.getFeatures(), true);
		} else if (navigationExpression instanceof QueryCallExpression) {
			QueryCallExpression queryCall = (QueryCallExpression) navigationExpression;
			return getLastFeatureTargetType(queryCall, queryCall.getFeatures(), true);
		}
		throw new IllegalArgumentException("Could not determinate type for navigation expression: " + navigationExpression);
	}

	public static TypeInfo getTargetType(FunctionedExpression functionedExpression) {
		return getTargetType(functionedExpression.getFunctionCall());
		//return getTargetType(functionedExpression.getOperand());
	}

	/*
		FunctionedExpression returns Expression
			: FunctionableExpression ({FunctionedExpression.operand=current} functionCall=FunctionCall)?
			| ParenthesizedExpression
			| EnumLiteralReference
		    ;

		NavigationExpression returns Expression
			: SelfExpression
			| NavigationBaseExpression
			| QueryCallExpression
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
	public static TypeInfo getTargetType(Expression expression) {
		if (expression instanceof FunctionedExpression) {
			return getTargetType((FunctionedExpression) expression);
		} else if (expression instanceof NavigationExpression) {			
			return getTargetType((NavigationExpression) expression);
		} else if (expression instanceof IntegerLiteral) {
			return new TypeInfo(TypeInfo.PrimitiveType.NUMERIC, false, true);
		} else if (expression instanceof DecimalLiteral) {
			return new TypeInfo(TypeInfo.PrimitiveType.NUMERIC, false, true);
		} else if (expression instanceof BooleanLiteral) {
			return new TypeInfo(TypeInfo.PrimitiveType.BOOLEAN, false, true);
		} else if (expression instanceof EscapedStringLiteral) {
			return new TypeInfo(TypeInfo.PrimitiveType.STRING, false, true);
		} else if (expression instanceof RawStringLiteral) {
			return new TypeInfo(TypeInfo.PrimitiveType.STRING, false, true);
		} else if (expression instanceof DateLiteral) {
			return new TypeInfo(TypeInfo.PrimitiveType.DATE, false, true);
		} else if (expression instanceof TimeLiteral) {
			return new TypeInfo(TypeInfo.PrimitiveType.TIME, false, true);
		} else if (expression instanceof TimeStampLiteral) {
			return new TypeInfo(TypeInfo.PrimitiveType.TIMESTAMP, false, true);
		}
		throw new IllegalArgumentException("Could not determinate type for expression: " + expression);
	}

		
	public static TypeInfo getLastFeatureTargetType(EObject context, List<Feature> features, boolean traverseDown) {
		if (features != null && features.size() > 0 && features.get(features.size() - 1).getNavigationTargetType() != null) {
			NavigationTarget navigationTarget = features.get(features.size() - 1).getNavigationTargetType();
			return getTargetType(navigationTarget);
		} else if (context instanceof NavigationBaseExpression) {
			return getTargetType(((NavigationBaseExpression) context).getNavigationBaseType());
		} else if (context instanceof FunctionCall) {
			if (traverseDown) {
				return getTargetType((FunctionCall) context);				
			} else {
				return getTargetType(((FunctionCall) context).getFunction());				
			}
		} else if (context instanceof QueryCallExpression) {
			return getTargetType((QueryCallExpression) context);
		}
		throw new IllegalArgumentException("Could not determinate type for last feature: " + context);
	}

	public static TypeInfo getFeatureScopeForNavigationTargetTypeReferences(Feature featureToScope, NavigationExpression navigationExpression) {
		if (featureToScope != null && featureToScope.getNavigationTargetType() != null) {
			if (featureToScope.getNavigationTargetType() instanceof EntityMemberDeclaration) {
				return getTargetType((EntityMemberDeclaration) featureToScope.getNavigationTargetType());
			}
		} else {
			return getTargetType(navigationExpression);
		}
		return null;				
	}

	public static TypeInfo getFunctionCallExpressionTargetTypeReferences(Feature featureToScope, FunctionCall functionCall) {
		if (featureToScope != null && featureToScope.getNavigationTargetType() != null) {
			if (featureToScope.getNavigationTargetType() instanceof EntityMemberDeclaration) {
				return getTargetType(featureToScope.getNavigationTargetType());
			}
		} else {
			return getTargetType(functionCall);
		}		
		return null;
	}
	
	public static TypeInfo getQueryCallExpressionTargetTypeReferences(Feature featureToScope, QueryCallExpression queryCallExpression) {
		if (featureToScope != null && featureToScope.getNavigationTargetType() != null) {
			if (featureToScope.getNavigationTargetType() instanceof EntityMemberDeclaration) {
				return getTargetType(featureToScope.getNavigationTargetType());
			}
		} else {
			return getTargetType(queryCallExpression);
		}		
		return null;
	}


	public static Feature getPreviousFeature(Feature context, List<Feature> features) {
		Feature featureToScope = null;
		int contextIndex = features.indexOf(context) - 1;
		if (contextIndex > -1) {
			featureToScope = features.get(contextIndex);
		}			
		return featureToScope;
	}
	
	
	public static TypeInfo getTargetType(Feature context) {		
		if (context.eContainer() instanceof SelfExpression) {
			return 
					getFeatureScopeForNavigationTargetTypeReferences(
						getPreviousFeature(context, ((SelfExpression) context.eContainer()).getFeatures()),
						(SelfExpression) context.eContainer()
					);
					
		} else if (context.eContainer() instanceof NavigationBaseExpression) {
			return 
					getFeatureScopeForNavigationTargetTypeReferences(
							getPreviousFeature(context, ((NavigationBaseExpression) context.eContainer()).getFeatures()),
							(SelfExpression) context.eContainer()
						);
		} else if (context.eContainer() != null && context.eContainer() instanceof FunctionCall) {
			return 
					getFunctionCallExpressionTargetTypeReferences(
							getPreviousFeature(context, ((NavigationBaseExpression) context.eContainer()).getFeatures()),
							(FunctionCall) context.eContainer()
						);

		} else if (context.eContainer() instanceof QueryCallExpression) {
			return
					getQueryCallExpressionTargetTypeReferences(
						getPreviousFeature(context, ((QueryCallExpression) context.eContainer()).getFeatures()),
						(QueryCallExpression) context.eContainer()
					);
		}
		return null;
	}
}