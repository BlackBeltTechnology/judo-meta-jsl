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
import hu.blackbelt.judo.meta.jsl.jsldsl.ModifierMaxSize
import hu.blackbelt.judo.meta.jsl.jsldsl.ModifierMinSize
import java.math.BigInteger
import hu.blackbelt.judo.meta.jsl.jsldsl.ModifierPrecision
import hu.blackbelt.judo.meta.jsl.jsldsl.ModifierScale
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
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryParameterDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryDeclaration
import org.eclipse.emf.ecore.util.EcoreUtil
import hu.blackbelt.judo.meta.jsl.jsldsl.Feature
import hu.blackbelt.judo.meta.jsl.jsldsl.MemberReference
import hu.blackbelt.judo.meta.jsl.jsldsl.Expression
import java.util.ArrayList
import hu.blackbelt.judo.meta.jsl.jsldsl.Self
import hu.blackbelt.judo.meta.jsl.jsldsl.LambdaVariable
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
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferDefault
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferConstructorDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.Navigation
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityMapDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.GuardModifier
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationTarget
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewActionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewGroupDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewLinkDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewSubmitDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewTableDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewTabsDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.RowColumnDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorGroupDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferRelationDeclaration

import hu.blackbelt.judo.meta.jsl.jsldsl.EntityCalculatedMemberDeclaration

import hu.blackbelt.judo.meta.jsl.jsldsl.EntityStoredFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityStoredRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferActionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityCalculatedFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityCalculatedRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferInitializerDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferSubmitDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorMenuDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorAccessDeclaration

