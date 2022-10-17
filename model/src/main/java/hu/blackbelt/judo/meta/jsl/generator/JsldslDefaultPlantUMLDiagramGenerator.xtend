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
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityQueryDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeInjected
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeReferenced
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOpposite

@Singleton
class JsldslDefaultPlantUMLDiagramGenerator {
	
	@Inject extension JslDslModelExtension
	
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
		class «name?:"none"» <<  «primitive» >>
		show «name?:"none"» stereotype
		hide «name?:"none"» empty members
	'''

	def enumRepresentation(EnumDeclaration it)
	'''
		class «name?:"none"» <<  Enumeration >> {
			«FOR literal : literals»
				<b>«literal.name»</b> = «literal.value»
			«ENDFOR»
		}
		hide «name» empty members
	'''

	def errorExtendsFragment(ErrorDeclaration it)
	'''«IF extends !== null» extends «extends.name»«ENDIF»'''

	def errorFieldRepsresentation(ErrorField it)
	'''+«name» : «referenceType.name»'''

	def errorRepresentation(ErrorDeclaration it)
	'''
		class «name?:"none"» <<  Error >> «errorExtendsFragment» {
			«FOR field : fields»
				«field.errorFieldRepsresentation»
			«ENDFOR»
		}
		hide «name» empty members
	'''

	
	def entityExtendsFragment(EntityDeclaration it)
	'''«FOR extend : extends BEFORE 'extends ' SEPARATOR ', '»«extend.name»«ENDFOR»'''

	def entityStereotypeFragment(EntityDeclaration it)
	'''«IF isIsAbstract» << Abstract >> «ELSE» << Entity >>«ENDIF»'''

	def entityFieldCardinalityFragment(EntityFieldDeclaration it)
	'''«IF isIsMany»[0..*]«ENDIF»'''

	def entityFieldModifierFragment(EntityFieldDeclaration it)
	'''«IF it instanceof EntityDeclaration»#«ELSE»+«ENDIF»'''

	def entityFieldNameFragment(EntityFieldDeclaration it)
	'''«IF isRequired»<b>«ENDIF»«name»«IF isRequired»</b>«ENDIF»'''

	def entityFieldRepresentation(EntityFieldDeclaration it)
	'''«entityFieldModifierFragment»«entityFieldNameFragment» : «referenceType.name»«entityFieldCardinalityFragment»'''

	def entityIdentifierRepresentation(EntityIdentifierDeclaration it)
	'''+<u>«IF isRequired»<b>«ENDIF»«name»«IF isRequired»</b>«ENDIF»</u> : «referenceType.name»'''


	def entityQueryParameterFragment(EntityQueryDeclaration it)
	'''«FOR param : parameters BEFORE '(' SEPARATOR ', ' AFTER ')'»«param.name» : «param.referenceType.name» =«param.^default.sourceCode»«ENDFOR»'''

	def entityDerivedRepresentation(EntityDerivedDeclaration it)
	'''~<i>«name»</i> : «referenceType.name»«IF isIsMany»[0..*]«ENDIF»'''

	def entityQueryRepresentation(EntityQueryDeclaration it)
	'''~«name»«entityQueryParameterFragment» : «referenceType.name»[0..*]'''


	def constraintParameterFragment(ConstraintDeclaration it)
	'''«FOR param : error.parameters BEFORE '(' SEPARATOR ', ' AFTER ')'»«param.errorFieldType.name» =«param.expession.sourceCode»«ENDFOR»'''

	def constraintRepresentation(ConstraintDeclaration it)
	'''-«error.errorDeclarationType.name»«constraintParameterFragment»'''


