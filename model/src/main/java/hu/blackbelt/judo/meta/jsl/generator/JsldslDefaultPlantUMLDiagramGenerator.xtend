package hu.blackbelt.judo.meta.jsl.generator

import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration
import com.google.inject.Singleton
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.DataTypeDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ErrorDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ErrorField
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityIdentifierDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDerivedDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ConstraintDeclaration
import java.util.Collection
import java.util.HashSet
import java.util.Set
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.resource.impl.ResourceDescriptionsProvider
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import com.google.inject.Provider
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.resource.IResourceDescriptions
import org.eclipse.xtext.resource.IContainer
import org.eclipse.emf.ecore.EObject
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage

@Singleton
class JsldslDefaultPlantUMLDiagramGenerator {
	
	@Inject extension JslDslModelExtension
	
	@Inject
	ResourceDescriptionsProvider rdProvider
	
	@Inject IContainer.Manager containerManager
	@Inject IResourceDescriptions resourceDescriptions
	@Inject Provider<XtextResourceSet> resourceSetProvider
	
	def defaultStyle() '''
		'left to right direction
		
		skinparam nodesep 50
		skinparam ranksep 100
		
		hide circle
		hide stereotype
		
		skinparam padding 2
		skinparam roundCorner 8
		skinparam linetype ortho
		
		skinparam class {
			BackgroundColor #moccasin
			BorderColor #grey
			ArrowColor #black
		
			FontSize 13
			FontStyle bold
		
			BackgroundColor<< Abstract >> white|#cfe3e8
			HeaderBackgroundColor<< Abstract >> #cee2e6/#bed8df
			FontStyle<< Abstract >> italic
		
			BackgroundColor<< Entity >> white|#cfe3e8
			HeaderBackgroundColor<< Entity >> #cee2e6/#bed8df
		
			BackgroundColor<< Enumeration >> white|#d6e6c8
			HeaderBackgroundColor<< Enumeration >> #d6e6c8/#c8e0be
		
			BackgroundColor<< Error >> white|#e69987
			HeaderBackgroundColor<< Error >> #d69080
			FontStyle<< Error >> normal
		
			BackgroundColor<< numeric >> white|#d6e6c8
			HeaderBackgroundColor<< numeric >> #d6e6c8/#c8e0be
		
			BackgroundColor<< string >> white|#d6e6c8
			HeaderBackgroundColor<< string >> #d6e6c8/#c8e0be
		
			BackgroundColor<< date >> white|#d6e6c8
			HeaderBackgroundColor<< date >> #d6e6c8/#c8e0be
		
			BackgroundColor<< timestamp >> white|#d6e6c8
			HeaderBackgroundColor<< timestamp >> #d6e6c8/#c8e0be
		
			BackgroundColor<< time >> white|#d6e6c8
			HeaderBackgroundColor<< time >> #d6e6c8/#c8e0be
		
			BackgroundColor<< binary >> white|#d6e6c8
			HeaderBackgroundColor<< binary >> #d6e6c8/#c8e0be
		
			BackgroundColor<< boolean >> white|#d6e6c8
			HeaderBackgroundColor<< boolean >> #d6e6c8/#c8e0be
		
			BackgroundColor<< External >> white|#efefef
			HeaderBackgroundColor<< External >> #dedede/#d7d7d7
			FontColor<< External >> #7f7f7f
			AttributeFontColor<< External >> #7f7f7f		
		}
		
		skinparam package<<DataTypes>> {
			borderColor Transparent
			backgroundColor Transparent
			fontColor Transparent
			stereotypeFontColor Transparent
		}	
	'''
	
	def cardinalityRepresentation(EntityRelationDeclaration it)
	'''[«IF isIsRequired»1«ELSE»0«ENDIF»..«IF isIsMany»*«ELSE»1«ENDIF»]'''


