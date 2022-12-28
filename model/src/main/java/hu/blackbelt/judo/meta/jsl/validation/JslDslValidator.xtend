package hu.blackbelt.judo.meta.jsl.validation

import org.eclipse.xtext.validation.Check
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.naming.IQualifiedNameConverter
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension
import org.eclipse.xtext.validation.CheckType
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import hu.blackbelt.judo.meta.jsl.scoping.JslDslIndex
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityMemberDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.Declaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ModifierMaxSize
import hu.blackbelt.judo.meta.jsl.jsldsl.ModifierMinSize
import java.math.BigInteger
import hu.blackbelt.judo.meta.jsl.jsldsl.ModifierPrecision
import hu.blackbelt.judo.meta.jsl.jsldsl.ModifierScale
import hu.blackbelt.judo.meta.jsl.jsldsl.DataTypeDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityIdentifierDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.Named
import hu.blackbelt.judo.meta.jsl.jsldsl.BinaryOperation
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeInjected
import hu.blackbelt.judo.meta.jsl.jsldsl.MimeType
import java.util.regex.Pattern
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelImportDeclaration
import java.util.Arrays
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDerivedDeclaration
import hu.blackbelt.judo.meta.jsl.runtime.TypeInfo
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityQueryDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TernaryOperation
import hu.blackbelt.judo.meta.jsl.jsldsl.UnaryOperation
import java.util.Iterator
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionParameterDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionCall
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionArgument
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaCall
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryArgument
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryCall
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.common.util.EList
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityQueryCall
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryParameterDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryDeclaration
import org.eclipse.emf.ecore.util.EcoreUtil
import hu.blackbelt.judo.meta.jsl.jsldsl.Feature
import hu.blackbelt.judo.meta.jsl.jsldsl.MemberReference
import hu.blackbelt.judo.meta.jsl.jsldsl.Expression
import java.util.ArrayList
import hu.blackbelt.judo.meta.jsl.jsldsl.Self

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
 
/* TODO: self validation must be implemented */
 
class JslDslValidator extends AbstractJslDslValidator {

	protected static val ISSUE_CODE_PREFIX = "hu.blackbelt.judo.meta.jsl.jsldsl."
	public static val HIERARCHY_CYCLE = ISSUE_CODE_PREFIX + "HierarchyCycle"
	public static val DUPLICATE_MODEL = ISSUE_CODE_PREFIX + "DuplicateModel"
	public static val OPPOSITE_TYPE_MISMATH = ISSUE_CODE_PREFIX + "OppositeTypeMismatch"
	public static val DUPLICATE_MEMBER_NAME = ISSUE_CODE_PREFIX + "DuplicateMemberName"
	public static val MEMBER_NAME_TOO_LONG = ISSUE_CODE_PREFIX + "MemberNameTooLong"
	public static val DUPLICATE_DECLARATION_NAME = ISSUE_CODE_PREFIX + "DuplicateDeclarationName"
	public static val INHERITENCE_CYCLE = ISSUE_CODE_PREFIX + "InheritenceCycle"
	public static val INHERITED_MEMBER_NAME_COLLISION = ISSUE_CODE_PREFIX + "InheritedMemberNameCollision"
	public static val ENUM_LITERAL_NAME_COLLISION = ISSUE_CODE_PREFIX + "EnumLiteralNameCollision"
	public static val ENUM_LITERAL_ORDINAL_COLLISION = ISSUE_CODE_PREFIX + "EnumLiteralOrdinalCollision"
	public static val MAX_SIZE_MODIFIER_IS_NEGATIVE = ISSUE_CODE_PREFIX + "MaxSizeIsNegative"
	public static val MIN_SIZE_MODIFIER_IS_NEGATIVE = ISSUE_CODE_PREFIX + "MinSizeIsNegative"
	public static val INVALID_MIMETYPE = ISSUE_CODE_PREFIX + "MimetypeIsInvalid"
	public static val PRECISION_MODIFIER_IS_NEGATIVE = ISSUE_CODE_PREFIX + "PrecisionIsNegative"
	public static val SCALE_MODIFIER_IS_NEGATIVE = ISSUE_CODE_PREFIX + "ScaleIsNegative"
	public static val MAX_SIZE_MODIFIER_IS_TOO_LARGE = ISSUE_CODE_PREFIX + "MaxSizeIsTooLarge"
	public static val MIN_SIZE_MODIFIER_IS_TOO_LARGE = ISSUE_CODE_PREFIX + "MinSizeIsTooLarge"
	public static val PRECISION_MODIFIER_IS_TOO_LARGE = ISSUE_CODE_PREFIX + "PrecisionIsTooLarge"
	public static val SCALE_MODIFIER_IS_TOO_LARGE = ISSUE_CODE_PREFIX + "ScaleIsLargerThanPrecision"
	public static val USING_REQUIRED_WITH_IS_MANY = ISSUE_CODE_PREFIX + "UsingRequiredWithIsMany"
	public static val TYPE_MISMATCH = ISSUE_CODE_PREFIX + "TypeMismatch"
	public static val ENUM_MEMBER_MISSING = ISSUE_CODE_PREFIX + "EnumMemberMissing"
	public static val DUPLICATE_PARAMETER = ISSUE_CODE_PREFIX + "DuplicateParameter"
	public static val MISSING_REQUIRED_PARAMETER = ISSUE_CODE_PREFIX + "MissingRequiredParameter"
	public static val INVALID_LAMBDA_EXPRESSION = ISSUE_CODE_PREFIX + "InvalidLambdaExpression"
	public static val IMPORT_ALIAS_COLLISION = ISSUE_CODE_PREFIX + "ImportAliasCollison"
	public static val HIDDEN_DECLARATION = ISSUE_CODE_PREFIX + "HiddenDeclaration"
	public static val INVALID_DECLARATION = ISSUE_CODE_PREFIX + "InvalidDeclaration"
	public static val EXPRESSION_CYCLE = ISSUE_CODE_PREFIX + "ExpressionCycle"
	public static val SELF_NOT_ALLOWED = ISSUE_CODE_PREFIX + "SelfNotAllowed"

