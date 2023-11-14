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
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityMemberDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.Declaration
import java.math.BigInteger
import hu.blackbelt.judo.meta.jsl.jsldsl.DataTypeDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumLiteral
import hu.blackbelt.judo.meta.jsl.jsldsl.Named
import hu.blackbelt.judo.meta.jsl.jsldsl.BinaryOperation
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeInjected
import hu.blackbelt.judo.meta.jsl.jsldsl.MimeType
import java.util.regex.Pattern
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelImportDeclaration
import java.util.Arrays
import hu.blackbelt.judo.meta.jsl.runtime.TypeInfo
import hu.blackbelt.judo.meta.jsl.jsldsl.TernaryOperation
import hu.blackbelt.judo.meta.jsl.jsldsl.UnaryOperation
import java.util.Iterator
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaCall
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.common.util.EList
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryParameterDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryDeclaration
import org.eclipse.emf.ecore.util.EcoreUtil
import hu.blackbelt.judo.meta.jsl.jsldsl.Feature
import hu.blackbelt.judo.meta.jsl.jsldsl.MemberReference
import hu.blackbelt.judo.meta.jsl.jsldsl.Expression
import java.util.ArrayList
import hu.blackbelt.judo.meta.jsl.jsldsl.Self
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationBaseDeclarationReference
import hu.blackbelt.judo.meta.jsl.jsldsl.AnnotationParameterDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.AnnotationArgument
import hu.blackbelt.judo.meta.jsl.jsldsl.AnnotationMark
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.AnnotationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferMemberDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.RowDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.Navigation
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityMapDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.GuardModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationTarget
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewActionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewGroupDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewLinkDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewTableDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewTabsDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.RowColumnDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorGroupDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferRelationDeclaration

import hu.blackbelt.judo.meta.jsl.jsldsl.TransferActionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorMenuDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorAccessDeclaration

import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeReferenced
import hu.blackbelt.judo.meta.jsl.jsldsl.PrecisionModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.MaxSizeModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.Modifiable
import hu.blackbelt.judo.meta.jsl.jsldsl.Modifier
import hu.blackbelt.judo.meta.jsl.jsldsl.PrimitiveDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.MinSizeModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.ScaleModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.IdentityModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferEventDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferChoiceModifier

import hu.blackbelt.judo.meta.jsl.jsldsl.SimpleTransferDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferCreateDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferInitializeDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionOrQueryCall
import hu.blackbelt.judo.meta.jsl.jsldsl.Argument
import hu.blackbelt.judo.meta.jsl.jsldsl.FunctionParameterDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaVariable
import hu.blackbelt.judo.meta.jsl.jsldsl.EagerModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.DetailModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.RowsModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.DefaultModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferDataDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.InputModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.CreateModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.DeleteModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.UpdateModifier

class JslDslValidator extends AbstractJslDslValidator {

    protected static val ISSUE_CODE_PREFIX = "hu.blackbelt.judo.meta.jsl.jsldsl."

    public static val RECOMMENDATION = ISSUE_CODE_PREFIX + "Recommendation"

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
    public static val DUPLICATE_ERROR_THROW = ISSUE_CODE_PREFIX + "DuplicateErrorThrow"
    public static val DUPLICATE_ACTOR = ISSUE_CODE_PREFIX + "DuplicateActor"
    public static val MISSING_REQUIRED_PARAMETER = ISSUE_CODE_PREFIX + "MissingRequiredParameter"
    public static val INVALID_LAMBDA_EXPRESSION = ISSUE_CODE_PREFIX + "InvalidLambdaExpression"
    public static val IMPORT_ALIAS_COLLISION = ISSUE_CODE_PREFIX + "ImportAliasCollison"
    public static val HIDDEN_DECLARATION = ISSUE_CODE_PREFIX + "HiddenDeclaration"
    public static val INVALID_DECLARATION = ISSUE_CODE_PREFIX + "InvalidDeclaration"
    public static val EXPRESSION_CYCLE = ISSUE_CODE_PREFIX + "ExpressionCycle"
    public static val ANNOTATION_CYCLE = ISSUE_CODE_PREFIX + "AnnotationCycle"
    public static val REQUIRED_COMPOSITION_CYCLE = ISSUE_CODE_PREFIX + "RequiredFieldCycle"
    public static val SELF_NOT_ALLOWED = ISSUE_CODE_PREFIX + "SelfNotAllowed"
    public static val INVALID_COLLECTION = ISSUE_CODE_PREFIX + "InvalidCollection"
    public static val INVALID_ANNOTATION = ISSUE_CODE_PREFIX + "InvalidAnnotation"
    public static val INVALID_ANNOTATION_MARK = ISSUE_CODE_PREFIX + "InvalidAnnotationMark"
    public static val DUPLICATE_AUTOMAP = ISSUE_CODE_PREFIX + "DuplicateAutomap"
    public static val DUPLICATE_ENTITY_QUERY = ISSUE_CODE_PREFIX + "DuplicateEntityQuery"
    public static val INVALID_SERVICE_FUNCTION_CALL = ISSUE_CODE_PREFIX + "InvalidServiceFunctionCall"
    public static val INVALID_FIELD_MAPPING = ISSUE_CODE_PREFIX + "InvalidFieldMapping"
    public static val INVALID_IDENTITY_MAPPING = ISSUE_CODE_PREFIX + "InvalidFieldMapping"
    public static val INCOMPAIBLE_EXPORT = ISSUE_CODE_PREFIX + "IncompatibleExport"
    public static val INVALID_SELF_VARIABLE = ISSUE_CODE_PREFIX + "InvalidSelfVariable"
    public static val NON_STATIC_EXPRESSION = ISSUE_CODE_PREFIX + "NonStaticExpression"
    public static val INVALID_CHOICES = ISSUE_CODE_PREFIX + "InvalidChoices"
    public static val ENUM_ORDINAL_IS_TOO_LARGE = ISSUE_CODE_PREFIX + "EnumOrdinalIsTooLarge"
    public static val JAVA_BEAN_NAMING_ISSUE = ISSUE_CODE_PREFIX + "JavaBeanNamingIssue"
    public static val DUPLICATE_FIELD_MAPPING = ISSUE_CODE_PREFIX + "DuplicateFieldMapping"
    public static val DUPLICATE_CONSTRUCTOR = ISSUE_CODE_PREFIX + "DuplicateConstructor"
    public static val DUPLICATE_EVENT = ISSUE_CODE_PREFIX + "DuplicateEvent"
    public static val DUPLICATE_SUBMIT = ISSUE_CODE_PREFIX + "DuplicateSubmit"
    public static val FIELD_TYPE_IS_ABSRTACT_ENTITY = ISSUE_CODE_PREFIX + "FieldTypeIsAbstractEntity"
    public static val DUPLICATE_MODIFIER = ISSUE_CODE_PREFIX + "DuplicateModifier"