import hu.blackbelt.judo.meta.jsl.jsldsl.TransferCreateDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferUpdateDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferDeleteDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeReferenced

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
    public static val ANNOTATION_CYCLE = ISSUE_CODE_PREFIX + "AnnotationCycle"
    public static val SELF_NOT_ALLOWED = ISSUE_CODE_PREFIX + "SelfNotAllowed"
    public static val INVALID_COLLECTION = ISSUE_CODE_PREFIX + "InvalidCollection"
    public static val INVALID_ANNOTATION = ISSUE_CODE_PREFIX + "InvalidAnnotation"
    public static val INVALID_ANNOTATION_MARK = ISSUE_CODE_PREFIX + "InvalidAnnotationMark"
    public static val DUPLICATE_AUTOMAP = ISSUE_CODE_PREFIX + "DuplicateAutomap"
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
    public static val DUPLICATE_INITIALIZER = ISSUE_CODE_PREFIX + "DuplicateInitializer"
    public static val DUPLICATE_CREATE = ISSUE_CODE_PREFIX + "DuplicateCreate"
    public static val DUPLICATE_UPDATE = ISSUE_CODE_PREFIX + "DuplicateUpdate"
    public static val DUPLICATE_DELETE = ISSUE_CODE_PREFIX + "DuplicateDelete"
    public static val DUPLICATE_SUBMIT = ISSUE_CODE_PREFIX + "DuplicateSubmit"
    public static val FIELD_TYPE_IS_ABSRTACT_ENTITY = ISSUE_CODE_PREFIX + "FieldTypeIsAbstractEntity"

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

    @Check
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

            if (queryCall.declaration !== null && queryCall.declaration.getterExpr !== null) {
                findExpressionCycle(queryCall.declaration.getterExpr, visited)
            }
        }

        val Iterator<Feature> featureIterator = EcoreUtil.getAllContents(expression, true).filter(Feature)
        while (featureIterator.hasNext) {
            val EObject obj = featureIterator.next()

            if (obj instanceof MemberReference && (obj as MemberReference).member instanceof EntityCalculatedMemberDeclaration) {
                val EntityCalculatedMemberDeclaration member = (obj as MemberReference).member as EntityCalculatedMemberDeclaration
                findExpressionCycle(member.getterExpr, visited)
            }
        }

        visited.remove(expression)
    }

    @Check
    def checkCyclicDerivedExpression(EntityCalculatedMemberDeclaration member) {
        try {
            findExpressionCycle(member.getterExpr, new ArrayList<Expression>())
        } catch (IllegalCallerException e) {
            error(
                "Cyclic expression at '" + member.name + "'.",
                JsldslPackage::eINSTANCE.entityCalculatedMemberDeclaration_GetterExpr,
                EXPRESSION_CYCLE,
                member.name
            )
            return
        }
    }

    @Check
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
    def checkSelfInFieldDefaultExpression(EntityStoredFieldDeclaration member) {
        if (member.defaultExpr !== null) {
            if (!this.isStaticExpression(member.defaultExpr)) {
                error(
                    "Self is not allowed in default expression at '" + member.name + "'.",
                    JsldslPackage::eINSTANCE.entityStoredFieldDeclaration_DefaultExpr,
                    SELF_NOT_ALLOWED,
                    member.name
                )
                return
            }
        }
    }

    @Check
    def checkSelfInRelationDefaultExpression(EntityStoredRelationDeclaration member) {
        if (member.defaultExpr !== null) {
            if (!this.isStaticExpression(member.defaultExpr)) {
                error(
                    "Self is not allowed in default expression at '" + member.name + "'.",
                    JsldslPackage::eINSTANCE.entityStoredRelationDeclaration_DefaultExpr,
                    SELF_NOT_ALLOWED,
                    member.name
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

    @Check
    def checkInvalidFunctionDeclaration(FunctionDeclaration functionDeclaration) {
        val ModelDeclaration modelDeclaration = functionDeclaration.eContainer as ModelDeclaration
        if (!modelDeclaration.fullyQualifiedName.equals("judo::functions")) {
            error("Invalid function declaration '" + functionDeclaration.name + "'. Function declaration is currently only allowed in the judo::functions model.",
                JsldslPackage::eINSTANCE.named_Name,
                INVALID_DECLARATION,
                functionDeclaration.name)
        }
    }

    @Check
    def checkInvalidLambdaDeclaration(LambdaDeclaration lambdaDeclaration) {
        val ModelDeclaration modelDeclaration = lambdaDeclaration.eContainer as ModelDeclaration
        if (!modelDeclaration.fullyQualifiedName.equals("judo::functions")) {
            error("Invalid lambda declaration '" + lambdaDeclaration.name + "'. Lambda declaration is currently only allowed in the judo::functions model.",
                JsldslPackage::eINSTANCE.named_Name,
                INVALID_DECLARATION,
                lambdaDeclaration.name)
        }
    }

    @Check
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
            error("Cycle in model import '" + modelImport.model.name + "'",
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
                error("Type mismatch. Incompatible query argument at '" + argument.declaration.name + "'.",
                    JsldslPackage::eINSTANCE.queryArgument_Expression,
                    TYPE_MISMATCH,
                    JsldslPackage::eINSTANCE.queryArgument.name)
            }

            if (!this.isStaticExpression(argument.expression)) {
                error("Self is not allowed in query argument expression at '" + argument.declaration.name + "'.",
                    JsldslPackage::eINSTANCE.queryArgument_Expression,
                    INVALID_SELF_VARIABLE,
                    JsldslPackage::eINSTANCE.queryArgument.name)
            }

            if (EcoreUtil.getAllContents(argument.expression, true).
                filter(NavigationBaseDeclarationReference).
                map[r | r.reference].filter(LambdaVariable).size > 0)
            {
                error("Lambda variable is not allowed in query argument expression at '" + argument.declaration.name + "'.",
                    JsldslPackage::eINSTANCE.queryArgument_Expression,
                    INVALID_LAMBDA_EXPRESSION,
                    JsldslPackage::eINSTANCE.queryArgument.name)
            }
        }

        val EObject container = argument.eContainer;
        var EList<QueryArgument> arguments;

        if (container instanceof QueryCall) {
            arguments = (container as QueryCall).arguments;
        }
        
        if (container instanceof MemberReference) {
            arguments = (container as MemberReference).arguments;
        }
        
        if (arguments.filter[a | a.declaration.isEqual(argument.declaration)].size > 1) {
            error("Duplicate query parameter:" + argument.declaration.name,
                JsldslPackage::eINSTANCE.queryArgument_Declaration,
                DUPLICATE_PARAMETER,
                JsldslPackage::eINSTANCE.queryArgument.name)
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

            if (!declarationTypeInfo.isBaseCompatible(exprTypeInfo)) {
                error("Type mismatch. Incompatible function argument at '" + argument.declaration.name + "'.",
                    JsldslPackage::eINSTANCE.functionArgument_Expression,
                    TYPE_MISMATCH,
                    JsldslPackage::eINSTANCE.functionArgument.name)
            }

            if (declarationTypeInfo.constant && !exprTypeInfo.constant) {
                error("Function argument must be constant at '" + argument.declaration.name + "'.",
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
            EntityDeclaration:                    error = !mark.declaration.targets.exists[t | t.entity]
            ViewDeclaration:                      error = !mark.declaration.targets.exists[t | t.view]
            RowDeclaration:                       error = !mark.declaration.targets.exists[t | t.row]
            ActorDeclaration:                     error = !mark.declaration.targets.exists[t | t.actor]
            TransferDeclaration:                  error = !mark.declaration.targets.exists[t | t.transfer]
            QueryDeclaration:                     error = !mark.declaration.targets.exists[t | t.query]
            DataTypeDeclaration:                  error = !mark.declaration.targets.exists[t | t.type]
            EnumDeclaration:                      error = !mark.declaration.targets.exists[t | t.enumeration]

            EnumLiteral:                          error = !mark.declaration.targets.exists[t | t.enumLiteral]

            EntityStoredFieldDeclaration:         error = !mark.declaration.targets.exists[t | t.entityField]
            EntityCalculatedFieldDeclaration:     error = !mark.declaration.targets.exists[t | t.entityField]
            EntityStoredRelationDeclaration:      error = !mark.declaration.targets.exists[t | t.entityRelation]
            EntityCalculatedRelationDeclaration:  error = !mark.declaration.targets.exists[t | t.entityRelation]

            ViewActionDeclaration:          error = !mark.declaration.targets.exists[t | t.viewAction]
            ViewFieldDeclaration:           error = !mark.declaration.targets.exists[t | t.viewField]
            ViewGroupDeclaration:           error = !mark.declaration.targets.exists[t | t.viewGroup]
            ViewLinkDeclaration:            error = !mark.declaration.targets.exists[t | t.viewLink]
            ViewSubmitDeclaration:          error = !mark.declaration.targets.exists[t | t.viewSubmit]
            ViewTableDeclaration:           error = !mark.declaration.targets.exists[t | t.viewTable]
            ViewTabsDeclaration:            error = !mark.declaration.targets.exists[t | t.viewTabs]

            RowColumnDeclaration:           error = !mark.declaration.targets.exists[t | t.rowColumn]

            ActorMenuDeclaration:           error = !mark.declaration.targets.exists[t | t.actorMenu]
            ActorGroupDeclaration:          error = !mark.declaration.targets.exists[t | t.actorGroup]
            ActorAccessDeclaration:         error = !mark.declaration.targets.exists[t | t.actorAccess]

            TransferActionDeclaration:      error = !mark.declaration.targets.exists[t | t.transferAction]
            TransferConstructorDeclaration: error = !mark.declaration.targets.exists[t | t.transferConstructor]
            TransferFieldDeclaration:       error = !mark.declaration.targets.exists[t | t.transferField]
            TransferInitializerDeclaration: error = !mark.declaration.targets.exists[t | t.transferInitializer]
            TransferRelationDeclaration:    error = !mark.declaration.targets.exists[t | t.transferRelation]
            TransferSubmitDeclaration:      error = !mark.declaration.targets.exists[t | t.transferSubmit]
        }

        if (error) {
            error("Annotation @" + mark.declaration.name +" is not applicable on " + String.join(" ", mark.eContainer.eClass.name.split("(?=\\p{Upper})")).toLowerCase + ".",
                JsldslPackage::eINSTANCE.annotationMark_Declaration,
                INVALID_ANNOTATION)
        }
    }

    @Check
    def checkAssociation(EntityStoredRelationDeclaration relation) {
        // System.out.println("checkAssociationOpposite: " + relation + " opposite: " + relation?.opposite + " type: " + relation?.opposite?.oppositeType)

        // Check the referenced opposite relation type reference back to this relation
        if (relation.opposite?.oppositeType !== null) {
            // System.out.println(" -- " + relation + " --- " + relation.opposite?.oppositeType?.opposite?.oppositeType)
            if (relation !== relation.opposite?.oppositeType?.opposite?.oppositeType) {
                error("The relation's opposite does not match '" + relation.opposite.oppositeType.name + "'.",
                    JsldslPackage::eINSTANCE.entityStoredRelationDeclaration_Opposite,
                    OPPOSITE_TYPE_MISMATH,
                    relation.name)
            }
        }

        // Check this relation without oppoite type is referenced from another relation in the relation target type
        if (relation.opposite === null) {
            val selectableRelatations = (relation.referenceType as EntityDeclaration).getAllRelations(null)
            val relationReferencedBack = selectableRelatations.filter[r | r.opposite !== null && r.opposite.oppositeType === relation].toList
            // System.out.println(" -- " + relation + " --- Referenced back: " + relationReferencedBack.map[r | r.eContainer.fullyQualifiedName + "#" + r.name].join(", "))
            if (!relationReferencedBack.empty) {
                error("The relation does not declare an opposite relation, but the following relations refer to this relation as opposite: " +
                    relationReferencedBack.map[r | "'" + r.eContainer.fullyQualifiedName.toString("::") + "#" + r.name + "'"].join(", "),
                    JsldslPackage::eINSTANCE.entityStoredRelationDeclaration_Opposite,
                    OPPOSITE_TYPE_MISMATH,
                    relation.name)
            }
        }
    }

    @Check
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
            val member = opposite.eContainer as EntityStoredRelationDeclaration
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
            error("Precision must be less than " + PRECISION_MAX_VALUE.add(new BigInteger("1")),
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
    def checkAbstractComposition(EntityStoredFieldDeclaration member) {
	    if (member.referenceType instanceof EntityDeclaration) {
	        val reference = member.referenceType as EntityDeclaration
		    if (reference.isAbstract()) {
		    	error("You cannot use entity named '" + (member.referenceType as EntityDeclaration).name + "' as a field type, because it is abstract.",
		             JsldslPackage::eINSTANCE.entityStoredFieldDeclaration_EntityReferenceType,
		             FIELD_TYPE_IS_ABSRTACT_ENTITY,
		             JsldslPackage::eINSTANCE.entityStoredFieldDeclaration.name)
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
    def checkTransferDefault(TransferDefault transferDefault) {
        if (transferDefault.member === null || transferDefault.rightValue === null) {
            return
        }

        try {
            if (transferDefault.rightValue !== null) {
                if (!this.isStaticExpression(transferDefault.rightValue)) {
                    error(
                        "Default value expression must be static, it cannot contain mapping field.",
                        JsldslPackage::eINSTANCE.transferDefault_RightValue,
                        NON_STATIC_EXPRESSION
                    )
                    return
                }
            }

            if (!TypeInfo.getTargetType(transferDefault.member.reference).isCompatible(TypeInfo.getTargetType(transferDefault.rightValue))) {
                error("Type mismatch. Default value does not match field type.",
                    JsldslPackage::eINSTANCE.transferDefault_RightValue,
                    TYPE_MISMATCH)
            }
        } catch (IllegalArgumentException illegalArgumentException) {
            return
        }
    }

    @Check
    def checkTransferField(TransferFieldDeclaration field) {
        try {
            if (field.maps && !TypeInfo.getTargetType(field).isCompatible(TypeInfo.getTargetType(field.getterExpr))) {
                error("Type mismatch. Mapping expression value does not match field type at '" + field.name + "'.",
                    JsldslPackage::eINSTANCE.transferFieldDeclaration_Maps,
                    TYPE_MISMATCH)
            }

            if (field.reads && !TypeInfo.getTargetType(field).isCompatible(TypeInfo.getTargetType(field.getterExpr))) {
                error("Type mismatch. Read expression value does not match field type at '" + field.name + "'.",
                    JsldslPackage::eINSTANCE.transferFieldDeclaration_Reads,
                    TYPE_MISMATCH)
            }
        } catch (IllegalArgumentException illegalArgumentException) {
            return
        }
    }

    @Check
    def checkTransferRelation(TransferRelationDeclaration relation) {
        try {
            if (relation.maps && !TypeInfo.getTargetType(relation).isCompatible(TypeInfo.getTargetType(relation.getterExpr))) {
                error("Type mismatch. Mapping expression value does not match relation type at '" + relation.name + "'.",
                    JsldslPackage::eINSTANCE.transferRelationDeclaration_Maps,
                    TYPE_MISMATCH)
            }

            if (relation.reads && !TypeInfo.getTargetType(relation).isCompatible(TypeInfo.getTargetType(relation.getterExpr))) {
                error("Type mismatch. Read expression value does not match relation type at '" + relation.name + "'.",
                    JsldslPackage::eINSTANCE.transferRelationDeclaration_Reads,
                    TYPE_MISMATCH)
            }
        } catch (IllegalArgumentException illegalArgumentException) {
            return
        }
    }

    @Check
    def checkEntityStoredFieldMember(EntityStoredFieldDeclaration member) {
        try {
        	var TypeInfo memberType = TypeInfo.getTargetType(member);
        	var TypeInfo exprType = TypeInfo.getTargetType(member.defaultExpr);

            if (member.defaultExpr !== null && !memberType.isCompatible(exprType)) {
 //           if (member.defaultExpr !== null && !TypeInfo.getTargetType(member).isCompatible(TypeInfo.getTargetType(member.defaultExpr))) {
                error("Type mismatch. Default value expression does not match field type at '" + member.name + "'.",
                    JsldslPackage::eINSTANCE.entityStoredFieldDeclaration_DefaultExpr,
                    TYPE_MISMATCH)
            }
        } catch (IllegalArgumentException illegalArgumentException) {
            return
        }
    }

    @Check
    def checkEntityStoredRelationMember(EntityStoredRelationDeclaration member) {
        try {
            if (member.defaultExpr !== null && !TypeInfo.getTargetType(member).isCompatible(TypeInfo.getTargetType(member.defaultExpr))) {
                error("Type mismatch. Default value expression does not match relation type at '" + member.name + "'.",
                    JsldslPackage::eINSTANCE.entityStoredRelationDeclaration_DefaultExpr,
                    TYPE_MISMATCH)
            }
        } catch (IllegalArgumentException illegalArgumentException) {
            return
        }
    }

    @Check
    def checkEntityDerived(EntityCalculatedMemberDeclaration member) {
        try {
            if (member.getterExpr !== null && !TypeInfo.getTargetType(member).isCompatible(TypeInfo.getTargetType(member.getterExpr))) {
                error("Type mismatch. Derived value expression does not match derived field type at '" + member.name + "'.",
                    JsldslPackage::eINSTANCE.entityCalculatedMemberDeclaration_GetterExpr,
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
    def checkTransferAutomap(TransferDeclaration transfer) {
        if (!transfer.automap) {
            return
        }

        if (transfer.map === null  || transfer.map.entity === null) {
            error("Automapping requires mapping to an entity.",
                JsldslPackage::eINSTANCE.transferDeclaration_Automap,
                INVALID_DECLARATION,
                JsldslPackage::eINSTANCE.transferDeclaration.name)

            return
        }

        if (transfer.parentContainer(ModelDeclaration).fromModel.transfers.filter[t | t.automap && transfer.map.entity.isEqual(t.map?.entity)].size > 1){
            error("Duplicate transfer automap: more than one automapped transfer objects for the same entity type.",
                JsldslPackage::eINSTANCE.transferDeclaration_Automap,
                DUPLICATE_AUTOMAP,
                JsldslPackage::eINSTANCE.transferDeclaration.name)
        };

        val Iterator<EntityMemberDeclaration> containmentsIterator = transfer.map.entity.members.filter[m | m instanceof EntityStoredFieldDeclaration && m.referenceType instanceof EntityDeclaration].iterator

        while (containmentsIterator.hasNext) {
            val EntityStoredFieldDeclaration containment = containmentsIterator.next() as EntityStoredFieldDeclaration;

            if (!transfer.parentContainer(ModelDeclaration).fromModel.transfers.exists[t | t.automap && t.map?.entity.isEqual(containment.referenceType)]){
                error("Missing automapping in mapped entity for field '" + containment.name + "'",
                    JsldslPackage::eINSTANCE.transferDeclaration_Automap,
                    INVALID_DECLARATION,
                    JsldslPackage::eINSTANCE.transferDeclaration.name)
            }
        }
    }

    @Check
    def checkTransferFieldReads(TransferFieldDeclaration field) {
        if (!field.reads) {
            return
        }

        if (field.referenceType !== null && field.referenceType instanceof TransferDeclaration) {
            val TransferDeclaration referenceType = field.referenceType as TransferDeclaration

            if (referenceType.map === null || referenceType.map.entity === null) {
                error("Invalid field mapping. Reads keyword cannot be used for unmapped field type.",
                    JsldslPackage::eINSTANCE.transferFieldDeclaration_Reads,
                    INVALID_FIELD_MAPPING,
                    JsldslPackage::eINSTANCE.transferFieldDeclaration.name)

                return;
            }
        }
    }

    @Check
    def checkTransferRelationCreateFlag(TransferRelationDeclaration relation) {
    	if (relation instanceof ActorAccessDeclaration) {
    		return
    	}
    	
        if (relation.create !== null && !relation.maps) {
            error("Create flag is allowed only for mapped relations.",
                JsldslPackage::eINSTANCE.transferRelationDeclaration_Create,
                INVALID_DECLARATION,
                JsldslPackage::eINSTANCE.transferRelationDeclaration.name)

            return;
        }
    }

    @Check
    def checkTransferRelationReads(TransferRelationDeclaration relation) {
        if (!relation.reads) {
            return
        }

        if (relation.referenceType !== null && relation.referenceType instanceof TransferDeclaration) {
            val TransferDeclaration referenceType = relation.referenceType as TransferDeclaration

            if (referenceType.map === null || referenceType.map.entity === null) {
                error("Invalid field mapping. Reads keyword cannot be used for unmapped field type.",
                    JsldslPackage::eINSTANCE.transferRelationDeclaration_Reads,
                    INVALID_FIELD_MAPPING,
                    JsldslPackage::eINSTANCE.transferRelationDeclaration.name)

                return;
            }
        }
    }

    @Check
    def checkTransferFieldMaps(TransferFieldDeclaration field) {
        if (!field.maps) {
            return
        }

        val TransferDeclaration transfer = field.eContainer as TransferDeclaration

        if (transfer.map === null || transfer.map.entity === null) {
            error("Invalid field mapping. Maps keyword cannot be used in unmapped transfer object.",
                JsldslPackage::eINSTANCE.transferFieldDeclaration_Maps,
                INVALID_FIELD_MAPPING,
                JsldslPackage::eINSTANCE.transferFieldDeclaration.name)

            return;
        }

        if (field.referenceType !== null && field.referenceType instanceof TransferDeclaration) {
            val TransferDeclaration referenceType = field.referenceType as TransferDeclaration

            if (referenceType.map === null || referenceType.map.entity === null) {
                error("Invalid field mapping. Maps keyword cannot be used for unmapped field type.",
                    JsldslPackage::eINSTANCE.transferFieldDeclaration_Maps,
                    INVALID_FIELD_MAPPING,
                    JsldslPackage::eINSTANCE.transferFieldDeclaration.name)

                return;
            }
        }

        if (!(field.getterExpr instanceof Navigation)) {
            error("Invalid field mapping. Field mapping must be a navigation.",
                JsldslPackage::eINSTANCE.transferFieldDeclaration_Maps,
                INVALID_FIELD_MAPPING,
                JsldslPackage::eINSTANCE.transferFieldDeclaration.name)

            return;
        }

        val Navigation navigation = field.getterExpr as Navigation;

        if (!(navigation.base instanceof NavigationBaseDeclarationReference)) {
            error("Invalid field mapping. Field mapping must be a navigation.",
                JsldslPackage::eINSTANCE.transferFieldDeclaration_Maps,
                INVALID_FIELD_MAPPING,
                JsldslPackage::eINSTANCE.transferFieldDeclaration.name)

            return;
        }

        val NavigationBaseDeclarationReference navigationBaseDeclarationReference = navigation.base as NavigationBaseDeclarationReference;

        if (!(navigationBaseDeclarationReference.reference instanceof EntityMapDeclaration)) {
            error("Invalid field mapping. Field mapping must be a navigation starting from the mapping field.",
                JsldslPackage::eINSTANCE.transferFieldDeclaration_Maps,
                INVALID_FIELD_MAPPING,
                JsldslPackage::eINSTANCE.transferFieldDeclaration.name)

            return;
        }

        if (navigation.features.size() != 1) {
            error("Invalid field mapping. Field mapping must select a member of the mapped entity.",
                JsldslPackage::eINSTANCE.transferFieldDeclaration_Maps,
                INVALID_FIELD_MAPPING,
                JsldslPackage::eINSTANCE.transferFieldDeclaration.name)

            return;
        }

        if (!(navigation.features.get(0) instanceof MemberReference)) {
            error("Invalid field mapping. Field mapping must select a member of the mapped entity.",
                JsldslPackage::eINSTANCE.transferFieldDeclaration_Maps,
                INVALID_FIELD_MAPPING,
                JsldslPackage::eINSTANCE.transferFieldDeclaration.name)

            return;
        }

        val MemberReference memberReference = navigation.features.get(0) as MemberReference;

        if (!(memberReference.member instanceof EntityStoredFieldDeclaration) &&
        	!(memberReference.member instanceof EntityStoredRelationDeclaration) &&
            !(memberReference.member instanceof EntityRelationOppositeInjected))
        {
            error("Invalid field mapping. Field mapping must select a member of the mapped entity.",
                JsldslPackage::eINSTANCE.transferFieldDeclaration_Maps,
                INVALID_FIELD_MAPPING,
                JsldslPackage::eINSTANCE.transferFieldDeclaration.name)

            return;
        }
    }

    @Check
    def checkTransferRelationMaps(TransferRelationDeclaration relation) {
        if (!relation.maps) {
            return
        }

        val TransferDeclaration transfer = relation.eContainer as TransferDeclaration

        if (transfer.map === null || transfer.map.entity === null) {
            error("Invalid field mapping. Maps keyword cannot be used in unmapped transfer object.",
                JsldslPackage::eINSTANCE.transferRelationDeclaration_Maps,
                INVALID_FIELD_MAPPING,
                JsldslPackage::eINSTANCE.transferRelationDeclaration.name)

            return;
        }

        if (relation.referenceType !== null && relation.referenceType instanceof TransferDeclaration) {
            val TransferDeclaration referenceType = relation.referenceType as TransferDeclaration

            if (referenceType.map === null || referenceType.map.entity === null) {
                error("Invalid field mapping. Maps keyword cannot be used for unmapped field type.",
                    JsldslPackage::eINSTANCE.transferRelationDeclaration_Maps,
                    INVALID_FIELD_MAPPING,
                    JsldslPackage::eINSTANCE.transferRelationDeclaration.name)

                return;
            }
        }

        if (!(relation.getterExpr instanceof Navigation)) {
            error("Invalid field mapping. Field mapping must be a navigation.",
                JsldslPackage::eINSTANCE.transferRelationDeclaration_Maps,
                INVALID_FIELD_MAPPING,
                JsldslPackage::eINSTANCE.transferRelationDeclaration.name)

            return;
        }

        val Navigation navigation = relation.getterExpr as Navigation;

        if (!(navigation.base instanceof NavigationBaseDeclarationReference)) {
            error("Invalid field mapping. Field mapping must be a navigation.",
                JsldslPackage::eINSTANCE.transferRelationDeclaration_Maps,
                INVALID_FIELD_MAPPING,
                JsldslPackage::eINSTANCE.transferRelationDeclaration.name)

            return;
        }

        val NavigationBaseDeclarationReference navigationBaseDeclarationReference = navigation.base as NavigationBaseDeclarationReference;

        if (!(navigationBaseDeclarationReference.reference instanceof EntityMapDeclaration)) {
            error("Invalid field mapping. Field mapping must be a navigation starting from the mapping field.",
                JsldslPackage::eINSTANCE.transferRelationDeclaration_Maps,
                INVALID_FIELD_MAPPING,
                JsldslPackage::eINSTANCE.transferRelationDeclaration.name)

            return;
        }

        if (navigation.features.size() != 1) {
            error("Invalid field mapping. Field mapping must select a member of the mapped entity.",
                JsldslPackage::eINSTANCE.transferRelationDeclaration_Maps,
                INVALID_FIELD_MAPPING,
                JsldslPackage::eINSTANCE.transferRelationDeclaration.name)

            return;
        }

        if (!(navigation.features.get(0) instanceof MemberReference)) {
            error("Invalid field mapping. Field mapping must select a member of the mapped entity.",
                JsldslPackage::eINSTANCE.transferRelationDeclaration_Maps,
                INVALID_FIELD_MAPPING,
                JsldslPackage::eINSTANCE.transferRelationDeclaration.name)

            return;
        }

        val MemberReference memberReference = navigation.features.get(0) as MemberReference;

        if (!(memberReference.member instanceof EntityStoredFieldDeclaration) &&
        	!(memberReference.member instanceof EntityStoredRelationDeclaration) &&
            !(memberReference.member instanceof EntityRelationOppositeInjected))
        {
            error("Invalid field mapping. Field mapping must select a member of the mapped entity.",
                JsldslPackage::eINSTANCE.transferRelationDeclaration_Maps,
                INVALID_FIELD_MAPPING,
                JsldslPackage::eINSTANCE.transferRelationDeclaration.name)

            return;
        }

        if (relation.choices !== null && !TypeInfo.getTargetType(relation).isCompatibleCollection(TypeInfo.getTargetType(relation.choices.expression))) {
            error("Type mismatch. Choices must return compatible collection with field type.",
                JsldslPackage::eINSTANCE.transferRelationDeclaration_Choices,
                INVALID_CHOICES,
                JsldslPackage::eINSTANCE.transferRelationDeclaration.name)
        }
    }

    @Check
    def checkActorIdentity(ActorDeclaration actor) {
        if (actor.identity === null) {
            return
        }

        if (!(actor.identity.expression instanceof Navigation)) {
            error("Invalid actor identity. Identity must be mapped to an identifier of the mapped entity type.",
                JsldslPackage::eINSTANCE.actorDeclaration_Identity,
                INVALID_IDENTITY_MAPPING,
                JsldslPackage::eINSTANCE.actorDeclaration.name)

            return;
        }

        val Navigation navigation = actor.identity.expression as Navigation;

        if (!(navigation.base instanceof NavigationBaseDeclarationReference)) {
            error("Invalid actor identity. Identity must be mapped to an identifier of the mapped entity type.",
                JsldslPackage::eINSTANCE.actorDeclaration_Identity,
                INVALID_IDENTITY_MAPPING,
                JsldslPackage::eINSTANCE.actorDeclaration.name)

            return;
        }

        val NavigationBaseDeclarationReference navigationBaseDeclarationReference = navigation.base as NavigationBaseDeclarationReference;

        if (!(navigationBaseDeclarationReference.reference instanceof EntityMapDeclaration)) {
            error("Invalid actor identity. Identity must be mapped to an identifier of the mapped entity type.",
                JsldslPackage::eINSTANCE.actorDeclaration_Identity,
                INVALID_IDENTITY_MAPPING,
                JsldslPackage::eINSTANCE.actorDeclaration.name)

            return;
        }

        if (navigation.features.size() != 1) {
            error("Invalid actor identity. Identity must be mapped to an identifier of the mapped entity type.",
                JsldslPackage::eINSTANCE.actorDeclaration_Identity,
                INVALID_IDENTITY_MAPPING,
                JsldslPackage::eINSTANCE.actorDeclaration.name)

            return;
        }

        if (!(navigation.features.get(0) instanceof MemberReference)) {
            error("Invalid actor identity. Identity must be mapped to an identifier of the mapped entity type.",
                JsldslPackage::eINSTANCE.actorDeclaration_Identity,
                INVALID_IDENTITY_MAPPING,
                JsldslPackage::eINSTANCE.actorDeclaration.name)

            return;
        }

        val MemberReference memberReference = navigation.features.get(0) as MemberReference;

        if (!(memberReference.member instanceof EntityStoredFieldDeclaration)) {
            error("Invalid actor identity. Identity must be mapped to an identifier of the mapped entity type.",
                JsldslPackage::eINSTANCE.actorDeclaration_Identity,
                INVALID_IDENTITY_MAPPING,
                JsldslPackage::eINSTANCE.actorDeclaration.name)

            return;
        }

        val EntityStoredFieldDeclaration field = memberReference.member as EntityStoredFieldDeclaration;

        if (!field.identifier) {
            error("Invalid actor identity. Identity must be mapped to an identifier of the mapped entity type.",
                JsldslPackage::eINSTANCE.actorDeclaration_Identity,
                INVALID_IDENTITY_MAPPING,
                JsldslPackage::eINSTANCE.actorDeclaration.name)

            return;
        }

        if (!TypeInfo.getTargetType(field).isString) {
            error("Invalid actor identity. Identifier must be a string.",
                JsldslPackage::eINSTANCE.actorDeclaration_Identity,
                INVALID_IDENTITY_MAPPING,
                JsldslPackage::eINSTANCE.actorDeclaration.name)

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

        val TransferDeclaration transfer = field.eContainer as TransferDeclaration;
        val NavigationTarget target = getMappedField(field);

        if (target === null) return;

        if (transfer.members.filter[m | m instanceof TransferFieldDeclaration && target === getMappedField(m as TransferFieldDeclaration)].size > 1) {
            warning("More than one transfer field map the same entity field at '" + field.name + "'.",
                JsldslPackage::eINSTANCE.transferFieldDeclaration_Maps,
                DUPLICATE_FIELD_MAPPING,
                JsldslPackage::eINSTANCE.named.name)
        }
    }
    
    @Check
    def checkTransferConstructor(TransferConstructorDeclaration declaration) {
        val TransferDeclaration transfer = declaration.eContainer as TransferDeclaration;
    	
        if (transfer.members.filter[m | m instanceof TransferConstructorDeclaration].size > 1) {
            error("More than one constructor declared in transfer '" + transfer.name + "'.",
                JsldslPackage::eINSTANCE.transferConstructorDeclaration.getEStructuralFeature("ID"),
                DUPLICATE_CONSTRUCTOR)
        }
    }

    @Check
    def checkTransferInitializer(TransferInitializerDeclaration declaration) {
        val TransferDeclaration transfer = declaration.eContainer as TransferDeclaration;
    	
    	if (transfer.map === null) {
            error("Inititalizer is not allowed in unmapped transfer object.",
                JsldslPackage::eINSTANCE.transferInitializerDeclaration.getEStructuralFeature("ID"),
                INVALID_DECLARATION)
    	}
    	
        if (transfer.members.filter[m | m instanceof TransferInitializerDeclaration].size > 1) {
            error("More than one initializer declared in transfer '" + transfer.name + "'.",
                JsldslPackage::eINSTANCE.transferInitializerDeclaration.getEStructuralFeature("ID"),
                DUPLICATE_INITIALIZER)
        }
    }
	
    @Check
    def checkTransferCreate(TransferCreateDeclaration declaration) {
        val TransferDeclaration transfer = declaration.eContainer as TransferDeclaration;
    	
    	if (transfer.map === null) {
            error("Create is not allowed in unmapped transfer object.",
                JsldslPackage::eINSTANCE.transferInitializerDeclaration.getEStructuralFeature("ID"),
                INVALID_DECLARATION)
    	}

        if (transfer.members.filter[m | m instanceof TransferCreateDeclaration].size > 1) {
            error("More than one create declared in transfer '" + transfer.name + "'.",
                JsldslPackage::eINSTANCE.transferCreateDeclaration.getEStructuralFeature("ID"),
                DUPLICATE_CREATE)
        }

		if (declaration.^default) {
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
    def checkTransferUpdate(TransferUpdateDeclaration declaration) {
        val TransferDeclaration transfer = declaration.eContainer as TransferDeclaration;
    	
    	if (transfer.map === null) {
            error("Update is not allowed in unmapped transfer object.",
                JsldslPackage::eINSTANCE.transferInitializerDeclaration.getEStructuralFeature("ID"),
                INVALID_DECLARATION)
    	}

        if (transfer.members.filter[m | m instanceof TransferUpdateDeclaration].size > 1) {
            error("More than one update declared in transfer '" + transfer.name + "'.",
                JsldslPackage::eINSTANCE.transferUpdateDeclaration.getEStructuralFeature("ID"),
                DUPLICATE_UPDATE)
        }
    }

    @Check
    def checkTransferDelete(TransferDeleteDeclaration declaration) {
        val TransferDeclaration transfer = declaration.eContainer as TransferDeclaration;
    	
    	if (transfer.map === null) {
            error("Delete is not allowed in unmapped transfer object.",
                JsldslPackage::eINSTANCE.transferInitializerDeclaration.getEStructuralFeature("ID"),
                INVALID_DECLARATION)
    	}

        if (transfer.members.filter[m | m instanceof TransferUpdateDeclaration].size > 1) {
            error("More than one update declared in transfer '" + transfer.name + "'.",
                JsldslPackage::eINSTANCE.transferDeleteDeclaration.getEStructuralFeature("ID"),
                DUPLICATE_DELETE)
        }
    }
    
    @Check
    def checkActorMenu(ActorMenuDeclaration menu) {
    	if (menu.parentContainer(ActorDeclaration).system) {
            error("Menu is not allowed in system actor.",
                JsldslPackage::eINSTANCE.actorMenuDeclaration.getEStructuralFeature("ID"),
                INVALID_DECLARATION)
    	}
    	
    	if (!menu.many && menu.rows !== null) {
            error("Rows is not allowed to define for single links.",
                JsldslPackage::eINSTANCE.actorMenuDeclaration_Rows,
                INVALID_DECLARATION)
    	}
    }

    @Check
    def checkActorGroup(ActorGroupDeclaration group) {
    	if (group.parentContainer(ActorDeclaration).system) {
            error("Group is not allowed in system actor.",
                JsldslPackage::eINSTANCE.actorGroupDeclaration.getEStructuralFeature("ID"),
                INVALID_DECLARATION)
    	}
    }
    
    @Check
    def checkOppositeRequired(EntityRelationOppositeReferenced opposite) {
		if (opposite.oppositeType === null) return

    	val EntityStoredRelationDeclaration relation = opposite.eContainer as EntityStoredRelationDeclaration

    	if (relation.required && opposite.oppositeType.required) {
            error("Bidirectional relation is not allowed to be required on both ends.",
                JsldslPackage::eINSTANCE.entityRelationOppositeReferenced.getEStructuralFeature("ID"),
                INVALID_DECLARATION)
    	}
    }
}