	def entityRepresentation(EntityDeclaration it)
	'''
		class «name?:"none"»«entityStereotypeFragment» {
			«FOR field : fields»
				«field.entityFieldRepresentation»
			«ENDFOR»
			«FOR identifier : identifiers»
				«identifier.entityIdentifierRepresentation»
			«ENDFOR»
			«FOR derived : derivedes»
				«derived.entityDerivedRepresentation»
			«ENDFOR»
			«FOR query : queries»
				«query.entityQueryRepresentation»
			«ENDFOR»
			«FOR constraint : constraints»
				«constraint.constraintRepresentation»
			«ENDFOR»
		}
	'''

	def entityExtends(EntityDeclaration it)
	'''
		«FOR supertype : it.extends»
			«name» --|> «supertype.name»
		«ENDFOR»
	'''

	def entityRelationOppositeInjectedRepresentation(EntityRelationOppositeInjected it)
	'''"«name»\n«IF many»[0..*] «ELSE»[0..1]«ENDIF»" -- '''

	def entityRelationOppositeReferencedRepresentation(EntityRelationOppositeReferenced it)
	'''"«oppositeType?.name»\n«oppositeType?.cardinalityRepresentation»" -- '''

	def entityRelationOppositeRepresentation(EntityRelationOpposite it) {
		switch it {
			EntityRelationOppositeInjected : it.entityRelationOppositeInjectedRepresentation
			EntityRelationOppositeReferenced : it.entityRelationOppositeReferencedRepresentation
		}		
	}
	
	def entityRelationRepresentation(EntityRelationDeclaration it, ModelDeclaration base)
	'''« base.getExternalNameOfEntityDeclaration(eContainer as EntityDeclaration)» «
		IF opposite !== null» «opposite.entityRelationOppositeRepresentation» «ELSE» --> «ENDIF
		» "«name»\n«cardinalityRepresentation»" «base.getExternalNameOfEntityDeclaration(referenceType)»'''
	
	def generate(ModelDeclaration it, String style) '''
	@startuml «name?:"none"»
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
		
		«FOR entity : externalReferencedRelationReferenceTypes»
			class «getExternalNameOfEntityDeclaration(entity)» <«entity.parentContainer(ModelDeclaration)?.name»> << External >> 
		«ENDFOR»

		«FOR entity : entityDeclarations»
			«entity.entityExtends»
		«ENDFOR»

		«FOR relation : getAllRelations(true)»
			«relation.entityRelationRepresentation(it)»
		«ENDFOR»

		«FOR external : externalReferencedRelationReferenceTypes»
			«FOR relation : external.relations»
				«IF relation.opposite instanceof EntityRelationOppositeInjected && relation.referenceType?.parentContainer(ModelDeclaration)?.name === it.name»
					«relation.entityRelationRepresentation(it)»
				«ENDIF»
			«ENDFOR»
		«ENDFOR»

	}

	@enduml
	'''


	def Collection<EntityDeclaration> getExternalReferencedRelationReferenceTypes(ModelDeclaration it) {
		val Set<EntityDeclaration> externalEntities = new HashSet()
		for (entity : it.entityDeclarations) {
			for (relation : entity.relations) {
				if (relation.referenceType?.parentContainer(ModelDeclaration)?.name !== it.name) {
					externalEntities.add(relation.referenceType)
				}
			}
			for (superType : entity.extends) {
				if (superType.parentContainer(ModelDeclaration)?.name !== it.name) {
					externalEntities.add(superType)
				}
			}
		}
		externalEntities
	}
	
	def String getExternalNameOfEntityDeclaration(ModelDeclaration it, EntityDeclaration entityDeclaration) {
		if (it.name !== entityDeclaration?.parentContainer(ModelDeclaration)?.name) {
			val importList = imports.filter[i | i.modelName.importName.equals(entityDeclaration.parentContainer(ModelDeclaration).name)]
				.map[i | i.modelName.alias !== null ? i.modelName.alias + "::" + entityDeclaration.name : entityDeclaration.name]
			if (importList !== null && importList.size > 0) { 
				importList.get(0)
			} else {
				entityDeclaration.name
			}
		} else {
			entityDeclaration.name
		}
	}

}