	public static val MEMBER_NAME_LENGTH_MAX = 128
	public static val MODIFIER_MAX_SIZE_MAX_VALUE = BigInteger.valueOf(4000)
	public static val PRECISION_MAX_VALUE = BigInteger.valueOf(15)


	@Inject extension IQualifiedNameProvider
	@Inject extension IQualifiedNameConverter
	@Inject extension JslDslModelExtension
	@Inject extension JslDslIndex
	
	
	// perform this check only on file save
	@Check(CheckType::NORMAL)
	def checkDuplicateModelsInFiles(ModelDeclaration modelDeclaration) {
		val className = modelDeclaration.fullyQualifiedName
		modelDeclaration.getVisibleClassesDescriptions.forEach[
			desc |
			if (desc.qualifiedName == className && 
					desc.EObjectOrProxy != modelDeclaration && 
					desc.EObjectURI.trimFragment != modelDeclaration.eResource.URI) {
				error(
					"The model '" + modelDeclaration.name + "' is already defined",
					JsldslPackage::eINSTANCE.modelDeclaration_Name,
					HIERARCHY_CYCLE,
					modelDeclaration.name
				)
				return
			}
		]
	}
    
    def void findExpressionCycle(Expression expression, ArrayList<Expression> visited) {
		if (visited.size > 0 && expression.equals(visited.get(0))) {
    		throw new IllegalCallerException
		}

    	if (visited.contains(expression)) {
    		return
    	}

		visited.add(expression)
    	
    	val Iterator<QueryCall> queryCallIterator = EcoreUtil.getAllContents(expression, true).filter(QueryCall)
		while (queryCallIterator.hasNext) {
			val QueryCall queryCall = queryCallIterator.next()
			
			if (queryCall.declaration !== null && queryCall.declaration.expression !== null) {
				findExpressionCycle(queryCall.declaration.expression, visited)
			}
		}
    	
    	val Iterator<Feature> featureIterator = EcoreUtil.getAllContents(expression, true).filter(Feature)
		while (featureIterator.hasNext) {
			val EObject obj = featureIterator.next()

			if (obj instanceof MemberReference && (obj as MemberReference).member instanceof EntityDerivedDeclaration) {
				val EntityDerivedDeclaration derived = (obj as MemberReference).member as EntityDerivedDeclaration
				if (derived.expression !== null) {
					findExpressionCycle(derived.expression, visited)
				}
			} else if (obj instanceof EntityQueryCall) {
				if (obj.declaration !== null && obj.declaration.expression !== null) {
					findExpressionCycle(obj.declaration.expression, visited)
				}
			}
		}
		
		visited.remove(expression)
    }
    
    @Check
    def checkCyclicDerivedExpression(EntityDerivedDeclaration derived) {
    	if (derived.expression !== null) {
    		try {
    			findExpressionCycle(derived.expression, new ArrayList<Expression>())
    		} catch (IllegalCallerException e) {
				error(
					"Cyclic expression",
					JsldslPackage::eINSTANCE.entityDerivedDeclaration_Expression,
					EXPRESSION_CYCLE,
					derived.name
				)
				return
    		}
    	}
    }
    
    @Check
    def checkCyclicEntityQueryExpression(EntityQueryDeclaration query) {
    	if (query.expression !== null) {
    		try {
    			findExpressionCycle(query.expression, new ArrayList<Expression>())
    		} catch (IllegalCallerException e) {
				error(
					"Cyclic expression",
					JsldslPackage::eINSTANCE.entityQueryDeclaration_Expression,
					EXPRESSION_CYCLE,
					query.name
				)
				return
    		}
    	}
    }

