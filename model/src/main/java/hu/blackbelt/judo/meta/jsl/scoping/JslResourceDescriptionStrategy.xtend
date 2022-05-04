package hu.blackbelt.judo.meta.jsl.scoping

import com.google.inject.Inject
import com.google.inject.Singleton
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionStrategy
import org.eclipse.xtext.util.IAcceptor
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.slf4j.LoggerFactory
import org.slf4j.Logger

@Singleton
class JslResourceDescriptionStrategy extends DefaultResourceDescriptionStrategy {
	Logger log = LoggerFactory.getLogger(JslResourceDescriptionStrategy);

	@Inject extension IQualifiedNameProvider

	override createEObjectDescriptions(EObject eObject, IAcceptor<IEObjectDescription> acceptor) {

		if (eObject instanceof ModelDeclaration) {
			val modelDeclaration = eObject as ModelDeclaration
			
			if (modelDeclaration.fullyQualifiedName !== null) {
				log.debug("JslResourceDescriptionStrategy.createEObjectDescriptions="+ modelDeclaration + " fq: " + modelDeclaration.fullyQualifiedName.toString("::"));

				acceptor.accept(
					EObjectDescription::create(
						modelDeclaration.fullyQualifiedName, modelDeclaration
					)
				)					

				modelDeclaration.declarations.forEach[
					declaration |
	
					val fullyQualifiedName = declaration.fullyQualifiedName
	
					if (fullyQualifiedName !== null)
						log.debug("JslResourceDescriptionStrategy.createEObjectDescriptions="+ declaration + " fq: " + fullyQualifiedName.toString("::"));
						acceptor.accept(
							EObjectDescription::create(
								fullyQualifiedName, declaration
							)
						)
				]				
			}
			true
		} else {
			log.debug("JslResourceDescriptionStrategy.createEObjectDescriptions="+ eObject);			
			false
		}

	}
}