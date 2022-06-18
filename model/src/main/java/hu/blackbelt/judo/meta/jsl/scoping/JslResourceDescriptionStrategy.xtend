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
								}								
							}]
						}

				]				
			}
			true
		} else {
			// System.out.println("JslResourceDescriptionStrategy.createEObjectDescriptions="+ eObject);			
			false
		}

	}
	
	
	def Map<String, String> indexInfo(EObject object) {
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
			EntityFieldDeclaration: {
		 		val singleTypeField = object.eGet(JsldslPackage::eINSTANCE.entityFieldDeclaration_ReferenceType, false);
		 		userData.put("isMany", object.isIsMany.toString)  
		 		if (singleTypeField instanceof EntityDeclaration) {
		 			userData.put("type", "EntityDeclaration")
		 			userData.put("referenceType", singleTypeField?.fullyQualifiedName?.toString)
		 		} else if (singleTypeField instanceof PrimitiveDeclaration) {
		 			userData.put("type", "PrimitiveDeclaration")
		 			userData.put("referenceType", singleTypeField?.fullyQualifiedName?.toString)		 			
		 		}
 			}	
		 	EntityIdentifierDeclaration: {
		 		val singleTypeField = object.eGet(JsldslPackage::eINSTANCE.entityIdentifierDeclaration_ReferenceType, false) as EObject;
		 		userData.put("isMany", "false")  
	 			userData.put("type", "PrimitiveDeclaration")
	 			userData.put("referenceType", singleTypeField?.fullyQualifiedName?.toString)		 			
 			}		 	
		 	EntityRelationDeclaration: {
		 		userData.put("isMany", object.isIsMany.toString)
		 		val referenceType = object.eGet(JsldslPackage::eINSTANCE.entityRelationDeclaration_ReferenceType, false) as EObject;
		 		userData.put("referenceType", referenceType?.fullyQualifiedName?.toString)
	 			userData.put("type", "EntityDeclaration")	
 			}		 	
		 	EntityDerivedDeclaration: {
		 		userData.put("isMany", object.isIsMany.toString)
		 		val singleTypeField = object.eGet(JsldslPackage::eINSTANCE.entityDerivedDeclaration_ReferenceType, false) as EObject;

		 		if (singleTypeField instanceof EntityDeclaration) {
		 			userData.put("type", "EntityDeclaration")
		 			userData.put("referenceType", singleTypeField?.fullyQualifiedName?.toString)
		 		} else if (singleTypeField instanceof PrimitiveDeclaration) {
		 			userData.put("type", "PrimitiveDeclaration")
		 			userData.put("referenceType", singleTypeField?.fullyQualifiedName?.toString)		 			
		 		}
 			}		 	
		 	EntityQueryDeclaration: {
		 		val singleTypeField = object.eGet(JsldslPackage::eINSTANCE.entityQueryDeclaration_ReferenceType, false) as EObject;
		 		userData.put("isMany", object.isIsMany.toString)
		 		if (singleTypeField instanceof EntityDeclaration) {
		 			userData.put("type", "EntityDeclaration")
		 			userData.put("referenceType", singleTypeField?.fullyQualifiedName?.toString)
		 		} else if (singleTypeField instanceof PrimitiveDeclaration) {
		 			userData.put("type", "PrimitiveDeclaration")
		 			userData.put("referenceType", singleTypeField?.fullyQualifiedName?.toString)		 			
		 		}
 			}
 			QueryDeclaration: {
		 		val referenceType = object.eGet(JsldslPackage::eINSTANCE.queryDeclaration_ReferenceType, false) as EObject;

		 		userData.put("isMany", object.isIsMany.toString)
		 		if (referenceType instanceof EntityDeclaration) {
		 			userData.put("type", "EntityDeclaration")
		 			userData.put("referenceType", referenceType?.fullyQualifiedName?.toString)
		 		} else if (referenceType instanceof PrimitiveDeclaration) {
		 			userData.put("type", "PrimitiveDeclaration")
		 			userData.put("referenceType", referenceType?.fullyQualifiedName?.toString)		 			
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