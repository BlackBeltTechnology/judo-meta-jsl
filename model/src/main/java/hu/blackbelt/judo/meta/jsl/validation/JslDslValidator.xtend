package hu.blackbelt.judo.meta.jsl.validation

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.validation.Check
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelImport
//import static extension hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension.*
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.naming.IQualifiedNameConverter
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension
import org.eclipse.xtext.validation.CheckType
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import hu.blackbelt.judo.meta.jsl.scoping.JslDslIndex

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
					"The model " + modelDeclaration.name + " is already defined",
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
		
		if (modelImport.importedNamespace === null) {
			return
		}
		if (modelImport.importedNamespace.toQualifiedName.equals(modelImport.eContainer().fullyQualifiedName)) {
			//System.out.println("==== ERROR: " + modelImport.importedNamespace)
			error("Cycle in hierarchy of model '" + modelImport.importedNamespace + "'",
				JsldslPackage::eINSTANCE.modelImport_ImportedNamespace,
				HIERARCHY_CYCLE,
				modelImport.importedNamespace)
		}
	}

	@Check
	def checkImportSanity(ModelImport modelImport) {
		val modelName = modelImport.importedNamespace;
		if (modelName !== null) {
			val modelQualifiedName = modelName.toQualifiedName
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
				error("Imported model '" + modelImport.importedNamespace + "' not found",
					JsldslPackage::eINSTANCE.modelImport_ImportedNamespace,
					IMPORTED_MODEL_NOT_FOUND,
					modelImport.importedNamespace)				
			}
		} else {			
				error("Imported model is not defined",
					JsldslPackage::eINSTANCE.modelImport_ImportedNamespace,
					IMPORTED_MODEL_NOT_FOUND,
					modelImport.importedNamespace)				
		}
    }

	def currentElem(EObject grammarElement) {
		return grammarElement.eResource.resourceSet.getResource(URI.createURI("self_synthetic"), true).contents.get(0)
	}

}
