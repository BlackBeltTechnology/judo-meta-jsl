package hu.blackbelt.judo.meta.jsl.validation

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
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
import hu.blackbelt.judo.meta.jsl.jsldsl.DefaultExpressionType
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumLiteralReference
import hu.blackbelt.judo.meta.jsl.jsldsl.EscapedStringLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.RawStringLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.BooleanLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.IntegerLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.DecimalLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityIdentifierDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.DateLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.TimeLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.TimeStampLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.ErrorField
import hu.blackbelt.judo.meta.jsl.jsldsl.Named
import hu.blackbelt.judo.meta.jsl.jsldsl.SelfExpression
import hu.blackbelt.judo.meta.jsl.jsldsl.BinaryOperation
import hu.blackbelt.judo.meta.jsl.jsldsl.Expression
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeInjected
import hu.blackbelt.judo.meta.jsl.jsldsl.MimeType
import java.util.function.BinaryOperator
import hu.blackbelt.judo.meta.jsl.services.JslDslGrammarAccess.ImpliesExpressionElements
import java.util.regex.Pattern
import org.eclipse.emf.mwe2.language.mwe2.StringLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelImportDeclaration

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
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
	public static val DEFAULT_TYPE_MISMATCH = ISSUE_CODE_PREFIX + "DefaultValueTypeMismatch"
	public static val UNSUPPORTED_DEFAULT_TYPE = ISSUE_CODE_PREFIX + "UnsupportedDefaultValueType"

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
	
	
	def isBooleanExpression(Expression it) {
		if ((it instanceof BinaryOperation) && (#["not", "implies", "or", "xor", "and", "!=", "==", ">=", "<=", "<", ">"].contains((it as BinaryOperation).operator))) {
			return true;
		}
		return false;
	}

	def isIntegerExpression(Expression it) {
		if ((it instanceof BinaryOperation) && (#["div", "mod", "^", "*", "/", "+", "-" ].contains((it as BinaryOperation).operator))) {
			return true;
		}
		return false;
	}

	def isDecimalExpression(Expression it) {
		if ((it instanceof BinaryOperation) && (#["^", "*", "/", "+", "-" ].contains((it as BinaryOperation).operator))) {
			return true;
		}
		return false;
	}


	@Check
	def checkDefaultExpressionMatchesMemberType(DefaultExpressionType defaultExpression) {
        var EObject memberReferenceType
		
        if (defaultExpression.eContainer instanceof EntityFieldDeclaration) {
			memberReferenceType = (defaultExpression.eContainer as EntityFieldDeclaration).referenceType
        } else if (defaultExpression.eContainer instanceof EntityIdentifierDeclaration) {
			memberReferenceType = (defaultExpression.eContainer as EntityIdentifierDeclaration).referenceType
        } else if (defaultExpression.eContainer instanceof ErrorField) {
            memberReferenceType = (defaultExpression.eContainer as ErrorField).referenceType
        } else {
            throw new IllegalArgumentException("Unsupported default expression for member type: " + defaultExpression.eContainer.class.simpleName)
        }
		
		var String primitive
		var String nameForEntityFieldSingleType
				
		if (memberReferenceType instanceof DataTypeDeclaration) {
			primitive = memberReferenceType.primitive
			nameForEntityFieldSingleType = memberReferenceType.name
		}

		if (defaultExpression.expression instanceof EnumLiteralReference) {
			val enumLiteral = defaultExpression.expression as EnumLiteralReference
			
			if (enumLiteral.enumDeclaration !== memberReferenceType) {
				error("Default value type: '" + enumLiteral.enumDeclaration.name + "' does not match member type: '" + (memberReferenceType as EnumDeclaration).name + "'",
                    JsldslPackage::eINSTANCE.defaultExpressionType_Expression,
                    DEFAULT_TYPE_MISMATCH,
                    JsldslPackage::eINSTANCE.enumLiteralReference_EnumLiteral.name)
			}
		} else if (defaultExpression.expression instanceof EscapedStringLiteral) {
			if (!#["string"].contains(primitive)) {
				error("Default value type: '" + EscapedStringLiteral.simpleName + "' does not match member type: '" + nameForEntityFieldSingleType + "'",
                    JsldslPackage::eINSTANCE.defaultExpressionType_Expression,
                    DEFAULT_TYPE_MISMATCH,
                    JsldslPackage::eINSTANCE.escapedStringLiteral.name)
			}
		} else if (defaultExpression.expression instanceof RawStringLiteral) {
			if (!#["string"].contains(primitive)) {
				error("Default value type: '" + RawStringLiteral.simpleName + "' does not match member type: '" + nameForEntityFieldSingleType + "'",
                    JsldslPackage::eINSTANCE.defaultExpressionType_Expression,
                    DEFAULT_TYPE_MISMATCH,
                    JsldslPackage::eINSTANCE.rawStringLiteral.name)
			}
		} else if ((defaultExpression.expression instanceof BooleanLiteral) || (defaultExpression.expression.isBooleanExpression)) {
			if (!#["boolean"].contains(primitive)) {
				error("Default value type: '" + BooleanLiteral.simpleName + "' does not match member type: '" + nameForEntityFieldSingleType + "'",
                    JsldslPackage::eINSTANCE.defaultExpressionType_Expression,
                    DEFAULT_TYPE_MISMATCH,
                    JsldslPackage::eINSTANCE.booleanLiteral.name)
			}
		} else if ((defaultExpression.expression instanceof IntegerLiteral) || (defaultExpression.expression.isIntegerExpression)) {
			if (!#["numeric"].contains(primitive)) {
				error("Default value type: '" + IntegerLiteral.simpleName + "' does not match member type: '" + nameForEntityFieldSingleType + "'",
                    JsldslPackage::eINSTANCE.defaultExpressionType_Expression,
                    DEFAULT_TYPE_MISMATCH,
                    JsldslPackage::eINSTANCE.integerLiteral.name)
			}
		} else if ((defaultExpression.expression instanceof DecimalLiteral) || (defaultExpression.expression.isDecimalExpression)) {
			if (!#["numeric"].contains(primitive)) {
				error("Default value type: '" + DecimalLiteral.simpleName + "' does not match member type: '" + nameForEntityFieldSingleType + "'",
                    JsldslPackage::eINSTANCE.defaultExpressionType_Expression,
                    DEFAULT_TYPE_MISMATCH,
                    JsldslPackage::eINSTANCE.decimalLiteral.name)
			}
		} else if (defaultExpression.expression instanceof DateLiteral) {
			if (!#["date"].contains(primitive)) {
				error("Default value type: '" + DecimalLiteral.simpleName + "' does not match member type: '" + nameForEntityFieldSingleType + "'",
                    JsldslPackage::eINSTANCE.defaultExpressionType_Expression,
                    DEFAULT_TYPE_MISMATCH,
                    JsldslPackage::eINSTANCE.dateLiteral.name)
			}
		} else if (defaultExpression.expression instanceof TimeLiteral) {
			if (!#["time"].contains(primitive)) {
				error("Default value type: '" + DecimalLiteral.simpleName + "' does not match member type: '" + nameForEntityFieldSingleType + "'",
                    JsldslPackage::eINSTANCE.defaultExpressionType_Expression,
                    DEFAULT_TYPE_MISMATCH,
                    JsldslPackage::eINSTANCE.timeLiteral.name)
			}
		} else if (defaultExpression.expression instanceof TimeStampLiteral) {
			if (!#["timestamp"].contains(primitive)) {
				error("Default value type: '" + DecimalLiteral.simpleName + "' does not match member type: '" + nameForEntityFieldSingleType + "'",
                    JsldslPackage::eINSTANCE.defaultExpressionType_Expression,
                    DEFAULT_TYPE_MISMATCH,
                    JsldslPackage::eINSTANCE.timeStampLiteral.name)
			}
		} else if (defaultExpression.expression instanceof SelfExpression) {
			error("Default value type: '" + defaultExpression.expression.class.simpleName + "' not supported!",
                    JsldslPackage::eINSTANCE.defaultExpressionType_Expression,
                    UNSUPPORTED_DEFAULT_TYPE)
		}
	}

	def currentElem(EObject grammarElement) {
		return grammarElement.eResource.resourceSet.getResource(URI.createURI("self_synthetic"), true).contents.get(0)
	}

}