	def dataTypeRepresentation(DataTypeDeclaration it)
	'''
		class «name» <<  «primitive» >>
		show «name» stereotype
		hide «name» empty members
	'''

	def enumRepresentation(EnumDeclaration it)
	'''
		class «name» <<  Enumeration >> {
			«FOR literal : literals»
				<b>«literal.name»</b> = «literal.value»
			«ENDFOR»
		}
		hide «name» empty members
	'''

	def errorExtendsFragment(ErrorDeclaration it)
	'''«IF extends !== null» extends «extends.name»«ENDIF»'''

	def errorFieldRepsresentation(ErrorField it)
	'''+«IF isRequired»<b>«ENDIF»«name»«IF isRequired»</b>«ENDIF» : «referenceType.name»'''

	def errorRepresentation(ErrorDeclaration it)
	'''
		class «name» <<  Error >> «errorExtendsFragment» {
			«FOR field : fields»
				«field.errorFieldRepsresentation»
			«ENDFOR»
		}
		hide «name» empty members
	'''

	
	def entityExtendsFragment(EntityDeclaration it)
	'''«FOR extend : extends BEFORE 'extends ' SEPARATOR ', '»«extend.name»«ENDFOR»'''

	def entityStereotypeFragment(EntityDeclaration it)
	'''«IF isIsAbstract» <<  Abstract >> «ELSE» << Entity >>«ENDIF»'''

	def entityFieldCardinalityFragment(EntityFieldDeclaration it)
	'''«IF isIsMany»[0..*]«ENDIF»'''

	def entityFieldModifierFragment(EntityFieldDeclaration it)
	'''«IF it instanceof EntityDeclaration»#«ELSE»+«ENDIF»'''

	def entityFieldNameFragment(EntityFieldDeclaration it)
	'''«IF isRequired»<b>«ENDIF»«name»«IF isRequired»</b>«ENDIF»'''

	def entityFieldRepresentation(EntityFieldDeclaration it)
	'''«entityFieldModifierFragment»«entityFieldNameFragment» : «referenceType.nameForEntityFieldSingleType»«entityFieldCardinalityFragment»'''

	def entityIdentifierRepresentation(EntityIdentifierDeclaration it)
	'''+<u>«IF isRequired»<b>«ENDIF»«name»«IF isRequired»</b>«ENDIF»</u> : «referenceType.nameForEntityFieldSingleType»'''


	def entityDerivedParameterFragment(EntityDerivedDeclaration it)
	'''«FOR param : parameters BEFORE '(' SEPARATOR ', ' AFTER ')'»«param.name» : «param.referenceType.name» =«param.^default.sourceCode»«ENDFOR»'''

	def entityDerivedRepresentation(EntityDerivedDeclaration it)
	'''~«name»«entityDerivedParameterFragment» : «referenceType.nameForEntityDerivedSingleType»«IF isIsMany»[0..*]«ENDIF»'''


	def constraintParameterFragment(ConstraintDeclaration it)
	'''«FOR param : error.parameters BEFORE '(' SEPARATOR ', ' AFTER ')'»«param.errorFieldType.name» =«param.expession.sourceCode»«ENDFOR»'''

	def constraintRepresentation(ConstraintDeclaration it)
	'''-«error.errorDeclarationType.name»«constraintParameterFragment»'''


	def entityRepresentation(EntityDeclaration it)
	'''
		class «name»«entityStereotypeFragment» «entityExtendsFragment» {
«/*»
			«FOR field : fields»
				«field.entityFieldRepresentation»
			«ENDFOR»
			«FOR identifier : identifiers»
				«identifier.entityIdentifierRepresentation»
			«ENDFOR»
			«FOR derived : derivedes»
				«derived.entityDerivedRepresentation»
			«ENDFOR»
			«FOR constraint : constraints»
				«constraint.constraintRepresentation»
			«ENDFOR»
«*/»

		}
	'''
	
