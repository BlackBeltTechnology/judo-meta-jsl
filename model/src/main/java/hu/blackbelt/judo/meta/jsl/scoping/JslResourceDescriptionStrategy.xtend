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
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityFieldDeclaration
import org.eclipse.xtext.naming.IQualifiedNameProvider
import hu.blackbelt.judo.meta.jsl.jsldsl.Declaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TypeDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.PrimitiveDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ClassDeclaration
import org.eclipse.xtext.naming.IQualifiedNameConverter

@Singleton
class JslResourceDescriptionStrategy extends DefaultResourceDescriptionStrategy {

	@Inject extension IQualifiedNameProvider

	override createEObjectDescriptions(EObject eObject, IAcceptor<IEObjectDescription> acceptor) {

		if (eObject instanceof ModelDeclaration) {
			val modelDeclaration = eObject as ModelDeclaration
			
			//System.out.println("JslResourceDescriptionStrategy.createEObjectDescriptions="+ modelDeclaration + " fq: " + modelDeclaration.fullyQualifiedName.toString("::"));
			acceptor.accept(
				EObjectDescription::create(
					modelDeclaration.fullyQualifiedName, modelDeclaration
				)
			)					
		
			modelDeclaration.declarations.forEach[
				declaration |

				val fullyQualifiedName = declaration.fullyQualifiedName

				if (fullyQualifiedName !== null)
					// System.out.println("JslResourceDescriptionStrategy.createEObjectDescriptions="+ declaration + " fq: " + fullyQualifiedName.toString("::"));
					acceptor.accept(
						EObjectDescription::create(
							fullyQualifiedName, declaration
						)
					)
			]
			true
		} else
			false

	}
}