    @Check
    def checkCyclicStaticQueryExpression(QueryDeclaration query) {
    	if (query.expression !== null) {
    		try {
    			findExpressionCycle(query.expression, new ArrayList<Expression>())
    		} catch (IllegalCallerException e) {
				error(
					"Cyclic expression",
					JsldslPackage::eINSTANCE.queryDeclaration_Expression,
					EXPRESSION_CYCLE,
					query.name
				)
				return
    		}
    	}
    }
    
    @Check
    def checkSelfInDefaultExpression(EntityFieldDeclaration field) {
    	if (field.defaultExpression !== null) {
	    	val Iterator<Self> iter = EcoreUtil.getAllContents(field.defaultExpression, true).filter(Self)

			if (iter.hasNext) {
				error(
					"Self is not allowed in default expression",
					JsldslPackage::eINSTANCE.entityFieldDeclaration_DefaultExpression,
					SELF_NOT_ALLOWED,
					field.name
				)
				return
			}
    	}
	}

	@Check
	def checkInvalidFunctionDeclaration(FunctionDeclaration functionDeclaration) {
		val ModelDeclaration modelDeclaration = functionDeclaration.eContainer as ModelDeclaration
		if (!modelDeclaration.fullyQualifiedName.equals("judo::functions")) {
			error("Invalid function declaration '" + functionDeclaration.name + "'",
				JsldslPackage::eINSTANCE.named_Name,
				INVALID_DECLARATION,
				functionDeclaration.name)
		}
	}
      
	@Check
	def checkInvalidLambdaDeclaration(LambdaDeclaration lambdaDeclaration) {
		val ModelDeclaration modelDeclaration = lambdaDeclaration.eContainer as ModelDeclaration
		if (!modelDeclaration.fullyQualifiedName.equals("judo::functions")) {
			error("Invalid lambda declaration '" + lambdaDeclaration.name + "'",
				JsldslPackage::eINSTANCE.named_Name,
				INVALID_DECLARATION,
				lambdaDeclaration.name)
		}
	}

    @Check
	def checkImportAlias(ModelImportDeclaration modelImport) {
		if (modelImport.alias !== null) {
			if ((modelImport.eContainer as ModelDeclaration).imports.filter[i | i.model.name.toLowerCase.equals(modelImport.alias.toLowerCase)].size > 0) {
				error("Alias name collision '" + modelImport.alias + "'",
					JsldslPackage::eINSTANCE.modelImportDeclaration_Alias,
					IMPORT_ALIAS_COLLISION,
					modelImport.alias)
			}
	
			if ((modelImport.eContainer as ModelDeclaration).imports.filter[i | i.alias !== null && i.alias.toLowerCase.equals(modelImport.alias.toLowerCase)].size > 1) {
				error("Alias name collision '" + modelImport.alias + "'",
					JsldslPackage::eINSTANCE.modelImportDeclaration_Alias,
					IMPORT_ALIAS_COLLISION,
					modelImport.alias)
			}
		}
	}
    
	@Check
	def checkSelfImport(ModelImportDeclaration modelImport) {
		//System.out.println("checkSelfImport: " + modelImport.importedNamespace + " " + modelImport.eContainer().fullyQualifiedName.toString("::"))
		
		if (modelImport.model === null) {
			return
		}

		if (modelImport.model.name === null) {
			return
		}

		if (modelImport.model.name.toQualifiedName.equals(modelImport.eContainer().fullyQualifiedName)) {
			//System.out.println("==== ERROR: " + modelImport.importedNamespace)
			error("Cycle in hierarchy of model '" + modelImport.model.name + "'",
				JsldslPackage::eINSTANCE.modelImportDeclaration_Model,
				HIERARCHY_CYCLE,
				modelImport.model.name)
		}
	}

	@Check
	def checkHiddenDeclaration(Declaration declaration) {
		for (importDeclaration : (declaration.eContainer as ModelDeclaration).imports.filter[i | i.alias === null]) {
			if (importDeclaration.model.declarations.exists[d | d.name.equals(declaration.name)]) {
				warning("Declaration possibly hides other declaration in import '" + importDeclaration.model.name + "'",
					JsldslPackage::eINSTANCE.named_Name,
					HIDDEN_DECLARATION,
					declaration.name)				
			}
		}
	} 