	def entityRelationRepresentation(EntityRelationDeclaration it, ModelDeclaration base)
	'''« base.getExternalNameOfEntityDeclaration(eContainer as EntityDeclaration)» "«name»\n«cardinalityRepresentation»" «
		IF opposite?.oppositeType !== null
			» <--> "«opposite.oppositeType.name»\n«opposite.oppositeType.cardinalityRepresentation»" «	
		ELSEIF opposite?.oppositeName !== null
			» <--> "«opposite?.oppositeName»\n[0..*]" «
		ELSE
			» --> «
		ENDIF
		»«base.getExternalNameOfEntityDeclaration(referenceType)»'''
	
	def generate(ModelDeclaration it, String style) '''
	@startuml «name»
	'!pragma layout smetana
	«IF style === null || style.blank»«defaultStyle»«ELSE»«style»«ENDIF»
	
	package «name» {
	
	together {
		«FOR type : dataTypeDeclarations»
			«type.dataTypeRepresentation»
		«ENDFOR»

		«FOR enumt : enumDeclarations»
			«enumt.enumRepresentation»
		«ENDFOR»
	}
	
	together {
		«FOR error : errorDeclarations»
			«error.errorRepresentation»
		«ENDFOR»
	}

	together {
		«FOR entity : entityDeclarations»
			«entity.entityRepresentation»
		«ENDFOR»
		
		«/*FOR entity : externalReferencedRelationReferenceTypes»
			class «getExternalNameOfEntityDeclaration(entity)» <entity.modelDeclaration.name> << External >> 
		«ENDFOR»

		«FOR relation : getAllRelations(true)»
			«relation.entityRelationRepresentation(it)»
		«ENDFOR */»

	}

	@enduml
	'''
/*
 		«FOR external : externalReferencedRelationReferenceTypes»
			«FOR relation : external.relations»
			
				«IF relation.opposite?.oppositeName !== null && relation.referenceType.modelDeclaration === it »
					«relation.entityRelationRepresentation(it)»
				«ENDIF»
			«ENDFOR»
		«ENDFOR»
 
 */


/* 
	def EObject resolve(EObject o) {
		var desc = resourceDescriptions.getResourceDescription(o.eResource.URI)
		var visibleContainers = containerManager.getVisibleContainers(desc, resourceDescriptions)

		for (visibleContainer : visibleContainers) {
			var exported = visibleContainer.getExportedObjectsByType(ModelPackage.Literals.BOOFAR)
			var allObjects = newArrayList
	
	    exported.forEach [boofar |  
	      // this is the line I'm interested about -->  
	      allObjects.add(resourceSetProvider.get.getEObject(boofar.EObjectURI, true) as BooFar)
	    ]
	    // ...
	  }		
	}
*/

	def Collection<ModelDeclaration> allModelDeclarations(ModelDeclaration modelDeclr) {
		var desc = resourceDescriptions.getResourceDescription(modelDeclr.eResource.URI)
		var visibleContainers = containerManager.getVisibleContainers(desc, resourceDescriptions)
		val allObjects = newArrayList

		for (visibleContainer : visibleContainers) {
			var exported = visibleContainer.getExportedObjectsByType(JsldslPackage.Literals.MODEL_DECLARATION)
			exported.forEach [m | 
				allObjects.add(resourceSetProvider.get.getEObject(m.EObjectURI, true) as ModelDeclaration)
			]	
		}
		allObjects		
	}
	
	
	def ModelDeclaration getOriginal(ModelDeclaration modelDeclaration) {
		allModelDeclarations(modelDeclaration).findFirst[m | m.name.equals(modelDeclaration.name)]
	}

