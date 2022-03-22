package hu.blackbelt.judo.meta.jsl.validation

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.validation.Check
import static extension hu.blackbelt.judo.meta.jsl.util.JslModelExtension.*
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelImport

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class JslDslValidator extends AbstractJslDslValidator {

	protected static val ISSUE_CODE_PREFIX = "hu.blackbelt.judo.meta.jsl.jsldsl.";
	public static val HIERARCHY_CYCLE = ISSUE_CODE_PREFIX + "HierarchyCycle";

	@Check
	def checkImportCycle(ModelImport modelImport) {
		if (modelImport.importedModel.modelImportHierarchy.contains(modelImport.importedModel)) {
			error("cycle in hierarchy of model '" + modelImport.importedModel.name + "'",
				JsldslPackage::eINSTANCE.modelImport_ImportedModel,
				HIERARCHY_CYCLE,
				modelImport.importedModel.name)
		}
	}


	def currentElem(EObject grammarElement) {
		return grammarElement.eResource.resourceSet.getResource(URI.createURI("self_synthetic"), true).contents.get(0)
	}

}