	@Check
	def checkQueryArgument(QueryArgument argument) {
		if (argument.expression !== null && argument.declaration !== null) {
			val TypeInfo exprTypeInfo = TypeInfo.getTargetType(argument.expression);
			val TypeInfo declarationTypeInfo = TypeInfo.getTargetType(argument.declaration);

			if (!declarationTypeInfo.isCompatible(exprTypeInfo)) {
				error("Type mismatch",
	                JsldslPackage::eINSTANCE.queryArgument_Expression,
	                TYPE_MISMATCH,
	                JsldslPackage::eINSTANCE.queryArgument.name)
			}

			if (declarationTypeInfo.constant && !exprTypeInfo.constant) {
				error("Right value must be constant",
	                JsldslPackage::eINSTANCE.queryArgument_Expression,
	                TYPE_MISMATCH,
	                JsldslPackage::eINSTANCE.queryArgument.name)
			}
		}

		val EObject container = argument.eContainer;
		var EList<QueryArgument> arguments;
		
		if (container instanceof QueryCall) {
			arguments = (container as QueryCall).arguments;
		} else {
			arguments = (container as EntityQueryCall).arguments;
		}

		if (arguments.filter[a | a.declaration.isEqual(argument.declaration)].size > 1) {
			error("Duplicate query parameter:" + argument.declaration.name,
                JsldslPackage::eINSTANCE.queryArgument_Declaration,
                DUPLICATE_PARAMETER,
                JsldslPackage::eINSTANCE.queryArgument.name)
		}
	}

	@Check
	def checkEntityQueryRequiredArguments(EntityQueryCall entityQueryCall) {
		val EntityQueryDeclaration entityQueryDeclaration = entityQueryCall.declaration;
		val Iterator<QueryParameterDeclaration> itr = entityQueryDeclaration.parameters.iterator;

		while (itr.hasNext) {
			val QueryParameterDeclaration declaration = itr.next;

			if (declaration.getDefault() === null && !entityQueryCall.arguments.exists[a | a.declaration.isEqual(declaration)]) {
				error("Missing required query parameter:" + declaration.name,
	                JsldslPackage::eINSTANCE.entityQueryCall_Arguments,
	                MISSING_REQUIRED_PARAMETER,
	                JsldslPackage::eINSTANCE.entityQueryCall.name)
			}
		}
	}

	@Check
	def checkQueryRequiredArguments(QueryCall queryCall) {
		val QueryDeclaration queryDeclaration = queryCall.declaration;
		val Iterator<QueryParameterDeclaration> itr = queryDeclaration.parameters.iterator;

		while (itr.hasNext) {
			val QueryParameterDeclaration declaration = itr.next;

			if (declaration.getDefault() === null && !queryCall.arguments.exists[a | a.declaration.isEqual(declaration)]) {
				error("Missing required query parameter:" + declaration.name,
	                JsldslPackage::eINSTANCE.queryCall_Arguments,
	                MISSING_REQUIRED_PARAMETER,
	                JsldslPackage::eINSTANCE.queryCall.name)
			}
		}
	}

	@Check
	def checkFunctionArgument(FunctionArgument argument) {
		if (argument.expression !== null && argument.declaration !== null && argument.declaration.description !== null) {
			val TypeInfo exprTypeInfo = TypeInfo.getTargetType(argument.expression);
			val TypeInfo declarationTypeInfo = TypeInfo.getTargetType(argument.declaration.description);

			if (!declarationTypeInfo.isCompatible(exprTypeInfo)) {
				error("Type mismatch",
	                JsldslPackage::eINSTANCE.functionArgument_Expression,
	                TYPE_MISMATCH,
	                JsldslPackage::eINSTANCE.functionArgument.name)
			}

			if (declarationTypeInfo.constant && !exprTypeInfo.constant) {
				error("Right value must be constant",
	                JsldslPackage::eINSTANCE.functionArgument_Expression,
	                TYPE_MISMATCH,
	                JsldslPackage::eINSTANCE.functionArgument.name)
			}
		}

		val FunctionCall functionCall = argument.eContainer as FunctionCall;

		if (functionCall.arguments.filter[a | a.declaration.isEqual(argument.declaration)].size > 1) {
			error("Duplicate function parameter:" + argument.declaration.name,
                JsldslPackage::eINSTANCE.functionArgument_Declaration,
                DUPLICATE_PARAMETER,
                JsldslPackage::eINSTANCE.functionArgument.name)
		}
	}

	@Check
	def checkFunctionRequiredArguments(FunctionCall functionCall) {
		val FunctionDeclaration functionDeclaration = functionCall.declaration;
		val Iterator<FunctionParameterDeclaration> itr = functionDeclaration.parameters.filter[p | p.isRequired].iterator;

		while (itr.hasNext) {
			val FunctionParameterDeclaration declaration = itr.next;

			if (!functionCall.arguments.exists[a | a.declaration.isEqual(declaration)]) {
				error("Missing required function parameter:" + declaration.name,
	                JsldslPackage::eINSTANCE.functionCall_Arguments,
	                MISSING_REQUIRED_PARAMETER,
	                JsldslPackage::eINSTANCE.functionCall.name)
			}
		}
	}