	def Collection<EntityDeclaration> getExternalReferencedRelationReferenceTypes(ModelDeclaration it) {
		val Set<EntityDeclaration> externalEntity = new HashSet()

		/*

		//for (r : it.eResource.resourceSet.resources) {
		//	EcoreUtil2::resolveAll(r)
		//}

		val modelDeclarationProxies = rdProvider.getResourceDescriptions(it.eResource.resourceSet)
			.allResourceDescriptions.map[it.exportedObjects].flatten.map[it.EObjectOrProxy].filter(ModelDeclaration)

        //val JslDslModelResourceSupport jslModelWrapper = JslDslModelResourceSupport.jslDslModelResourceSupportBuilder()
        //	.resourceSet(it.eResource.resourceSet).build();
        // jslModelWrapper.getStreamOfJsldslModelDeclaration().collect(Collectors.toList)
        
		for (model : modelDeclarationProxies) {
			for (entity : model.entityDeclarations) {
				for (relation : entity.relations) {
					if (relation.referenceType.eResource !== eResource) {
						externalEntity.add(relation.referenceType)
					}
					if (entity.eResource === eResource && relation.opposite?.oppositeName !== null && relation.eResource !== eResource) {
						externalEntity.add(relation.eContainer as EntityDeclaration)
					}
				}
			}			
		}
		externalEntity */

		for (entity : entityDeclarations) {
			for (relation : entity.relations) {
				if (!entityDeclarations.contains(relation.referenceType)) {
					externalEntity.add(relation.referenceType)					
				}
			}
		}
		externalEntity
	}
	
	def String getExternalNameOfEntityDeclaration(ModelDeclaration it, EntityDeclaration entityDeclaration) {

		/*
		if (it.eResource !== entityDeclaration.eResource) {
			val importList = imports.filter[i | i.modelName.importName.equals(entityDeclaration.modelDeclaration.name)]
				.map[i | i.modelName.alias !== null ? i.modelName.alias + "::" + entityDeclaration.name : entityDeclaration.name]
			if (importList.size > 0) { 
				importList.get(0)
			} else {
				entityDeclaration.name
			}
		} else {
			entityDeclaration.name
		} */
		
		if (entityDeclarations.contains(entityDeclaration)) {
			entityDeclaration.name			
		} else {
			"EXT::E" 						
		}
		
	}
	
	
	def void cloneModels(ResourceSet it) {

		
		/*
		 * Get all models from all resources.
		 * urlsToBuild contains all URIs of own model files to use for this run
		 */
		
		
		val resources = resources.filter( r | r.URI.toString.endsWith("jsl")).toList
		
		//urlsToBuild.map( url | getResource( url, true ) )
		
		/*
		 * Call resolveAll to avoid late errors with yet unresolved proxies
		 * (seems to be important before copyAll)
		 */
		for (r : resources) {
			EcoreUtil2::resolveAll(r)
		}
		
		/*
		 * Get models to build from resources
		 */
		val originalModels = resources.map( res | res.contents ).flatten
							  .filter( typeof( ModelDeclaration ) )
							  .toList // needed to avoid ConcurrentModificationException
		
		/*
		 * Clone content to new XtextResource
		 */
		// creating a totally new XtextResourceSet is not working cause all the additional Xtext related resources are missing then
		//		val tempResourceSet = xtextResourceSetProvider.get
		//		val tempResource = xbaseResourceProvider.get

		// create temporary resource
		val tempResource = createResource( URI::createPlatformResourceURI( "tempModel.dsl", false ) ) as XtextResource
		
		/*
		// put all models in new list to prepare and scope copyAll
		val copyObjects = <AbstractElement>newArrayList()
		copyObjects.addAll( originalModels.map( e | e.elements ).flatten )
		
		// do the copy // TODO here we still have links to old models!
		val copiedObjects = EcoreUtil::copyAll( copyObjects )
		
		// create new model, add to temp resource and add copied objects to it
		val model = factory.createModel
		tempResource.contents.add( model )
		model.elements.addAll( copiedObjects )
		
		// trigger associator and inferrer
		tempResource.installDerivedState( false )
		
		// get the new model as a list to do generation
		val models = newArrayList( model )		
		* 
		*/
	}
	
}