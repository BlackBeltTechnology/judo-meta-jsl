package hu.blackbelt.judo.meta.jsl.scoping

import com.google.inject.Inject
import com.google.inject.Singleton
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionStrategy
import org.eclipse.xtext.util.IAcceptor
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import hu.blackbelt.judo.meta.jsl.QualifiedNameSerializer

@Singleton
class JslResourceDescriptionStrategy extends DefaultResourceDescriptionStrategy {

	override createEObjectDescriptions(EObject eObject, IAcceptor<IEObjectDescription> acceptor) {
		if (eObject instanceof ModelDeclaration) {			
			val fullyQualifiedName = (eObject as ModelDeclaration).name
			if (fullyQualifiedName !== null) {
				acceptor.accept(
							EObjectDescription::create(
								fullyQualifiedName, eObject
							)
						)
			}
			true
		} else
			false
	}
}