	@Check
	def checkLambdaExpression(LambdaCall lambdaCall) {		
		if (lambdaCall.lambdaExpression !== null) {
			val lambdaExpressionTypeInfo = TypeInfo.getTargetType(lambdaCall.lambdaExpression)
			
			if (lambdaCall.declaration.expressionType === null && !lambdaExpressionTypeInfo.orderable) {
				error("Lambda expression must be orderable",
	                JsldslPackage::eINSTANCE.lambdaCall_LambdaExpression,
	                INVALID_LAMBDA_EXPRESSION,
	                JsldslPackage::eINSTANCE.lambdaCall.name)
			}
			
			if (lambdaCall.declaration.expressionType !== null) {
				if (!TypeInfo.getTargetType(lambdaCall.declaration.expressionType).isCompatible(lambdaExpressionTypeInfo)) {
					error("Lambda expression type mismatch",
		                JsldslPackage::eINSTANCE.lambdaCall_LambdaExpression,
		                TYPE_MISMATCH,
		                JsldslPackage::eINSTANCE.lambdaCall.name)
				}
			}
		}
	}

	@Check
	def checkAssociation(EntityRelationDeclaration relation) {
		// System.out.println("checkAssociationOpposite: " + relation + " opposite: " + relation?.opposite + " type: " + relation?.opposite?.oppositeType)
		
		// Check the referenced opposite relation type reference back to this relation
		if (relation.opposite?.oppositeType !== null) {
			// System.out.println(" -- " + relation + " --- " + relation.opposite?.oppositeType?.opposite?.oppositeType)
			if (relation !== relation.opposite?.oppositeType?.opposite?.oppositeType) {
				error("The opposite relation's opposite relation does not match '" + relation.opposite.oppositeType.name + "'",
					JsldslPackage::eINSTANCE.entityRelationDeclaration_Opposite,
					OPPOSITE_TYPE_MISMATH,
					relation.name)
			}			
		}

		// Check this relation without oppoite type is referenced from another relation in the relation target type
		if (relation.opposite === null) {
			val selectableRelatations = relation.referenceType.getAllRelations(null)
			val relationReferencedBack = selectableRelatations.filter[r | r.opposite !== null && r.opposite.oppositeType === relation].toList
			// System.out.println(" -- " + relation + " --- Referenced back: " + relationReferencedBack.map[r | r.eContainer.fullyQualifiedName + "#" + r.name].join(", "))
			if (!relationReferencedBack.empty) {
				error("The relation does not reference to a relation, while  the following relations referencing this relation as opposite: " + 
					relationReferencedBack.map[r | "'" + r.eContainer.fullyQualifiedName.toString("::") + "#" + r.name + "'"].join(", "),
					JsldslPackage::eINSTANCE.entityRelationDeclaration_Opposite,
					OPPOSITE_TYPE_MISMATH,
					relation.name)
			}			
		}
	}

	@Check
	def checkCycleInInheritence(EntityDeclaration entity) {
		// System.out.println(" -- " + relation + " --- Referenced back: " + relationReferencedBack.map[r | r.eContainer.fullyQualifiedName + "#" + r.name].join(", "))

		if (entity.superEntityTypes.contains(entity)) {
			error("Cycle in inheritence of entity '" + entity.name + "'",
				JsldslPackage::eINSTANCE.named_Name,
				INHERITENCE_CYCLE,
				entity.name)			
		}
	}

	@Check
	def checkForDuplicateNameForEntityMemberDeclaration(EntityMemberDeclaration member) {
		if (member instanceof Named && (member.eContainer as EntityDeclaration).getMemberNames(member).map[n | n.toLowerCase].contains(member.name.toLowerCase)) {
			error("Duplicate member declaration: '" + member.name + "'",
				member.nameAttribute,
				DUPLICATE_MEMBER_NAME,
				member.name)
		}
	}

	@Check
	def checkEntityMemberDeclarationLength(EntityMemberDeclaration member) {
		if (member instanceof Named && member.name.length > MEMBER_NAME_LENGTH_MAX) {
			error("Member name: '" + member.name + "' is too long, must be at most " + MEMBER_NAME_LENGTH_MAX + " characters",
				member.nameAttribute,
				MEMBER_NAME_TOO_LONG,
				member.name)
		}
	}

	@Check
	def checkForDuplicateNameForAddedOpposite(EntityRelationOppositeInjected opposite) {
		if (opposite.name !== null && !opposite.name.blank) {
			val relation = opposite.eContainer as EntityRelationDeclaration
			if (relation.referenceType.getMemberNames.contains(opposite.name)) {
				error("Duplicate name: '" + opposite.name + "'",
					opposite.nameAttribute,
					DUPLICATE_MEMBER_NAME,
					opposite.name)			
			}			
		}
	}

	@Check
	def checkForDuplicateInheritedFields(EntityDeclaration entity) {
		val collidingMembers = entity.allMembers
			.filter[m | m instanceof Named]
			.groupBy[m | m.name]
			.filter[n, l | l.size > 1]
			
		if (collidingMembers.size > 0) {
			error("Inherited member name collision for: " + collidingMembers.mapValues[l | l.map[v | "'" + v.memberFullyQualifiedName + "'"].join(", ")].values.join(", "),
				JsldslPackage::eINSTANCE.named_Name,
				INHERITED_MEMBER_NAME_COLLISION,
				entity.name)
		}
	}

