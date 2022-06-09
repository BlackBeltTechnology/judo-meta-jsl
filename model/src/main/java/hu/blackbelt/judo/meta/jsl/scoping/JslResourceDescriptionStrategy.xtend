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
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension
import hu.blackbelt.judo.meta.jsl.jsldsl.Named
import java.util.Map
import java.util.HashMap
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityIdentifierDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDerivedDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityQueryDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.PrimitiveDeclaration
import org.eclipse.xtext.linking.lazy.LazyLinkingResource.CyclicLinkingException
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryDeclaration

@Singleton
class JslResourceDescriptionStrategy extends DefaultResourceDescriptionStrategy {

	@Inject extension IQualifiedNameProvider
	@Inject extension JslDslModelExtension

	override createEObjectDescriptions(EObject eObject, IAcceptor<IEObjectDescription> acceptor) {

		if (eObject instanceof ModelDeclaration) {
			val modelDeclaration = eObject as ModelDeclaration
			
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
						
						if (declaration instanceof EntityDeclaration) {
							declaration.allMembers.filter[m | m instanceof Named].map[m | m as Named].forEach[m | {
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
				]				
			}
			true
		} else {
			// System.out.println("JslResourceDescriptionStrategy.createEObjectDescriptions="+ eObject);			
			false
		}

	}
	
	
	def Map<String, String> indexInfo(Object member) {
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
		 
		if (member === null) {
			return userData
		}
		switch member {
			EntityFieldDeclaration: {
		 		val singleTypeField = member.referenceType
		 		userData.put("isMany", member.isIsMany.toString)  
		 		if (singleTypeField instanceof EntityDeclaration) {
		 			userData.put("type", "EntityDeclaration")
		 			userData.put("referenceType", (singleTypeField as EntityDeclaration).fullyQualifiedName.toString)
		 		} else if (singleTypeField instanceof PrimitiveDeclaration) {
		 			userData.put("type", "PrimitiveDeclaration")
		 			userData.put("referenceType", (singleTypeField as PrimitiveDeclaration).fullyQualifiedName.toString)		 			
		 		}
 			}	
		 	EntityIdentifierDeclaration: {
		 		val singleTypeField = member.referenceType
		 		userData.put("isMany", "false")  
		 		if (singleTypeField instanceof EntityDeclaration) {
		 			userData.put("type", "EntityDeclaration")
		 			userData.put("referenceType", (singleTypeField as EntityDeclaration).fullyQualifiedName.toString)
		 		} else if (singleTypeField instanceof PrimitiveDeclaration) {
		 			userData.put("type", "PrimitiveDeclaration")
		 			userData.put("referenceType", (singleTypeField as PrimitiveDeclaration).fullyQualifiedName.toString)		 			
		 		}
 			}		 	
		 	EntityRelationDeclaration: {
		 		userData.put("isMany", member.isIsMany.toString)
		 		var EntityDeclaration referenceType = null
		 		try {
		 			referenceType = member.referenceType
			 		userData.put("referenceType", referenceType?.fullyQualifiedName?.toString)
		 		} catch (CyclicLinkingException e) {
		 		}		 		
	 			userData.put("type", "EntityDeclaration")	
 			}		 	
		 	EntityDerivedDeclaration: {
		 		userData.put("isMany", member.isIsMany.toString)
		 		val singleTypeField = member.referenceType
		 		if (singleTypeField instanceof EntityDeclaration) {
		 			userData.put("type", "EntityDeclaration")
		 			userData.put("referenceType", (singleTypeField as EntityDeclaration).fullyQualifiedName.toString)
		 		} else if (singleTypeField instanceof PrimitiveDeclaration) {
		 			userData.put("type", "PrimitiveDeclaration")
		 			userData.put("referenceType", (singleTypeField as PrimitiveDeclaration).fullyQualifiedName.toString)		 			
		 		}
 			}		 	
		 	EntityQueryDeclaration: {
		 		val singleTypeField = member.referenceType
		 		userData.put("isMany", member.isIsMany.toString)
		 		if (singleTypeField instanceof EntityDeclaration) {
		 			userData.put("type", "EntityDeclaration")
		 			userData.put("referenceType", (singleTypeField as EntityDeclaration).fullyQualifiedName.toString)
		 		} else if (singleTypeField instanceof PrimitiveDeclaration) {
		 			userData.put("type", "PrimitiveDeclaration")
		 			userData.put("referenceType", (singleTypeField as PrimitiveDeclaration).fullyQualifiedName.toString)		 			
		 		}
 			}
 			QueryDeclaration: {
		 		val referenceType = member.referenceType
		 		userData.put("isMany", member.isIsMany.toString)
		 		if (referenceType instanceof EntityDeclaration) {
		 			userData.put("type", "EntityDeclaration")
		 			userData.put("referenceType", (referenceType as EntityDeclaration).fullyQualifiedName.toString)
		 		} else if (referenceType instanceof PrimitiveDeclaration) {
		 			userData.put("type", "PrimitiveDeclaration")
		 			userData.put("referenceType", (referenceType as PrimitiveDeclaration).fullyQualifiedName.toString)		 			
		 		}	
 			}
		 }
		 return userData
	}
}