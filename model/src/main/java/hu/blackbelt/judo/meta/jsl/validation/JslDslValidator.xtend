package hu.blackbelt.judo.meta.jsl.validation

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.validation.Check
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelImport
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.naming.IQualifiedNameConverter
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension
import org.eclipse.xtext.validation.CheckType
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import hu.blackbelt.judo.meta.jsl.scoping.JslDslIndex
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration
import java.util.LinkedList
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityIdentifierDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDerivedDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOpposite

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class JslDslValidator extends AbstractJslDslValidator {

	protected static val ISSUE_CODE_PREFIX = "hu.blackbelt.judo.meta.jsl.jsldsl."
	public static val HIERARCHY_CYCLE = ISSUE_CODE_PREFIX + "HierarchyCycle"
	public static val IMPORTED_MODEL_NOT_FOUND = ISSUE_CODE_PREFIX + "ImportedModelNotFound"
	public static val DUPLICATE_MODEL = ISSUE_CODE_PREFIX + "DuplicateModel"
	public static val OPPOSITE_TYPE_MISMATH = ISSUE_CODE_PREFIX + "OppositeTypeMismatch"
	public static val DUPLICATE_MEMBER_NAME = ISSUE_CODE_PREFIX + "DuplicateMemberName"
	public static val INHERITENCE_CYCLE = ISSUE_CODE_PREFIX + "InheritenceCycle"
	
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
	
    /*
	@Check
	def checkImportCycle(ModelImport modelImport) {
		if (modelImport.importedNamespace !== null) {
			if (modelImport.modelDeclaration.modelImportHierarchy(modelImport.importedNamespace.toQualifiedName).contains(modelImport.importedNamespace.toQualifiedName)) {
				error("cycle in hierarchy of model '" + modelImport.importedNamespace + "'",
					JsldslPackage::eINSTANCE.modelImport_ImportedNamespace,
					HIERARCHY_CYCLE,
					modelImport.importedNamespace)
			}			
		}
	}
    */
    
	@Check
	def checkSelfImport(ModelImport modelImport) {
		//System.out.println("checkSelfImport: " + modelImport.importedNamespace + " " + modelImport.eContainer().fullyQualifiedName.toString("::"))
		
		if (modelImport.modelName === null) {
			return
		}
		if (modelImport.modelName.importName.toQualifiedName.equals(modelImport.eContainer().fullyQualifiedName)) {
			//System.out.println("==== ERROR: " + modelImport.importedNamespace)
			error("Cycle in hierarchy of model '" + modelImport.modelName.importName + "'",
				JsldslPackage::eINSTANCE.modelImport_ModelName,
				HIERARCHY_CYCLE,
				modelImport.modelName.importName)
		}
	}

	@Check
	def checkImportSanity(ModelImport modelImport) {
		val modelName = modelImport.modelName;
		if (modelName !== null) {
			val modelQualifiedName = modelName.importName.toQualifiedName
			val found = modelImport.modelDeclaration.getVisibleClassesDescriptions.map[
				desc |
				if (desc.qualifiedName == modelQualifiedName 
					&& desc.EObjectOrProxy != modelImport.modelDeclaration 
					&& desc.EObjectURI.trimFragment != modelImport.modelDeclaration.eResource.URI) {
						true
				} else {				
					false
				}
			].exists[l | l]
			if (!found) {
				error("Imported model '" + modelImport.modelName.importName + "' not found",
					JsldslPackage::eINSTANCE.modelImport_ModelName,
					IMPORTED_MODEL_NOT_FOUND,
					modelImport.modelName.importName)				
			}
		} else {			
				error("Imported model is not defined",
					JsldslPackage::eINSTANCE.modelImport_ModelName,
					IMPORTED_MODEL_NOT_FOUND,
					modelImport.modelName.importName)				
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
			val selectableRelatations = relation.referenceType.getAllRelations(null, new LinkedList)
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
				JsldslPackage::eINSTANCE.entityDeclaration_Name,
				INHERITENCE_CYCLE,
				entity.name)			
		}
	}

	@Check
	def checkForDuplicateNameForEntityFieldDeclaration(EntityFieldDeclaration member) {
		if ((member.eContainer as EntityDeclaration).getMemberNames(member).contains(member.name)) {
			error("Duplicate name: '" + member.name + "'",
				JsldslPackage::eINSTANCE.entityFieldDeclaration_Name,
				DUPLICATE_MEMBER_NAME,
				member.name)			
		}
	}


	@Check
	def checkForDuplicateNameForEntityIdentifierDeclaration(EntityIdentifierDeclaration member) {
		if ((member.eContainer as EntityDeclaration).getMemberNames(member).contains(member.name)) {
			error("Duplicate name: '" + member.name + "'",
				JsldslPackage::eINSTANCE.entityIdentifierDeclaration_Name,
				DUPLICATE_MEMBER_NAME,
				member.name)			
		}
	}


	@Check
	def checkForDuplicateNameForEntityRelationDeclaration(EntityRelationDeclaration member) {
		if ((member.eContainer as EntityDeclaration).getMemberNames(member).contains(member.name)) {
			error("Duplicate name: '" + member.name + "'",
				JsldslPackage::eINSTANCE.entityRelationDeclaration_Name,
				DUPLICATE_MEMBER_NAME,
				member.name)			
		}
	}
		
	@Check
	def checkForDuplicateNameForEntityDerivedDeclaration(EntityDerivedDeclaration member) {
		if ((member.eContainer as EntityDeclaration).getMemberNames(member).contains(member.name)) {
			error("Duplicate name: '" + member.name + "'",
				JsldslPackage::eINSTANCE.entityDerivedDeclaration_Name,
				DUPLICATE_MEMBER_NAME,
				member.name)			
		}
	}

	@Check
	def checkForDuplicateNameForEntityDerivedDeclaration(EntityRelationOpposite opposite) {
		if (opposite.oppositeName !== null && !opposite.oppositeName.blank) {
			val relation = opposite.eContainer as EntityRelationDeclaration
			if (relation.referenceType.getMemberNames.contains(opposite.oppositeName)) {
				error("Duplicate name: '" + opposite.oppositeName + "'",
					JsldslPackage::eINSTANCE.entityRelationOpposite_OppositeName,
					DUPLICATE_MEMBER_NAME,
					opposite.oppositeName)			
			}			
		}
	}


	def currentElem(EObject grammarElement) {
		return grammarElement.eResource.resourceSet.getResource(URI.createURI("self_synthetic"), true).contents.get(0)
	}

}