	@Check
	def checkForDuplicateNameForDeclaration(Declaration declaration) {
		if (declaration instanceof FunctionDeclaration) return;
		if (declaration instanceof LambdaDeclaration) return;
		
		if ((declaration.eContainer as ModelDeclaration).getDeclarationNames(declaration).map[n | n.toLowerCase].contains(declaration.name.toLowerCase)) {
			error("Duplicate declaration: '" + declaration.name + "'",
				declaration.nameAttribute,
				DUPLICATE_DECLARATION_NAME,
				declaration.name)
		}
	}

	@Check
	def checkMimeType(MimeType mimeType) {
		if (!Pattern.matches("^([a-zA-Z0-9]+([\\._+-][a-zA-Z0-9]+)*)/(\\*|([a-zA-Z0-9]+([\\._+-][a-zA-Z0-9]+)*))$", mimeType.value.stringLiteralValue)) { 
			error("Invalid mime type",
				JsldslPackage::eINSTANCE.mimeType_Value,
				INVALID_MIMETYPE,
				mimeType.value.stringLiteralValue
			)
		}
	}	

	@Check
	def checkModifierMinSize(ModifierMinSize modifier) {
		val maxValue = (modifier.eContainer as DataTypeDeclaration).maxSize.value
		if (modifier.value < BigInteger.ZERO) {
			error("min-size must be greater than or equal to 0",
				JsldslPackage::eINSTANCE.modifierMinSize_Value,
				MIN_SIZE_MODIFIER_IS_NEGATIVE,
				JsldslPackage::eINSTANCE.modifierMinSize.name)
		} else if (modifier.value > maxValue) {
			error("min-size must be less than/equal to max-size",
				JsldslPackage::eINSTANCE.modifierMinSize_Value,
				MIN_SIZE_MODIFIER_IS_TOO_LARGE,
				JsldslPackage::eINSTANCE.modifierMinSize.name)
		}
	}

	@Check
	def checkModifierMaxSize(ModifierMaxSize modifier) {
		if (modifier.value <= BigInteger.ZERO) {
			error("max-size must be greater than 0",
				JsldslPackage::eINSTANCE.modifierMaxSize_Value,
				MAX_SIZE_MODIFIER_IS_NEGATIVE,
				JsldslPackage::eINSTANCE.modifierMaxSize.name)
		} else if (modifier.value > MODIFIER_MAX_SIZE_MAX_VALUE) {
			error("max-size must be less than/equal to " + MODIFIER_MAX_SIZE_MAX_VALUE,
				JsldslPackage::eINSTANCE.modifierMaxSize_Value,
				MAX_SIZE_MODIFIER_IS_TOO_LARGE,
				JsldslPackage::eINSTANCE.modifierMaxSize.name)
		}
	}
	
	@Check
	def checkModifierPrecision(ModifierPrecision precision) {
		if (precision.value <= BigInteger.ZERO) {
			error("Precision must be greater than 0",
				JsldslPackage::eINSTANCE.modifierPrecision_Value,
				PRECISION_MODIFIER_IS_NEGATIVE,
				JsldslPackage::eINSTANCE.modifierPrecision.name)
		} else if (precision.value > PRECISION_MAX_VALUE) {
			error("Precision must be less than/equal to " + PRECISION_MAX_VALUE,
				JsldslPackage::eINSTANCE.modifierPrecision_Value,
				PRECISION_MODIFIER_IS_TOO_LARGE,
				JsldslPackage::eINSTANCE.modifierPrecision.name)
		}
	}
	
	@Check
	def checkModifierScale(ModifierScale scale) {
		val precisionValue = (scale.eContainer as DataTypeDeclaration).precision.value
		if (scale.value < BigInteger.ZERO) {
			error("Scale must be greater than/equal to 0",
				JsldslPackage::eINSTANCE.modifierScale_Value,
				SCALE_MODIFIER_IS_NEGATIVE,
				JsldslPackage::eINSTANCE.modifierScale.name)
		} else if (scale.value >= precisionValue) {
			error("Scale must be less than the defined precision: " + precisionValue,
				JsldslPackage::eINSTANCE.modifierScale_Value,
				SCALE_MODIFIER_IS_TOO_LARGE,
				JsldslPackage::eINSTANCE.modifierScale.name)
		}
	}
	
	@Check
	def checkEnumLiteralMinimum(EnumDeclaration _enum) {
		if (_enum.literals.size < 1) {
			error("Enumeration must have at least one member:"+_enum.name,
				JsldslPackage::eINSTANCE.enumDeclaration_Literals,
				ENUM_MEMBER_MISSING,
				JsldslPackage::eINSTANCE.enumDeclaration.name)
		}
	}
	 
