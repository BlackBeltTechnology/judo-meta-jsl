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
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration
import java.util.Map
import java.util.HashMap
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityIdentifierDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDerivedDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityQueryDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.PrimitiveDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeInjected

@Singleton
class JslResourceDescriptionStrategy extends DefaultResourceDescriptionStrategy {

	@Inject extension IQualifiedNameProvider
	@Inject JslDslInjectedObjectsProvider injectedObjectsProvider;

	override createEObjectDescriptions(EObject eObject, IAcceptor<IEObjectDescription> acceptor) {

		if (eObject instanceof ModelDeclaration) {
			val modelDeclaration = eObject
			
			if (modelDeclaration.fullyQualifiedName !== null) {
				// System.out.println("JslResourceDescriptionStrategy.createEObjectDescriptions="+ modelDeclaration + " fq: " + modelDeclaration.fullyQualifiedName.toString("::"));

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
						// System.out.println("Indexing: " + fullyQualifiedName)

						acceptor.accept(
							EObjectDescription::create(
								fullyQualifiedName, declaration
							)
						)

						if (declaration instanceof QueryDeclaration) {
							val fq = declaration.fullyQualifiedName
							if (fq !== null) {
								// System.out.println("Indexing: " + fq)
								acceptor.accept(
									EObjectDescription::create(
										fq, declaration, declaration.indexInfo
									)
								)								
							}								
						}
						
						if (declaration instanceof EntityDeclaration) {
							//val decl = EcoreUtil.resolve(declaration, modelDeclaration) as EntityDeclaration;
							declaration.members.forEach[m | {
								val fq = m.fullyQualifiedName
								if (fq !== null) {
									// System.out.println("Indexing: " + fq)
									acceptor.accept(
										EObjectDescription::create(
											fq, m, m.indexInfo
										)
									)
									
									if (m instanceof EntityRelationDeclaration) {
										if (m.opposite instanceof EntityRelationOppositeInjected) {
											val fqOpposite = m.opposite.fullyQualifiedName
											acceptor.accept(
												EObjectDescription::create(
													fqOpposite, m.opposite, m.opposite.indexInfo(m)
												)
											)											
										}
									}								
								}								
							}]
						}

				]				
			}
			true
		} else {
			// System.out.println("JslResourceDescriptionStrategy.createEObjectDescriptions="+ eObject);			
			false
			//return super.createEObjectDescriptions(eObject, acceptor);
    	}

	}

	def Map<String, String> indexInfo(EObject object) {
		object.indexInfo(null)
	}
	

	def Map<String, String> indexInfo(EObject object, EObject object2) {
		/*
		 EntityMemberDeclaration
	     : NL+ (EntityFieldDeclaration
	     | EntityIdentifierDeclaration
	     | EntityRelationDeclaration
	     | EntityDerivedDeclaration
	     | EntityQueryDeclaration
	     | ConstraintDeclaration)
	     ;		 
		 */
 		
		val Map<String, String> userData = new HashMap<String, String>
		 	
		switch object {
		 	EntityRelationDeclaration: {
	 			if (object.opposite !== null && object.opposite instanceof EntityRelationOppositeInjected) {
	 				userData.put("oppositeName", (object.opposite as EntityRelationOppositeInjected).name)
	 			}
 			}		 	
		 }
		return userData
	}
	
	
	override isResolvedAndExternal(EObject from, EObject to) {
	 	if (injectedObjectsProvider.isProvided(to)) {
	 		true
 		} else {
 			super.isResolvedAndExternal(from, to)
		}
     }
}