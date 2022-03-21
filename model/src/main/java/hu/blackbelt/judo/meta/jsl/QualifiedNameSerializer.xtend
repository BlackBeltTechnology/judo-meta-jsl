package hu.blackbelt.judo.meta.jsl;

import org.eclipse.emf.ecore.EObject
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.QualifiedName

class QualifiedNameSerializer {

	def fullyQualifiedName(QualifiedName qualifiedName) {
		var fullName = "";
		for (part : qualifiedName.namespaceElements) {
			if (fullName !== "") {
				fullName += "::"
			}
			fullName += part;
		}
		if (fullName != "") {
			fullName += "::"
		}
		fullName += qualifiedName.name;
		fullName
	}
	
	def fullyQualifiedName(ModelDeclaration modelDeclaration) {
		modelDeclaration.name
	}			
}