	@Check
	def checkEnumLiteralCollision(EnumLiteral literal) {
		val declaration = literal.eContainer as EnumDeclaration
		val collidingNames = declaration.literals
			.groupBy[m | m.name.toLowerCase]
			.filter[n, l | l.size > 1]
		val collidingOrdinals = declaration.literals
			.groupBy[m | m.value]
			.filter[n, l | l.size > 1]
			
		if (collidingNames.size > 0 && collidingNames.keySet.contains(literal.name.toLowerCase)) {
			error("Enumeration Literal name collision for: " + collidingNames.mapValues[l | l.map[v | "'" + v.fullyQualifiedName + "'"].join(", ")].values.join(", "),
				JsldslPackage::eINSTANCE.named_Name,
				ENUM_LITERAL_NAME_COLLISION,
				literal.name)
		}
		if (collidingOrdinals.size > 0 && collidingOrdinals.keySet.contains(literal.value)) {
			error("Enumeration Literal ordinal collision for: " + collidingOrdinals.mapValues[l | l.map[v | "'" + v.fullyQualifiedName + "': '" + v.value + "'"].join(", ")].values.join(", "),
				JsldslPackage::eINSTANCE.enumLiteral_Value,
				ENUM_LITERAL_ORDINAL_COLLISION,
				literal.name)
		}
	}
	
	@Check
	def checkRequiredOnEntityMemberDeclaration(EntityMemberDeclaration member) {
		if (member instanceof EntityFieldDeclaration) {
			val field = member
			if (field.isIsMany && field.isIsRequired) {
				error("Collection typed field: '" + field.name + "' cannot have keyword: 'required'",
                    JsldslPackage::eINSTANCE.entityFieldDeclaration_IsRequired,
                    USING_REQUIRED_WITH_IS_MANY,
                    JsldslPackage::eINSTANCE.entityFieldDeclaration.name)
			}
		} else if (member instanceof EntityRelationDeclaration) {
			val relation = member
			if (relation.isIsMany && relation.isIsRequired) {
				error("Collection typed relation: '" + relation.name + "' cannot have keyword: 'required'",
                    JsldslPackage::eINSTANCE.entityRelationDeclaration_IsRequired,
                    USING_REQUIRED_WITH_IS_MANY,
                    JsldslPackage::eINSTANCE.entityRelationDeclaration.name)
			}
		}
	}

	@Check
	def checkTenaryOperation(TernaryOperation it) {
		try {
			val TypeInfo conditionTypeInfo = TypeInfo.getTargetType(it.condition)
			val TypeInfo thenTypeInfo = TypeInfo.getTargetType(it.thenExpression)
			val TypeInfo elseTypeInfo = TypeInfo.getTargetType(it.elseExpression)
	
			if (!conditionTypeInfo.isBoolean()) {
				error("Ternary condition must be boolean type",
	                JsldslPackage::eINSTANCE.ternaryOperation_Condition,
	                TYPE_MISMATCH)
			}	
			if (!elseTypeInfo.isCompatible(thenTypeInfo)) {
				error("'else' branch must be compatible with 'then' branch",
	                JsldslPackage::eINSTANCE.ternaryOperation_ThenExpression,
	                TYPE_MISMATCH)
			}
		} catch (IllegalArgumentException illegalArgumentException) {
            return
		}
	}

	@Check
	def checkUnaryOperation(UnaryOperation it) {
		try {
			if (!TypeInfo.getTargetType(it).isBoolean()) {
				error("Operand must be binary type",
	                JsldslPackage::eINSTANCE.unaryOperation_Operand,
	                TYPE_MISMATCH,
	                JsldslPackage::eINSTANCE.unaryOperation_Operator.name)
			}
		} catch (IllegalArgumentException illegalArgumentException) {
            return
		}
	}