    public static val MEMBER_NAME_LENGTH_MAX = 128
    public static val MODIFIER_MAX_SIZE_MAX_VALUE = BigInteger.valueOf(4000)
    public static val PRECISION_MAX_VALUE = BigInteger.valueOf(15)
    public static val ENUM_LITERAL_ORDINAL_MAX_VALUE = BigInteger.valueOf(9999)

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
                    "The model '" + modelDeclaration.name + "' is already defined.",
                    JsldslPackage::eINSTANCE.modelDeclaration_Name,
                    HIERARCHY_CYCLE,
                    modelDeclaration.name
                )
                return
            }
        ]
    }

    // perform this check only on file save
    @Check(CheckType::NORMAL)
	def checkDuplicateEntityQuery(QueryDeclaration query) {
		if (query.entity === null) {
			return
		}
		
		val TypeInfo queryTypeInfo = TypeInfo.getTargetType(query.entity);
		
		val ModelDeclaration m = query.eContainer as ModelDeclaration;
		m.allImportedModelDeclarations
			.forEach[mx |
				mx.allQueryDeclarations
					.filter[q | TypeInfo.getTargetType(q.entity).isCompatible(queryTypeInfo) && q.name.equals(query.name)]
					.forEach[q |
			            error("Duplicate query:" + q.fullyQualifiedName,
			                JsldslPackage::eINSTANCE.named_Name,
			                DUPLICATE_ENTITY_QUERY,
			                JsldslPackage::eINSTANCE.named.name)
					]
			]
	}

    // perform this check only on file save
    @Check(CheckType::NORMAL)
	def checkDuplicateActor(ActorDeclaration actor) {
		val ModelDeclaration m = actor.eContainer as ModelDeclaration;
		m.allImportedModelDeclarations
			.forEach[mx |
				mx.allActorDeclarations
					.filter[a | a.name.equals(actor.name)]
					.forEach[q |
			            error("Duplicate actor:" + q.fullyQualifiedName,
			                JsldslPackage::eINSTANCE.named_Name,
			                DUPLICATE_ACTOR,
			                JsldslPackage::eINSTANCE.named.name)
					]
			]
	}

    def void findAnnotationCycle(AnnotationDeclaration annotation, ArrayList<AnnotationDeclaration> visited) {
        if (visited.size > 0 && annotation.equals(visited.get(0))) {
            throw new IllegalCallerException
        }

        if (visited.contains(annotation)) {
            return
        }

        visited.add(annotation)

        val Iterator<AnnotationMark> annotationMarkIterator = annotation.annotations.iterator
        while (annotationMarkIterator.hasNext) {
            val AnnotationMark annotationMark = annotationMarkIterator.next()

            if (annotationMark.declaration !== null) {
                findAnnotationCycle(annotationMark.declaration, visited)
            }
        }

        visited.remove(annotation)
    }

    @Check(CheckType::NORMAL)
    def checkCyclicAnnotation(AnnotationDeclaration annotation) {
        if (annotation.annotations !== null) {
            try {
                findAnnotationCycle(annotation, new ArrayList<AnnotationDeclaration>())
            } catch (IllegalCallerException e) {
                error(
                    "Cyclic annotation definition at '" + annotation.name + "'.",
                    JsldslPackage::eINSTANCE.annotationDeclaration_Annotations,
                    ANNOTATION_CYCLE,
                    annotation.name
                )
                return
            }
        }
    }

    def void findEntityRequiredCycle(EntityMemberDeclaration member, ArrayList<EntityMemberDeclaration> visited) {
        if (visited.size > 0 && member.equals(visited.get(0))) {
            throw new IllegalCallerException
        }

        if (visited.contains(member)) {
            return
        }

        visited.add(member)
        
        (member.referenceType as EntityDeclaration).allMembers
        	.filter[m | m.required && m.referenceType instanceof EntityDeclaration]
       		.forEach[m | findEntityRequiredCycle(m, visited)]

        visited.remove(member)
    }

    @Check(CheckType::NORMAL)
	def checkCyclicEntityRequired(EntityMemberDeclaration member) {
		if (!(member.referenceType instanceof EntityDeclaration) || !member.required) {
			return
		}
		
        var ArrayList<EntityMemberDeclaration> cycle = new ArrayList<EntityMemberDeclaration>()
        try {
            findEntityRequiredCycle(member, cycle)
        } catch (IllegalCallerException e) {
            error(
                "Cyclic required member definition at '" + cycle.map[f | f.fullyQualifiedName].join(' -> ') + ' -> ' + member.fullyQualifiedName + "'.",
                JsldslPackage::eINSTANCE.named_Name,
                REQUIRED_COMPOSITION_CYCLE,
                member.name
            )
            return
        }
	}

    def void findEntityEagerCycle(EntityMemberDeclaration member, ArrayList<EntityMemberDeclaration> visited) {
        if (visited.size > 0 && member.equals(visited.get(0))) {
            throw new IllegalCallerException
        }

        if (visited.contains(member)) {
            return
        }

        visited.add(member)
        
        (member.referenceType as EntityDeclaration).allMembers
        	.filter[m | m.referenceType instanceof EntityDeclaration && m.eager]
       		.forEach[m | findEntityEagerCycle(m, visited)]

        visited.remove(member)
    }

    @Check(CheckType::NORMAL)
	def checkCyclicEagerEntity(EntityMemberDeclaration member) {
		if (!(member.referenceType instanceof EntityDeclaration) || !member.eager) {
			return
		}
		
        var ArrayList<EntityMemberDeclaration> cycle = new ArrayList<EntityMemberDeclaration>()
        try {
            findEntityEagerCycle(member, cycle)
        } catch (IllegalCallerException e) {
            warning(
                "Cyclic eager definition at '" + cycle.map[r | r.fullyQualifiedName].join(' -> ') + ' -> ' + member.fullyQualifiedName +"'. It may result in slow performance or endless loops.",
                JsldslPackage::eINSTANCE.named_Name,
                REQUIRED_COMPOSITION_CYCLE,
                member.name
            )
            return
        }
	}

    def void findTransferEagerCycle(TransferRelationDeclaration relation, ArrayList<TransferRelationDeclaration> visited) {
        if (visited.size > 0 && relation.equals(visited.get(0))) {
            throw new IllegalCallerException
        }

        if (visited.contains(relation)) {
            return
        }

        visited.add(relation)
        
        relation.referenceType.members
        	.filter[m | m instanceof TransferRelationDeclaration && relation.eager]
       		.forEach[m | findTransferEagerCycle(m as TransferRelationDeclaration, visited)]

        visited.remove(relation)
    }

    @Check(CheckType::NORMAL)
	def checkCyclicEagerTransfer(TransferRelationDeclaration relation) {
		if (!relation.eager) {
			return
		}
		
        var ArrayList<TransferRelationDeclaration> cycle = new ArrayList<TransferRelationDeclaration>()
        try {
            findTransferEagerCycle(relation, cycle)
        } catch (IllegalCallerException e) {
            warning(
                "Cyclic eager relation definition at '" + cycle.map[r | r.fullyQualifiedName].join(' -> ') + ' -> ' + relation.fullyQualifiedName +"'. It may result in slow performance or endless loops.",
                JsldslPackage::eINSTANCE.named_Name,
                REQUIRED_COMPOSITION_CYCLE,
                relation.name
            )
            return
        }
	}

    def void findExpressionCycle(Expression expression, ArrayList<Expression> visited) {
        if (visited.size > 0 && expression.equals(visited.get(0))) {
            throw new IllegalCallerException
        }

        if (visited.contains(expression)) {
            return
        }

        visited.add(expression)

        val Iterator<FunctionOrQueryCall> functionOrqueryCallIterator = EcoreUtil.getAllContents(expression, true).filter(FunctionOrQueryCall)
        while (functionOrqueryCallIterator.hasNext) {
            val FunctionOrQueryCall functionOrQueryCall = functionOrqueryCallIterator.next()

            if (functionOrQueryCall.declaration !== null && functionOrQueryCall.declaration instanceof QueryDeclaration) {
				val QueryDeclaration query = functionOrQueryCall.declaration as QueryDeclaration
            	if (query.getterExpr !== null) {
                	findExpressionCycle(query.getterExpr, visited)
               	}
            }
        }

        val Iterator<Feature> featureIterator = EcoreUtil.getAllContents(expression, true).filter(Feature)
        while (featureIterator.hasNext) {
            val EObject obj = featureIterator.next()

            if (obj instanceof MemberReference && (obj as MemberReference).member instanceof EntityMemberDeclaration) {
                val EntityMemberDeclaration member = (obj as MemberReference).member as EntityMemberDeclaration
                if (member.calculated) findExpressionCycle(member.getterExpr, visited)
            }
        }

        visited.remove(expression)
    }

    @Check(CheckType::NORMAL)
    def checkCyclicDerivedExpression(EntityMemberDeclaration member) {
    	if (!member.calculated) return;
    	
        try {
            findExpressionCycle(member.getterExpr, new ArrayList<Expression>())
        } catch (IllegalCallerException e) {
            error(
                "Cyclic expression at '" + member.name + "'.",
                JsldslPackage::eINSTANCE.entityMemberDeclaration_GetterExpr,
                EXPRESSION_CYCLE,
                member.name
            )
            return
        }
    }

    @Check(CheckType::NORMAL)
    def checkCyclicStaticQueryExpression(QueryDeclaration query) {
        if (query.getterExpr !== null) {
            try {
                findExpressionCycle(query.getterExpr, new ArrayList<Expression>())
            } catch (IllegalCallerException e) {
                error(
                    "Cyclic expression at '" + query.name + "'.",
                    JsldslPackage::eINSTANCE.queryDeclaration_GetterExpr,
                    EXPRESSION_CYCLE,
                    query.name
                )
                return
            }
        }
    }

    @Check
    def checkSelfInQueryParameterDefaultExpression(QueryParameterDeclaration parameter) {
        if (parameter.^default !== null) {
            if (!this.isStaticExpression(parameter.^default)) {
                error(
                    "Self is not allowed in parameter default expression at '" + parameter.name + "'.",
                    JsldslPackage::eINSTANCE.queryParameterDeclaration_Default,
                    SELF_NOT_ALLOWED,
                    parameter.name
                )
                return
            }
        }
    }

    @Check(CheckType::NORMAL)
    def checkInvalidFunctionDeclaration(FunctionDeclaration functionDeclaration) {
        val ModelDeclaration modelDeclaration = functionDeclaration.eContainer as ModelDeclaration
        if (!modelDeclaration.fullyQualifiedName.equals("judo::functions")) {
            error("Invalid function declaration '" + functionDeclaration.name + "'. Function declaration is currently only allowed in the judo::functions model.",
                JsldslPackage::eINSTANCE.named_Name,
                INVALID_DECLARATION,
                functionDeclaration.name)
        }
    }

    @Check(CheckType::NORMAL)
    def checkInvalidLambdaDeclaration(LambdaDeclaration lambdaDeclaration) {
        val ModelDeclaration modelDeclaration = lambdaDeclaration.eContainer as ModelDeclaration
        if (!modelDeclaration.fullyQualifiedName.equals("judo::functions")) {
            error("Invalid lambda declaration '" + lambdaDeclaration.name + "'. Lambda declaration is currently only allowed in the judo::functions model.",
                JsldslPackage::eINSTANCE.named_Name,
                INVALID_DECLARATION,
                lambdaDeclaration.name)
        }
    }

    @Check(CheckType::NORMAL)
    def checkImportAlias(ModelImportDeclaration modelImport) {
        if (modelImport.alias !== null) {
            if ((modelImport.eContainer as ModelDeclaration).imports.filter[i | i.model.name.toLowerCase.equals(modelImport.alias.toLowerCase)].size > 0) {
                error("Import alias name collision '" + modelImport.alias + "'",
                    JsldslPackage::eINSTANCE.modelImportDeclaration_Alias,
                    IMPORT_ALIAS_COLLISION,
                    modelImport.alias)
            }

            if ((modelImport.eContainer as ModelDeclaration).imports.filter[i | i.alias !== null && i.alias.toLowerCase.equals(modelImport.alias.toLowerCase)].size > 1) {
                error("Import alias name collision '" + modelImport.alias + "'",
                    JsldslPackage::eINSTANCE.modelImportDeclaration_Alias,
                    IMPORT_ALIAS_COLLISION,
                    modelImport.alias)
            }
        }
    }

    @Check(CheckType::NORMAL)
    def checkSelfImport(ModelImportDeclaration modelImport) {
        //System.out.println("checkSelfImport: " + modelImport.importedNamespace + " " + modelImport.eContainer().fullyQualifiedName.toString("::"))

        if (modelImport.model === null) {
            return
        }

        if (modelImport.model.name === null) {
            return
        }

        if (modelImport.model.name.toQualifiedName.equals(modelImport.eContainer().fullyQualifiedName)) {
            error("Cycle in model import '" + modelImport.model.name + "'",
                JsldslPackage::eINSTANCE.modelImportDeclaration_Model,
                HIERARCHY_CYCLE,
                modelImport.model.name)
        }
    }

    @Check(CheckType::NORMAL)
    def checkHiddenDeclaration(Declaration declaration) {
    	if (!(declaration.eContainer instanceof ModelDeclaration)) return;
    	
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
    def checkArgument(Argument argument) {
        if (argument.expression !== null && argument.declaration !== null) {
            val TypeInfo exprTypeInfo = TypeInfo.getTargetType(argument.expression);

        	if (argument.declaration instanceof FunctionParameterDeclaration && (argument.declaration as FunctionParameterDeclaration).description !== null) {
            	val TypeInfo declarationTypeInfo = TypeInfo.getTargetType((argument.declaration as FunctionParameterDeclaration).description);

	            if (!declarationTypeInfo.isBaseCompatible(exprTypeInfo)) {
	                error("Type mismatch. Incompatible function argument at '" + argument.declaration.name + "'.",
	                    JsldslPackage::eINSTANCE.argument_Expression,
	                    TYPE_MISMATCH,
	                    JsldslPackage::eINSTANCE.argument.name)
	            }
	
	            if (declarationTypeInfo.constant && !exprTypeInfo.constant) {
	                error("Function argument must be constant at '" + argument.declaration.name + "'.",
	                    JsldslPackage::eINSTANCE.argument_Expression,
	                    TYPE_MISMATCH,
	                    JsldslPackage::eINSTANCE.argument.name)
	            }
        	}
        	
        	if (argument.declaration instanceof QueryParameterDeclaration) {
            	val TypeInfo declarationTypeInfo = TypeInfo.getTargetType((argument.declaration as QueryParameterDeclaration));

	            if (!declarationTypeInfo.isCompatible(exprTypeInfo)) {
	                error("Type mismatch. Incompatible query argument at '" + argument.declaration.name + "'.",
	                    JsldslPackage::eINSTANCE.argument_Expression,
	                    TYPE_MISMATCH,
	                    JsldslPackage::eINSTANCE.argument.name)
	            }
	
	            if (!this.isStaticExpression(argument.expression)) {
	                error("Self is not allowed in query argument expression at '" + argument.declaration.name + "'.",
	                    JsldslPackage::eINSTANCE.argument_Expression,
	                    INVALID_SELF_VARIABLE,
	                    JsldslPackage::eINSTANCE.argument.name)
	            }
	
	            if (EcoreUtil.getAllContents(argument.expression, true).
	                filter(NavigationBaseDeclarationReference).
	                map[r | r.reference].filter(LambdaVariable).size > 0)
	            {
	                error("Lambda variable is not allowed in query argument expression at '" + argument.declaration.name + "'.",
	                    JsldslPackage::eINSTANCE.argument_Expression,
	                    INVALID_LAMBDA_EXPRESSION,
	                    JsldslPackage::eINSTANCE.argument.name)
	            }
        	}
        }

        val FunctionOrQueryCall functionOrQueryCall = argument.eContainer as FunctionOrQueryCall;

        if (functionOrQueryCall.arguments.filter[a | a.declaration.isEqual(argument.declaration)].size > 1) {
            error("Duplicate function parameter:" + argument.declaration.name,
                JsldslPackage::eINSTANCE.argument_Declaration,
                DUPLICATE_PARAMETER,
                JsldslPackage::eINSTANCE.argument.name)
        }
    }

    @Check
    def checkRequiredArguments(FunctionOrQueryCall functionOrQueryCall) {
    	if (functionOrQueryCall.declaration instanceof FunctionDeclaration) {
	        val FunctionDeclaration functionDeclaration = functionOrQueryCall.declaration as FunctionDeclaration;
	        val Iterator<FunctionParameterDeclaration> itr = functionDeclaration.parameters.filter[p | p.isRequired].iterator;
	
	        while (itr.hasNext) {
	            val FunctionParameterDeclaration declaration = itr.next;
	
	            if (!functionOrQueryCall.arguments.exists[a | a.declaration.isEqual(declaration)]) {
	                error("Missing required function parameter:" + declaration.name,
	                    JsldslPackage::eINSTANCE.functionOrQueryCall_Arguments,
	                    MISSING_REQUIRED_PARAMETER,
	                    JsldslPackage::eINSTANCE.functionOrQueryCall.name)
	            }
	        }
	    }

    	if (functionOrQueryCall.declaration instanceof QueryDeclaration) {
	        val QueryDeclaration queryDeclaration = functionOrQueryCall.declaration as QueryDeclaration;
	        val Iterator<QueryParameterDeclaration> itr = queryDeclaration.parameters.iterator;
	
	        while (itr.hasNext) {
	            val QueryParameterDeclaration declaration = itr.next;
	
	            if (declaration.getDefault() === null && !functionOrQueryCall.arguments.exists[a | a.declaration.isEqual(declaration)]) {
	                error("Missing required query parameter:" + declaration.name,
	                    JsldslPackage::eINSTANCE.functionOrQueryCall_Arguments,
	                    MISSING_REQUIRED_PARAMETER,
	                    JsldslPackage::eINSTANCE.functionOrQueryCall.name)
	            }
	        }
    	}
    }

    @Check
    def checkLambdaExpression(LambdaCall lambdaCall) {
        if (lambdaCall.lambdaExpression !== null) {
            val lambdaExpressionTypeInfo = TypeInfo.getTargetType(lambdaCall.lambdaExpression)

            if (lambdaCall.declaration.expressionType === null && !lambdaExpressionTypeInfo.orderable) {
                error("Lambda expression must be orderable.",
                    JsldslPackage::eINSTANCE.lambdaCall_LambdaExpression,
                    INVALID_LAMBDA_EXPRESSION,
                    JsldslPackage::eINSTANCE.lambdaCall.name)
            }

            if (lambdaCall.declaration.expressionType !== null) {
                if (!TypeInfo.getTargetType(lambdaCall.declaration.expressionType).isCompatible(lambdaExpressionTypeInfo)) {
                    error("Lambda expression type mismatch.",
                        JsldslPackage::eINSTANCE.lambdaCall_LambdaExpression,
                        TYPE_MISMATCH,
                        JsldslPackage::eINSTANCE.lambdaCall.name)
                }
            }

            if (!isStaticExpression(lambdaCall.lambdaExpression)) {
                error(
                    "Self is not allowed in lambda expression.",
                    JsldslPackage::eINSTANCE.lambdaCall_LambdaExpression,
                    SELF_NOT_ALLOWED,
                    JsldslPackage::eINSTANCE.lambdaCall.name
                )
                return
            }
        }
    }

    @Check
    def checkAnnotationArgument(AnnotationArgument argument) {
        if (argument.declaration !== null) {
            val TypeInfo declarationTypeInfo = TypeInfo.getTargetType(argument.declaration.referenceType);

            if (argument.literal !== null) {
                val TypeInfo literalTypeInfo = TypeInfo.getTargetType(argument.literal);

                if (!declarationTypeInfo.isCompatible(literalTypeInfo)) {
                    error("Literal at annotation argument '" + argument.declaration.name + "' is not compatible. (Expected: "+declarationTypeInfo+", Got: "+literalTypeInfo+")",
                        JsldslPackage::eINSTANCE.annotationArgument_Literal,
                        TYPE_MISMATCH,
                        JsldslPackage::eINSTANCE.annotationArgument.name)
                }
            }

            if (argument.reference !== null) {
                val TypeInfo referenceTypeInfo = TypeInfo.getTargetType(argument.reference.referenceType);

                if (!declarationTypeInfo.isCompatible(referenceTypeInfo)) {
                    error("Type mismatch at annotation argument '" + argument.declaration.name + "'",
                        JsldslPackage::eINSTANCE.annotationArgument_Reference,
                        TYPE_MISMATCH,
                        JsldslPackage::eINSTANCE.annotationArgument.name)
                }
            }
        }

        var EList<AnnotationArgument> arguments = (argument.eContainer as AnnotationMark).arguments;

        if (arguments.filter[a | a.declaration.isEqual(argument.declaration)].size > 1) {
            error("Duplicate annotation parameter:" + argument.declaration.name,
                JsldslPackage::eINSTANCE.annotationArgument_Declaration,
                DUPLICATE_PARAMETER,
                JsldslPackage::eINSTANCE.annotationArgument.name)
        }
    }

    @Check
    def checkAnnotationRequiredArguments(AnnotationMark annotation) {
        val AnnotationDeclaration annotationDeclaration = annotation.declaration;
        val Iterator<AnnotationParameterDeclaration> itr = annotationDeclaration.parameters.iterator;

        while (itr.hasNext) {
            val AnnotationParameterDeclaration declaration = itr.next;

            if (!annotation.arguments.exists[a | a.declaration.isEqual(declaration)]) {
                error("Missing required annotation parameter:" + declaration.name,
                    JsldslPackage::eINSTANCE.annotationMark_Declaration,
                    MISSING_REQUIRED_PARAMETER,
                    JsldslPackage::eINSTANCE.annotationMark.name)
            }
        }
    }

    @Check
    def checkAnnotationMark(AnnotationMark mark) {
        if (mark.declaration.targets.size == 0) {
            return
        }

        var error = false;

        switch mark.eContainer {
            ModelDeclaration:                     error = !mark.declaration.targets.exists[t | t.model]
            ModelImportDeclaration:               error = !mark.declaration.targets.exists[t | t.^import]
            DataTypeDeclaration:                  error = !mark.declaration.targets.exists[t | t.type]
            EnumDeclaration:                      error = !mark.declaration.targets.exists[t | t.enumeration]
            EntityDeclaration:                    error = !mark.declaration.targets.exists[t | t.entity]
            ViewDeclaration:                      error = !mark.declaration.targets.exists[t | t.view]
            RowDeclaration:                       error = !mark.declaration.targets.exists[t | t.row]
            ActorDeclaration:                     error = !mark.declaration.targets.exists[t | t.actor]
            TransferDeclaration:                  error = !mark.declaration.targets.exists[t | t.transfer]
            QueryDeclaration:                     error = !mark.declaration.targets.exists[t | t.query]

            EnumLiteral:                          error = !mark.declaration.targets.exists[t | t.enumLiteral]
            
            EntityFieldDeclaration:               error = !mark.declaration.targets.exists[t | t.entityField]
            EntityRelationDeclaration:            error = !mark.declaration.targets.exists[t | t.entityRelation]

            ViewActionDeclaration:          error = !mark.declaration.targets.exists[t | t.viewAction]
            ViewFieldDeclaration:           error = !mark.declaration.targets.exists[t | t.viewField]
            ViewGroupDeclaration:           error = !mark.declaration.targets.exists[t | t.viewGroup]
            ViewLinkDeclaration:            error = !mark.declaration.targets.exists[t | t.viewLink]
            ViewTableDeclaration:           error = !mark.declaration.targets.exists[t | t.viewTable]
            ViewTabsDeclaration:            error = !mark.declaration.targets.exists[t | t.viewTabs]

            RowColumnDeclaration:           error = !mark.declaration.targets.exists[t | t.rowColumn]

            ActorMenuDeclaration:           error = !mark.declaration.targets.exists[t | t.actorMenu]
            ActorGroupDeclaration:          error = !mark.declaration.targets.exists[t | t.actorGroup]
            ActorAccessDeclaration:         error = !mark.declaration.targets.exists[t | t.actorAccess]

            TransferActionDeclaration:      error = !mark.declaration.targets.exists[t | t.transferAction]
            TransferFieldDeclaration:       error = !mark.declaration.targets.exists[t | t.transferField]
            TransferRelationDeclaration:    error = !mark.declaration.targets.exists[t | t.transferRelation]

            TransferEventDeclaration:       error = (!mark.declaration.targets.exists[t | t.transferEvent] && mark.parentContainer(TransferDeclaration) instanceof SimpleTransferDeclaration) ||
                                                    (!mark.declaration.targets.exists[t | t.viewEvent] && mark.parentContainer(TransferDeclaration) instanceof ViewDeclaration)
        }

        if (error) {
            error("Annotation @" + mark.declaration.name +" is not applicable on " + String.join(" ", mark.eContainer.eClass.name.split("(?=\\p{Upper})")).toLowerCase + ".",
                JsldslPackage::eINSTANCE.annotationMark_Declaration,
                INVALID_ANNOTATION)
        }
    }

    @Check
    def checkAssociation(EntityRelationDeclaration relation) {
        // System.out.println("checkAssociationOpposite: " + relation + " opposite: " + relation?.opposite + " type: " + relation?.opposite?.oppositeType)

		if (relation.calculated) return;
		if (!(relation.referenceType instanceof EntityDeclaration)) return;

        // Check the referenced opposite relation type reference back to this relation
        if (relation.opposite?.oppositeType !== null) {
            // System.out.println(" -- " + relation + " --- " + relation.opposite?.oppositeType?.opposite?.oppositeType)
            if (relation !== relation.opposite?.oppositeType?.opposite?.oppositeType) {
                error("The relation's opposite does not match '" + relation.opposite.oppositeType.name + "'.",
                    JsldslPackage::eINSTANCE.entityRelationOpposite.getEStructuralFeature("ID"),
                    OPPOSITE_TYPE_MISMATH)
            }
        }

        // Check this relation without oppoite type is referenced from another relation in the relation target type
        if (relation.opposite === null) {
            val selectableRelatations = (relation.referenceType as EntityDeclaration).getAllStoredRelations(null)
            val relationReferencedBack = selectableRelatations.filter[r | r.opposite !== null && r.opposite.oppositeType === relation].toList
            // System.out.println(" -- " + relation + " --- Referenced back: " + relationReferencedBack.map[r | r.eContainer.fullyQualifiedName + "#" + r.name].join(", "))
            if (!relationReferencedBack.empty) {
                error("The relation does not declare an opposite relation, but the following relations refer to this relation as opposite: " +
                    relationReferencedBack.map[r | "'" + r.eContainer.fullyQualifiedName.toString("::") + "#" + r.name + "'"].join(", "),
                    JsldslPackage::eINSTANCE.entityRelationOpposite.getEStructuralFeature("ID"),
                    OPPOSITE_TYPE_MISMATH)
            }
        }
    }

    @Check(CheckType::NORMAL)
    def checkCycleInInheritence(EntityDeclaration entity) {
        // System.out.println(" -- " + relation + " --- Referenced back: " + relationReferencedBack.map[r | r.eContainer.fullyQualifiedName + "#" + r.name].join(", "))

        if (entity.superEntityTypes.contains(entity)) {
            error("Cycle in the inheritance tree of entity '" + entity.name + "'.",
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
            error("Member name: '" + member.name + "' is too long, it must be " + MEMBER_NAME_LENGTH_MAX + " characters at most.",
                member.nameAttribute,
                MEMBER_NAME_TOO_LONG,
                member.name)
        }
    }

    @Check
    def checkForDuplicateNameForAddedOpposite(EntityRelationOppositeInjected opposite) {
        if (opposite.name !== null && !opposite.name.blank) {
            val member = opposite.eContainer as EntityRelationDeclaration
            if (member.referenceType instanceof EntityDeclaration && (member.referenceType as EntityDeclaration).getMemberNames.contains(opposite.name)) {
                error("Duplicate member name at the opposite side of '" + member.name + "':'" + opposite.name + "'",
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
    def checkForDuplicateNameForQueryParameters(QueryParameterDeclaration parameter) {
        if (parameter.eContainer.eContents.filter[c | c.name.toLowerCase.equals(parameter.name.toLowerCase)].size > 1) {
            error("Duplicate declaration of parameter: '" + parameter.name + "'",
                parameter.nameAttribute,
                DUPLICATE_DECLARATION_NAME,
                parameter.name)
        }
    }

    @Check
    def checkForDuplicateNameForAnnotationParameters(AnnotationParameterDeclaration parameter) {
        if (parameter.eContainer.eContents.filter[c | c.name.toLowerCase.equals(parameter.name.toLowerCase)].size > 1) {
            error("Duplicate declaration of parameter: '" + parameter.name + "'",
                parameter.nameAttribute,
                DUPLICATE_DECLARATION_NAME,
                parameter.name)
        }
    }

    @Check
    def checkForDuplicateNameForDeclaration(Declaration declaration) {
    	if (!(declaration.eContainer instanceof ModelDeclaration)) return;
    	
        if (declaration instanceof FunctionDeclaration) return;
        if (declaration instanceof LambdaDeclaration) return;

        if ((declaration.eContainer as ModelDeclaration).getDeclarationNames(declaration).map[n | n.toLowerCase].contains(declaration.name.toLowerCase)) {
            error("Duplicate declaration name: '" + declaration.name + "'",
                declaration.nameAttribute,
                DUPLICATE_DECLARATION_NAME,
                declaration.name)
        }
    }

    @Check
    def checkMimeType(MimeType mimeType) {
        if (!Pattern.matches("^([a-zA-Z0-9]+([\\._+-][a-zA-Z0-9]+)*)/(\\*|([a-zA-Z0-9]+([\\._+-][a-zA-Z0-9]+)*))$", mimeType.value.stringLiteralValue)) {
            error("Invalid mime type.",
                JsldslPackage::eINSTANCE.mimeType_Value,
                INVALID_MIMETYPE,
                mimeType.value.stringLiteralValue
            )
        }
    }

    @Check
	def	checkModifierRequired(DataTypeDeclaration dataType) {
		if (TypeInfo.getTargetType(dataType).isString) {
			if (dataType.getModifier(JsldslPackage::eINSTANCE.minSizeModifier) === null) {
	            error("min-size modifier is required",
	                JsldslPackage::eINSTANCE.named_Name,
	                INVALID_DECLARATION,
	                JsldslPackage::eINSTANCE.named.name)
			}

			if (dataType.getModifier(JsldslPackage::eINSTANCE.maxSizeModifier) === null) {
	            error("max-size modifier is required",
	                JsldslPackage::eINSTANCE.named_Name,
	                INVALID_DECLARATION,
	                JsldslPackage::eINSTANCE.named.name)
			}
		}
		
		else if (TypeInfo.getTargetType(dataType).isNumeric) {
			if (dataType.getModifier(JsldslPackage::eINSTANCE.precisionModifier) === null) {
	            error("precision modifier is required",
	                JsldslPackage::eINSTANCE.named_Name,
	                INVALID_DECLARATION,
	                JsldslPackage::eINSTANCE.named.name)
			}

			if (dataType.getModifier(JsldslPackage::eINSTANCE.scaleModifier) === null) {
	            error("scale modifier is required",
	                JsldslPackage::eINSTANCE.named_Name,
	                INVALID_DECLARATION,
	                JsldslPackage::eINSTANCE.named.name)
			}
		}

		else if (TypeInfo.getTargetType(dataType).isBinary) {
			if (dataType.getModifier(JsldslPackage::eINSTANCE.mimeTypesModifier) === null) {
	            error("mime-type modifier is required",
	                JsldslPackage::eINSTANCE.named_Name,
	                INVALID_DECLARATION,
	                JsldslPackage::eINSTANCE.named.name)
			}

			if (dataType.getModifier(JsldslPackage::eINSTANCE.maxFileSizeModifier) === null) {
	            error("max-file-size modifier is required",
	                JsldslPackage::eINSTANCE.named_Name,
	                INVALID_DECLARATION,
	                JsldslPackage::eINSTANCE.named.name)
			}
		}
	}

    @Check
    def checkModifierMinSize(MinSizeModifier minSizeModifier) {
        val maxSizeModifier = (minSizeModifier.eContainer as Modifiable).getModifier(JsldslPackage::eINSTANCE.maxSizeModifier) as MaxSizeModifier
		if (maxSizeModifier === null) return;
        if (minSizeModifier.value > maxSizeModifier.value) {
            error("min-size must be less than/equal to max-size",
                JsldslPackage::eINSTANCE.minSizeModifier_Value,
                MIN_SIZE_MODIFIER_IS_TOO_LARGE,
                JsldslPackage::eINSTANCE.minSizeModifier.name)
        }
    }

    @Check
    def checkModifierMaxSize(MaxSizeModifier modifier) {
		if (modifier.value < BigInteger.ONE) {
            error("max-size must be greater than 0",
                JsldslPackage::eINSTANCE.maxSizeModifier_Value,
                MAX_SIZE_MODIFIER_IS_NEGATIVE,
                JsldslPackage::eINSTANCE.maxSizeModifier.name)
        }

		if (modifier.value > MODIFIER_MAX_SIZE_MAX_VALUE) {
            error("max-size must be less than/equal to " + MODIFIER_MAX_SIZE_MAX_VALUE,
                JsldslPackage::eINSTANCE.maxSizeModifier_Value,
                MAX_SIZE_MODIFIER_IS_TOO_LARGE,
                JsldslPackage::eINSTANCE.maxSizeModifier.name)
        }
    }

    @Check
    def checkModifierPrecision(PrecisionModifier precision) {
        if (precision.value <= BigInteger.ZERO) {
            error("Precision must be greater than 0",
                JsldslPackage::eINSTANCE.precisionModifier_Value,
                PRECISION_MODIFIER_IS_NEGATIVE,
                JsldslPackage::eINSTANCE.precisionModifier.name)
        } else if (precision.value > PRECISION_MAX_VALUE) {
            error("Precision must be less than " + PRECISION_MAX_VALUE.add(new BigInteger("1")),
                JsldslPackage::eINSTANCE.precisionModifier_Value,
                PRECISION_MODIFIER_IS_TOO_LARGE,
                JsldslPackage::eINSTANCE.precisionModifier.name)
        }
    }

    @Check
    def checkModifierScale(ScaleModifier scale) {
        if (scale.value < BigInteger.ZERO) {
            error("Scale must be greater than/equal to 0",
                JsldslPackage::eINSTANCE.scaleModifier_Value,
                SCALE_MODIFIER_IS_NEGATIVE,
                JsldslPackage::eINSTANCE.scaleModifier.name)
        }
        
        val precision = (scale.eContainer as Modifiable).getModifier(JsldslPackage::eINSTANCE.precisionModifier) as PrecisionModifier
		if (precision === null) return;
        if (scale.value >= precision.value) {
            error("Scale must be less than the defined precision: " + precision.value,
                JsldslPackage::eINSTANCE.scaleModifier_Value,
                SCALE_MODIFIER_IS_TOO_LARGE,
                JsldslPackage::eINSTANCE.scaleModifier.name)
        }
    }

	@Check
	def checkModifierDetail(DetailModifier modifier) {
		if (!(modifier.eContainer instanceof ActorMenuDeclaration)) {
			return
		}
		
		val ActorMenuDeclaration menu = modifier.eContainer as ActorMenuDeclaration
		
		if (menu.referenceType instanceof ViewDeclaration) {
            error("Detail modifier cannot be used for View menu.",
                JsldslPackage::eINSTANCE.detailModifier.getEStructuralFeature("ID"),
                INVALID_DECLARATION)
		}
	}

	@Check
	def checkModifierRows(RowsModifier modifier) {
		if (!(modifier.eContainer instanceof ActorMenuDeclaration)) {
			return
		}
		
		val ActorMenuDeclaration menu = modifier.eContainer as ActorMenuDeclaration
		
		if (menu.referenceType instanceof ViewDeclaration) {
            error("Rows modifier cannot be used for View menu.",
                JsldslPackage::eINSTANCE.rowsModifier.getEStructuralFeature("ID"),
                INVALID_DECLARATION)
		}
	}

    @Check
    def checkEnumLiteralMinimum(EnumDeclaration _enum) {
        if (_enum.literals.size < 1) {
            error("Enumeration must have at least one member: " + _enum.name + ".",
                JsldslPackage::eINSTANCE.enumDeclaration_Literals,
                ENUM_MEMBER_MISSING,
                JsldslPackage::eINSTANCE.enumDeclaration.name)
        }
    }

    @Check
    def checkEnumOrdinal(EnumLiteral literal) {
        if (literal.value > ENUM_LITERAL_ORDINAL_MAX_VALUE) {
            error("Enumeration ordinal is greater than the maximum allowed " + ENUM_LITERAL_ORDINAL_MAX_VALUE + " at '" + literal.name + "'.",
                JsldslPackage::eINSTANCE.enumLiteral_Value,
                ENUM_ORDINAL_IS_TOO_LARGE,
                JsldslPackage::eINSTANCE.enumLiteral.name)
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
            error("Duplicate literal name: '" + literal.name + "'.",
                JsldslPackage::eINSTANCE.named_Name,
                ENUM_LITERAL_NAME_COLLISION,
                literal.name)
        }
        if (collidingOrdinals.size > 0 && collidingOrdinals.keySet.contains(literal.value)) {
            error("Duplicate ordinal: " + literal.value + ".",
                JsldslPackage::eINSTANCE.enumLiteral_Value,
                ENUM_LITERAL_ORDINAL_COLLISION,
                literal.name)
        }
    }
    
    @Check
    def checkAbstractComposition(EntityFieldDeclaration member) {
    	if (member.calculated) return;
    	
	    if (member.referenceType instanceof EntityDeclaration) {
	        val reference = member.referenceType as EntityDeclaration
		    if (reference.isAbstract()) {
		    	error("You cannot use entity named '" + (member.referenceType as EntityDeclaration).name + "' as a field type, because it is abstract.",
		             JsldslPackage::eINSTANCE.entityMemberDeclaration_ReferenceType,
		             FIELD_TYPE_IS_ABSRTACT_ENTITY,
		             JsldslPackage::eINSTANCE.entityFieldDeclaration.name)
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
                error("Ternary condition must be boolean type.",
                    JsldslPackage::eINSTANCE.ternaryOperation_Condition,
                    TYPE_MISMATCH)
            }
            if (!elseTypeInfo.isCompatible(thenTypeInfo)) {
                error("'else' branch must be compatible type with 'then' branch.",
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
                error("Operand of negation must be boolean type.",
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
                error("Left operand of '" + it.getOperator() + "' cannot be binary type.",
                    JsldslPackage::eINSTANCE.binaryOperation_LeftOperand,
                    TYPE_MISMATCH,
                    JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
            }
            if (rightTypeInfo.binary) {
                error("Right operand of '" + it.getOperator() + "' cannot be binary type.",
                    JsldslPackage::eINSTANCE.binaryOperation_RightOperand,
                    TYPE_MISMATCH,
                    JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
            }

            if (Arrays.asList("!=","==",">=","<=",">","<").contains(it.getOperator())) {
                if (leftTypeInfo.collection) {
                    error("Left operand of '" + it.getOperator() + "' cannot be collection.",
                        JsldslPackage::eINSTANCE.binaryOperation_LeftOperand,
                        TYPE_MISMATCH,
                        JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
                }
                if (rightTypeInfo.collection) {
                    error("Right operand of '" + it.getOperator() + "' cannot be collection.",
                        JsldslPackage::eINSTANCE.binaryOperation_RightOperand,
                        TYPE_MISMATCH,
                        JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
                }
            } else if ("+".equals(it.getOperator())) {
                if (!leftTypeInfo.numeric && !leftTypeInfo.string) {
                    error("Left operand of '" + it.getOperator() + "' must be numeric or string type.",
                        JsldslPackage::eINSTANCE.binaryOperation_LeftOperand,
                        TYPE_MISMATCH,
                        JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
                }
                if (!rightTypeInfo.numeric && !rightTypeInfo.string) {
                    error("Right operand of '" + it.getOperator() + "' must be numeric or string type.",
                        JsldslPackage::eINSTANCE.binaryOperation_RightOperand,
                        TYPE_MISMATCH,
                        JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
                }
            } else if (Arrays.asList("^", "-", "*", "/", "mod", "div").contains(it.getOperator())) {
                if (!leftTypeInfo.numeric) {
                    error("Left operand of '" + it.getOperator() + "' must be numeric type",
                        JsldslPackage::eINSTANCE.binaryOperation_LeftOperand,
                        TYPE_MISMATCH,
                        JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
                }
                if (!rightTypeInfo.numeric) {
                    error("Right operand of '" + it.getOperator() + "' must be numeric type",
                        JsldslPackage::eINSTANCE.binaryOperation_RightOperand,
                        TYPE_MISMATCH,
                        JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
                }
            } else if (Arrays.asList("implies","or","xor","and").contains(it.getOperator())) {
                if (!leftTypeInfo.isBoolean()) {
                    error("Left operand of '" + it.getOperator() + "' must be boolean type.",
                        JsldslPackage::eINSTANCE.binaryOperation_LeftOperand,
                        TYPE_MISMATCH,
                        JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
                }
                if (!rightTypeInfo.isBoolean()) {
                    error("Right operand of '" + it.getOperator() + "' must be boolean type.",
                        JsldslPackage::eINSTANCE.binaryOperation_RightOperand,
                        TYPE_MISMATCH,
                        JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
                }
            }

            if (!leftTypeInfo.isCompatible(rightTypeInfo)) {
                error("Left and right operand type mismatch at '" + it.getOperator() + "'.",
                    JsldslPackage::eINSTANCE.binaryOperation_Operator,
                    TYPE_MISMATCH,
                    JsldslPackage::eINSTANCE.binaryOperation_Operator.name)
            }
        } catch (IllegalArgumentException illegalArgumentException) {
            return
        }
    }

    def boolean isStaticExpression(Expression expr) {
        val boolean retValue = EcoreUtil.getAllContents(expr, true).
            filter[i | i instanceof Self || (i instanceof NavigationBaseDeclarationReference && (i as NavigationBaseDeclarationReference).reference instanceof EntityMapDeclaration)].
            size == 0;

        return retValue;
    }

	@Check
	def checkDefaultModifier(DefaultModifier modifier) {
		if (modifier.expression === null) {
			return
		}
		
		if (modifier.eContainer instanceof EntityMemberDeclaration) {
			val EntityMemberDeclaration member = modifier.eContainer as EntityMemberDeclaration

	        if (!modifier.expression.isStaticExpression()) {
	            error("Default expression cannot contain 'self'.",
	                JsldslPackage::eINSTANCE.defaultModifier_Expression,
	                SELF_NOT_ALLOWED)
	        }
			
	        if (member.calculated) {
	            error("Calculated entity member cannot have default value.",
	                JsldslPackage::eINSTANCE.defaultModifier_Expression,
	                INVALID_DECLARATION)
	        }

	    	if (member instanceof EntityFieldDeclaration && member.referenceType instanceof EntityDeclaration) {
	            error("A composition cannot have default value.",
	                JsldslPackage::eINSTANCE.defaultModifier_Expression,
	                INVALID_DECLARATION)
	    	}

	        if (!TypeInfo.getTargetType(member).isCompatible(TypeInfo.getTargetType(modifier.expression))) {
	            error("Type mismatch. Default value does not match field type.",
	                JsldslPackage::eINSTANCE.defaultModifier_Expression,
	                TYPE_MISMATCH)
	        }
		}

		else if (modifier.eContainer instanceof TransferDataDeclaration) {
			val TransferDataDeclaration member = modifier.eContainer as TransferDataDeclaration

	        if (!modifier.expression.isStaticExpression()) {
	            error("Default expression cannot contain mapping field.",
	                JsldslPackage::eINSTANCE.defaultModifier_Expression,
	                NON_STATIC_EXPRESSION)
	        }
			
			if (member.getterExpr !== null && member.mappedMember === null) {
	            error("Getter expression must select a stored member of the mapped entity.",
	                JsldslPackage::eINSTANCE.defaultModifier_Expression,
	                INVALID_DECLARATION)
			}

	        if (!TypeInfo.getTargetType(member).isCompatible(TypeInfo.getTargetType(modifier.expression))) {
	            error("Type mismatch. Default value does not match field type.",
	                JsldslPackage::eINSTANCE.defaultModifier_Expression,
	                TYPE_MISMATCH)
	        }
		}
	}

	@Check
	def checkInputModifier(InputModifier modifier) {
		val TransferDataDeclaration member = modifier.eContainer as TransferDataDeclaration
		
		if (member.getterExpr !== null && member.mappedMember === null) {
            error("Invalid input modifier. Getter expression must select a stored member of the mapped entity.",
                JsldslPackage::eINSTANCE.inputModifier.getEStructuralFeature("ID"),
                INVALID_DECLARATION)
		}
	}

    @Check
	def checkTransferChoice(TransferChoiceModifier choice) {
		var TransferRelationDeclaration relation = choice.eContainer as TransferRelationDeclaration
		
        if (!TypeInfo.getTargetType(relation).isCompatibleCollection(TypeInfo.getTargetType(choice.expression))) {
            error("Invalid choices modifier. Choices must return compatible collection with field type.",
                JsldslPackage::eINSTANCE.transferChoiceModifier.getEStructuralFeature("ID"),
                INVALID_CHOICES)
        }

		val mappedMember = relation.mappedMember;

		if (relation.getterExpr !== null && mappedMember === null) {
            error("Invalid choices modifier. Getter expression must select a stored member of the mapped entity.",
                JsldslPackage::eINSTANCE.transferChoiceModifier.getEStructuralFeature("ID"),
                INVALID_CHOICES)
		}

		if (relation.getterExpr !== null && mappedMember instanceof EntityFieldDeclaration && (mappedMember as EntityFieldDeclaration).referenceType instanceof EntityDeclaration) {
            error("Invalid choices modifier. Choices modifier is not allowed if getter expression selects an entity containment.",
                JsldslPackage::eINSTANCE.transferChoiceModifier.getEStructuralFeature("ID"),
                INVALID_CHOICES)
		}
	}


    @Check
    def checkTransferField(TransferFieldDeclaration field) {
        try {
            if (field.getterExpr !== null && !TypeInfo.getTargetType(field).isCompatible(TypeInfo.getTargetType(field.getterExpr))) {
                error("Type mismatch. Getter expression value does not match field type at '" + field.name + "'.",
                    JsldslPackage::eINSTANCE.transferDataDeclaration_GetterExpr,
                    TYPE_MISMATCH)
            }
        } catch (IllegalArgumentException illegalArgumentException) {
            return
        }
    }

    @Check
    def checkTransferRelation(TransferRelationDeclaration relation) {
    	if (relation.referenceType instanceof PrimitiveDeclaration && relation.many) {
            error("Primitive field cannot be a collection.",
                JsldslPackage::eINSTANCE.transferRelationDeclaration_ReferenceType,
                INVALID_DECLARATION)
    	}

    	if (relation.many && relation.required) {
            error("A collection cannot be required.",
                JsldslPackage::eINSTANCE.transferDataDeclaration_Required,
                INVALID_DECLARATION)
    	}

        try {
            if (relation.getterExpr !== null && !TypeInfo.getTargetType(relation).isCompatible(TypeInfo.getTargetType(relation.getterExpr))) {
                error("Type mismatch. Getter expression value does not match relation type at '" + relation.name + "'.",
                    JsldslPackage::eINSTANCE.transferDataDeclaration_GetterExpr,
                    TYPE_MISMATCH)
            }
        } catch (IllegalArgumentException illegalArgumentException) {
            return
        }
    }

    @Check
    def checkEntityStoredFieldMember(EntityFieldDeclaration member) {
    	if (member.calculated) return;
    	
        try {
        	var TypeInfo memberType = TypeInfo.getTargetType(member);
        	var TypeInfo exprType = TypeInfo.getTargetType(member.defaultExpr);

            if (member.defaultExpr !== null && !memberType.isCompatible(exprType)) {
                error("Type mismatch. Default value expression does not match field type at '" + member.name + "'.",
                    JsldslPackage::eINSTANCE.entityMemberDeclaration.getEStructuralFeature("ID"),
                    TYPE_MISMATCH)
            }
        } catch (IllegalArgumentException illegalArgumentException) {
            return
        }
    }

    @Check
    def checkEntityStoredRelationMember(EntityRelationDeclaration member) {
    	if (member.calculated) return;

        try {
            if (member.defaultExpr !== null && !TypeInfo.getTargetType(member).isCompatible(TypeInfo.getTargetType(member.defaultExpr))) {
                error("Type mismatch. Default value expression does not match relation type at '" + member.name + "'.",
                    JsldslPackage::eINSTANCE.entityMemberDeclaration.getEStructuralFeature("ID"),
                    TYPE_MISMATCH)
            }
        } catch (IllegalArgumentException illegalArgumentException) {
            return
        }
    }

    @Check
    def checkEntityDerived(EntityMemberDeclaration member) {
    	if (!member.calculated) return;

        try {
            if (member.getterExpr !== null && !TypeInfo.getTargetType(member).isCompatible(TypeInfo.getTargetType(member.getterExpr))) {
                error("Type mismatch. Derived value expression does not match derived field type at '" + member.name + "'.",
                    JsldslPackage::eINSTANCE.entityMemberDeclaration_GetterExpr,
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
            if (query.getterExpr !== null && !TypeInfo.getTargetType(query).isCompatible(TypeInfo.getTargetType(query.getterExpr))) {
                error("Type mismatch. Query expression does not match query type at '" + query.name + "'.",
                    JsldslPackage::eINSTANCE.queryDeclaration_GetterExpr,
                    TYPE_MISMATCH,
                    JsldslPackage::eINSTANCE.queryDeclaration.name)
            }

            if (query.isMany && !(query.referenceType instanceof EntityDeclaration)) {
                error("Invalid collection of primitives at '" + query.name + "'.",
                    JsldslPackage::eINSTANCE.queryDeclaration_ReferenceType,
                    INVALID_COLLECTION)
            }
        } catch (IllegalArgumentException illegalArgumentException) {
            return
        }
    }

    @Check
    def checkForDuplicateNameForTransferMemberDeclaration(TransferMemberDeclaration member) {
        val TransferDeclaration transfer = member.parentContainer(TransferDeclaration)

    	if (transfer === null) {
    		return
    	}

        if (transfer.map !== null && member.name.toLowerCase.equals(transfer.map.name.toLowerCase)) {
            error("Member declaration name conflicts with mapping field name: '" + member.name + "'.",
                member.nameAttribute,
                DUPLICATE_MEMBER_NAME,
                member.name)
        }

        if (member instanceof Named && transfer.members.filter[m | m instanceof Named && m.name.toLowerCase.equals(member.name.toLowerCase)].size > 1) {
            error("Duplicate member declaration: '" + member.name + "'.",
                member.nameAttribute,
                DUPLICATE_MEMBER_NAME,
                member.name)
        }
    }


    @Check
    def checkGuard(GuardModifier guard) {
        if (guard.expression !== null && !TypeInfo.getTargetType(guard.expression).isBoolean) {
            error("Guard expression must have boolean return value.",
                JsldslPackage::eINSTANCE.guardModifier_Expression,
                TYPE_MISMATCH,
                JsldslPackage::eINSTANCE.guardModifier.name)
        }
    }

    @Check
    def checkActorIdentity(IdentityModifier identity) {
        if (!(identity.expression instanceof Navigation)) {
            error("Invalid actor identity. Identity must be mapped to an identifier of the mapped entity type.",
                JsldslPackage::eINSTANCE.identityModifier_Expression,
                INVALID_IDENTITY_MAPPING)

            return;
        }

        val Navigation navigation = identity.expression as Navigation;

        if (!(navigation.base instanceof NavigationBaseDeclarationReference)) {
            error("Invalid actor identity. Identity must be mapped to an identifier of the mapped entity type.",
                JsldslPackage::eINSTANCE.identityModifier_Expression,
                INVALID_IDENTITY_MAPPING)

            return;
        }

        val NavigationBaseDeclarationReference navigationBaseDeclarationReference = navigation.base as NavigationBaseDeclarationReference;

        if (!(navigationBaseDeclarationReference.reference instanceof EntityMapDeclaration)) {
            error("Invalid actor identity. Identity must be mapped to an identifier of the mapped entity type.",
                JsldslPackage::eINSTANCE.identityModifier_Expression,
                INVALID_IDENTITY_MAPPING)

            return;
        }

        if (navigation.features.size() != 1) {
            error("Invalid actor identity. Identity must be mapped to an identifier of the mapped entity type.",
                JsldslPackage::eINSTANCE.identityModifier_Expression,
                INVALID_IDENTITY_MAPPING)

            return;
        }

        if (!(navigation.features.get(0) instanceof MemberReference)) {
            error("Invalid actor identity. Identity must be mapped to an identifier of the mapped entity type.",
                JsldslPackage::eINSTANCE.identityModifier_Expression,
                INVALID_IDENTITY_MAPPING)

            return;
        }

        val MemberReference memberReference = navigation.features.get(0) as MemberReference;

        if (!(memberReference.member instanceof EntityFieldDeclaration)) {
            error("Invalid actor identity. Identity must be mapped to an identifier of the mapped entity type.",
                JsldslPackage::eINSTANCE.identityModifier_Expression,
                INVALID_IDENTITY_MAPPING)

            return;
        }

        val EntityFieldDeclaration field = memberReference.member as EntityFieldDeclaration;

        if (!field.identifier) {
            error("Invalid actor identity. Identity must be mapped to an identifier of the mapped entity type.",
                JsldslPackage::eINSTANCE.identityModifier_Expression,
                INVALID_IDENTITY_MAPPING)

            return;
        }

        if (!TypeInfo.getTargetType(field).isString) {
            error("Invalid actor identity. Identifier must be a string.",
                JsldslPackage::eINSTANCE.identityModifier_Expression,
                INVALID_IDENTITY_MAPPING)

            return;
        }
    }

    @Check
    def checkSelf(Self myself) {
        // myself is for Rob :-)

        if (!TypeInfo.getTargetType(myself).isEntity()) {
            error("Not allowed to use:'self'.",
                JsldslPackage::eINSTANCE.self_IsSelf,
                INVALID_SELF_VARIABLE,
                JsldslPackage::eINSTANCE.^self.name)
        }
    }

    @Check
    def checkJavaBeanName(Named named) {
        // this rule is so ugly that it is deliberately undocumented

        if (named.name.length < 2) return;

        if (Character.isLowerCase(named.name.charAt(0)) && Character.isUpperCase(named.name.charAt(1))) {
            error("The first character cannot be lowercase and the second character uppercase in '" + named.name + "'.",
                JsldslPackage::eINSTANCE.named_Name,
                JAVA_BEAN_NAMING_ISSUE,
                JsldslPackage::eINSTANCE.named.name)
        }
    }

    def NavigationTarget getMappedField(TransferFieldDeclaration field) {
        if (!field.maps) return null;

        if (!(field.getterExpr instanceof Navigation)) {
            return null;
        }

        val Navigation navigation = field.getterExpr as Navigation;

        if (!(navigation.base instanceof NavigationBaseDeclarationReference)) {
            return null;
        }

        val NavigationBaseDeclarationReference navigationBaseDeclarationReference = navigation.base as NavigationBaseDeclarationReference;

        if (!(navigationBaseDeclarationReference.reference instanceof EntityMapDeclaration)) {
            return null;
        }

        if (navigation.features.size() != 1) {
            return null;
        }

        if (!(navigation.features.get(0) instanceof MemberReference)) {
            return null;
        }

        return (navigation.features.get(0) as MemberReference).member;
    }

    @Check
    def checkDuplicateFieldMapping(TransferFieldDeclaration field) {
        if (!field.maps) return;

        val TransferDeclaration transfer = field.parentContainer(TransferDeclaration);
        val NavigationTarget target = getMappedField(field); 

        if (target === null) return;

        if (transfer.members.filter[m | m instanceof TransferFieldDeclaration && target === getMappedField(m as TransferFieldDeclaration)].size > 1) {
            warning("More than one transfer field map the same entity field at '" + field.name + "'.",
                JsldslPackage::eINSTANCE.transferFieldDeclaration_ReferenceType,
                DUPLICATE_FIELD_MAPPING,
                JsldslPackage::eINSTANCE.named.name)
        }
    }
    
    @Check
    def checkTransferEvent(TransferEventDeclaration event) {
        val TransferDeclaration transfer = event.eContainer as TransferDeclaration;

        if (transfer.members.filter[m | m instanceof TransferEventDeclaration]
        	.map[m | m as TransferEventDeclaration]
        	.filter[e | e.getClass().equals(event.getClass()) && ((e.before && event.before) || (e.after && event.after) || (e.instead && event.instead))].size > 1)
        {
            error("Duplicate event declaration in transfer '" + transfer.name + "'.",
                JsldslPackage::eINSTANCE.transferEventDeclaration.getEStructuralFeature("ID"),
                DUPLICATE_EVENT)
        }
        
        if (transfer.map === null && !(event instanceof TransferInitializeDeclaration)) {
            error("Unmapped transfer object cannot have " + event.kind + " event handler.",
                JsldslPackage::eINSTANCE.transferEventDeclaration.getEStructuralFeature("ID"),
                INVALID_DECLARATION)
        }
    }
	
    @Check
    def checkTransferCreate(TransferCreateDeclaration declaration) {
        val TransferDeclaration transfer = declaration.eContainer as TransferDeclaration;

		if ((declaration.before || declaration.after) && declaration.parameterType !== null) {
            error("Before and after create event handler cannot have parameter.",
                JsldslPackage::eINSTANCE.transferCreateDeclaration_ParamaterName,
                INVALID_DECLARATION)
		}

		if (declaration.parameterType !== null) {
			if (declaration.parameterType.map === null ||
				declaration.parameterType.map.entity === null ||
				!TypeInfo.getTargetType(transfer.map.entity).isCompatible(TypeInfo.getTargetType(declaration.parameterType.map.entity)))
			{
	            error("Create parameter must be compatible to transfer object type.",
	                JsldslPackage::eINSTANCE.transferCreateDeclaration_ParamaterName,
	                INVALID_DECLARATION)
			}
		}
    }
    
    @Check
    def checkOppositeRequired(EntityRelationOppositeReferenced opposite) {
		if (opposite.oppositeType === null) return

    	val EntityRelationDeclaration relation = opposite.eContainer as EntityRelationDeclaration

    	if (relation.required && opposite.oppositeType.required) {
            error("Bidirectional relation is not allowed to be required on both ends.",
                JsldslPackage::eINSTANCE.entityRelationOppositeReferenced.getEStructuralFeature("ID"),
                INVALID_DECLARATION)
    	}
    }
    
    @Check
    def checkModifierDuplicate(Modifier modifier) {
        val Modifiable modifiable = modifier.eContainer as Modifiable;
    	
        if (modifiable.modifiers.filter[m | m.getClass().equals(modifier.getClass())].size > 1) {
            error("Duplicate modifier.",
                JsldslPackage::eINSTANCE.modifier_Type,
                DUPLICATE_MODIFIER)
        }
    }
    
    @Check
    def checkEntityMember(EntityMemberDeclaration member) {
    	if (member.referenceType instanceof PrimitiveDeclaration && member.many) {
            error("Primitive field cannot be a collection.",
                JsldslPackage::eINSTANCE.entityMemberDeclaration_ReferenceType,
                INVALID_DECLARATION)
    	}

    	if (member.many && member.required) {
            error("A collection cannot be required.",
                JsldslPackage::eINSTANCE.entityMemberDeclaration_Required,
                INVALID_DECLARATION)
    	}
    	
    	if (member.required && member.calculated) {
            error("A calculated member cannot be required.",
                JsldslPackage::eINSTANCE.entityMemberDeclaration_Required,
                INVALID_DECLARATION)
    	}
	}

    @Check
    def checkEntityField(EntityFieldDeclaration field) {
    	if (field.referenceType instanceof EntityDeclaration && field.calculated) {
            error("A composition cannot be calculated.",
                JsldslPackage::eINSTANCE.entityMemberDeclaration_GetterExpr,
                INVALID_DECLARATION)
    	}
    }
    
    @Check
    def checkEager(EagerModifier eager) {
		if (eager.eContainer instanceof EntityFieldDeclaration) {
			val field = eager.eContainer as EntityFieldDeclaration

	    	if (field.referenceType instanceof PrimitiveDeclaration) {
    			error("Eager modifier cannot be applied to primitive field.",
    				JsldslPackage::eINSTANCE.eagerModifier.getEStructuralFeature("ID"),
    				INVALID_DECLARATION)
            }
	    	else if (eager.value.isTrue) {
	    		info("Entity field is eager fetched by default.", JsldslPackage::eINSTANCE.eagerModifier.getEStructuralFeature("ID"), RECOMMENDATION)
	    	}
		}
		
		else if (eager.eContainer instanceof EntityRelationDeclaration) {
	    	if (!eager.value.isTrue) {
	    		info("Entity relation is lazy fetched by default.", JsldslPackage::eINSTANCE.eagerModifier.getEStructuralFeature("ID"), RECOMMENDATION)
	    	}
		}
		
		else if (eager.eContainer instanceof TransferRelationDeclaration) {
			val relation = eager.eContainer as TransferRelationDeclaration

			if (relation.getterExpr === null) {
    			error("Eager modifier needs a getter expression.",
    				JsldslPackage::eINSTANCE.eagerModifier.getEStructuralFeature("ID"),
    				INVALID_DECLARATION)
			}

			if ((relation.maps || relation.reads) && !eager.value.isTrue) {
	    		info("Mapped transfer relation is lazy fetched by default.", JsldslPackage::eINSTANCE.eagerModifier.getEStructuralFeature("ID"), RECOMMENDATION)
			}
		}    	
    }

    @Check
    def checkEntityName(EntityDeclaration entity) {
    	if (entity.name.length > 0 && Character.isLowerCase(entity.name.charAt(0))) {
	    	info("It is recommended to start entity names with uppercase letter.", JsldslPackage::eINSTANCE.named_Name, RECOMMENDATION)
    	}
	}

    @Check
    def checkEntityMemberName(EntityMemberDeclaration member) {
    	if (member.name.length > 0 && Character.isUpperCase(member.name.charAt(0))) {
	    	info("It is recommended to start entity member names with a lowercase letter.", JsldslPackage::eINSTANCE.named_Name, RECOMMENDATION)
    	}
	}

	@Check
	def checkMenu(ActorMenuDeclaration menu) {
		if (menu.referenceType instanceof ViewDeclaration && menu.many) {
            error("A view type cannot be a collection. Use row type instead.",
                JsldslPackage::eINSTANCE.transferRelationDeclaration_ReferenceType,
                INVALID_DECLARATION)
		}

		else if (menu.referenceType instanceof RowDeclaration && !menu.many) {
            error("A row type cannot be a single. Use view type instead.",
                JsldslPackage::eINSTANCE.transferRelationDeclaration_ReferenceType,
                INVALID_DECLARATION)
		}
	}

	@Check
	def checkCreateModifier(CreateModifier modifier) {
		val TransferRelationDeclaration relation = modifier.eContainer as TransferRelationDeclaration
		
		if (relation.referenceType !== null && relation.referenceType.map === null) {
            error("Invalid create modifier. Create modifier cannot be used for unmapped relation.",
                JsldslPackage::eINSTANCE.createModifier.getEStructuralFeature("ID"),
                INVALID_DECLARATION)
		}
	}

	@Check
	def checkDeleteModifier(DeleteModifier modifier) {
		val TransferRelationDeclaration relation = modifier.eContainer as TransferRelationDeclaration
		
		if (relation.referenceType !== null && relation.referenceType.map === null) {
            error("Invalid delete modifier. Delete modifier cannot be used for unmapped relation.",
                JsldslPackage::eINSTANCE.deleteModifier.getEStructuralFeature("ID"),
                INVALID_DECLARATION)
		}
	}

	@Check
	def checkUpdateModifier(UpdateModifier modifier) {
		val TransferRelationDeclaration relation = modifier.eContainer as TransferRelationDeclaration
		
		if (relation.referenceType !== null && relation.referenceType.map === null) {
            error("Invalid update modifier. Update modifier cannot be used for unmapped relation.",
                JsldslPackage::eINSTANCE.updateModifier.getEStructuralFeature("ID"),
                INVALID_DECLARATION)
		}
	}
	
	@Check
	def checkTransferAction(TransferActionDeclaration action) {
		action.errors.forEach[e |
			if (action.errors.filter[other | other.isEqual(e)].size > 1) {
	            error("Duplicate error throws:" + e.name,
	                JsldslPackage::eINSTANCE.transferActionDeclaration.getEStructuralFeature("ID"),
	                DUPLICATE_ERROR_THROW,
	                e.name)
			}
		]
	}
}