	@Check
	def checkBinaryOperation(BinaryOperation it) {
		try {
			val TypeInfo leftTypeInfo = TypeInfo.getTargetType(it.leftOperand)
			val TypeInfo rightTypeInfo = TypeInfo.getTargetType(it.rightOperand)
	
			if (leftTypeInfo.binary) {
				error("Left operand cannot be binary type",
	                JsldslPackage::eINSTANCE.binaryOperation_LeftOperand,
	                TYPE_MISMATCH,
	                JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
			}
			if (rightTypeInfo.binary) {
				error("Right operand cannot be binary type",
	                JsldslPackage::eINSTANCE.binaryOperation_RightOperand,
	                TYPE_MISMATCH,
	                JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
			}
	
			if (Arrays.asList("!=","==",">=","<=",">","<").contains(it.getOperator())) {
				if (leftTypeInfo.collection) {
					error("Left operand cannot be collection",
		                JsldslPackage::eINSTANCE.binaryOperation_LeftOperand,
		                TYPE_MISMATCH,
		                JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
				}
				if (rightTypeInfo.collection) {
					error("Right operand cannot be collection",
		                JsldslPackage::eINSTANCE.binaryOperation_RightOperand,
		                TYPE_MISMATCH,
		                JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
				}
			} else if ("+".equals(it.getOperator())) {
				if (!leftTypeInfo.numeric && !leftTypeInfo.string) {
					error("Left operand must be numeric or string type",
		                JsldslPackage::eINSTANCE.binaryOperation_LeftOperand,
		                TYPE_MISMATCH,
		                JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
				}
				if (!rightTypeInfo.numeric && !rightTypeInfo.string) {
					error("Right operand must be numeric or string type",
		                JsldslPackage::eINSTANCE.binaryOperation_RightOperand,
		                TYPE_MISMATCH,
		                JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
				}	
			} else if (Arrays.asList("^", "-", "*", "/", "mod", "div").contains(it.getOperator())) {
				if (!leftTypeInfo.numeric) {
					error("Left operand must be numeric type",
		                JsldslPackage::eINSTANCE.binaryOperation_LeftOperand,
		                TYPE_MISMATCH,
		                JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
				}
				if (!rightTypeInfo.numeric) {
					error("Right operand must be numeric type",
		                JsldslPackage::eINSTANCE.binaryOperation_RightOperand,
		                TYPE_MISMATCH,
		                JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
				}	
			} else if (Arrays.asList("implies","or","xor","and").contains(it.getOperator())) {
				if (!leftTypeInfo.isBoolean()) {
					error("Left operand must be boolean type",
		                JsldslPackage::eINSTANCE.binaryOperation_LeftOperand,
		                TYPE_MISMATCH,
		                JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
				}
				if (!rightTypeInfo.isBoolean()) {
					error("Right operand must be boolean type",
		                JsldslPackage::eINSTANCE.binaryOperation_RightOperand,
		                TYPE_MISMATCH,
		                JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
				}	
			}
			
			if (!leftTypeInfo.isCompatible(rightTypeInfo)) {
				error("Left and right operand type mismatch",
	                JsldslPackage::eINSTANCE.binaryOperation_Operator,
	                TYPE_MISMATCH,
	                JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
			}
		} catch (IllegalArgumentException illegalArgumentException) {
            return
		}
	}

	@Check
	def checkEntityField(EntityFieldDeclaration field) {
		try {
			if (field.defaultExpression !== null && !TypeInfo.getTargetType(field).isCompatible(TypeInfo.getTargetType(field.defaultExpression))) {
				error("Default value does not match field type",
	                JsldslPackage::eINSTANCE.entityFieldDeclaration_DefaultExpression,
	                TYPE_MISMATCH)
			}
		} catch (IllegalArgumentException illegalArgumentException) {
            return
		}
	}

	@Check
	def checkEntityIdentifier(EntityIdentifierDeclaration field) {
		try {
			if (field.defaultExpression !== null && !TypeInfo.getTargetType(field).isCompatible(TypeInfo.getTargetType(field.defaultExpression))) {
				error("Type mismatch",
	                JsldslPackage::eINSTANCE.entityIdentifierDeclaration_DefaultExpression,
	                TYPE_MISMATCH,
	                JsldslPackage::eINSTANCE.dataTypeDeclaration.name)
			}
		} catch (IllegalArgumentException illegalArgumentException) {
            return
		}
	}

	@Check
	def checkEntityDerived(EntityDerivedDeclaration derived) {
		try {
			if (derived.expression !== null && !TypeInfo.getTargetType(derived).isCompatible(TypeInfo.getTargetType(derived.expression))) {
				error("Type mismatch",
	                JsldslPackage::eINSTANCE.entityDerivedDeclaration_Expression,
	                TYPE_MISMATCH,
	                JsldslPackage::eINSTANCE.dataTypeDeclaration.name)
			}
		} catch (IllegalArgumentException illegalArgumentException) {
            return
		}
	}

	@Check
	def checkEntityQuery(EntityQueryDeclaration query) {
		try {
			if (query.expression !== null && !TypeInfo.getTargetType(query).isCompatible(TypeInfo.getTargetType(query.expression))) {
				error("Type mismatch",
	                JsldslPackage::eINSTANCE.entityQueryDeclaration_Expression,
	                TYPE_MISMATCH,
	                JsldslPackage::eINSTANCE.dataTypeDeclaration.name)
			}
		} catch (IllegalArgumentException illegalArgumentException) {
            return
		}
		
	}

	@Check
	def checkQuery(QueryDeclaration query) {
		try {
			if (query.expression !== null && !TypeInfo.getTargetType(query).isCompatible(TypeInfo.getTargetType(query.expression))) {
				error("Type mismatch",
	                JsldslPackage::eINSTANCE.queryDeclaration_Expression,
	                TYPE_MISMATCH,
	                JsldslPackage::eINSTANCE.queryDeclaration.name)
			}
		} catch (IllegalArgumentException illegalArgumentException) {
            return
		}
		
	}
}
