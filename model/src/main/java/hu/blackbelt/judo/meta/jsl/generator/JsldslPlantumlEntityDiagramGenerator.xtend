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

@Singleton
class JsldslPlantumlEntityDiagramGenerator {
	
	@Inject extension JslDslModelExtension
	
	def defaultStyle() '''
		'left to right direction
		
		skinparam nodesep 50
		skinparam ranksep 100
		
		hide empty members
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
	'''

	def enumRepresentation(EnumDeclaration it)
	'''
		class «name» <<  Enumeration >> {
			«FOR literal : literals»
				<b>«literal.name»</b> = «literal.value»
			«ENDFOR»
		}
	'''

	def errorExtendsFragment(ErrorDeclaration it)
	'''«IF extends !== null» extends «extends.name»«ENDIF» {'''

	def errorFieldRepsresentation(ErrorField it)
	'''+«IF isRequired»<b>«ENDIF»«name»«IF isRequired»</b>«ENDIF» : «referenceType.name»'''

	def errorRepresentation(ErrorDeclaration it)
	'''
		class «name» <<  Error >> «errorExtendsFragment» {
			«FOR field : fields»
				«field.errorFieldRepsresentation»
			«ENDFOR»
		}
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
		}
	'''
	
	def entityRelationRepresentation(EntityRelationDeclaration it)
	'''«(eContainer as EntityDeclaration).name» "«name»\n«cardinalityRepresentation»" «
		IF opposite?.oppositeType !== null
			» <--> "«opposite.oppositeType.name»\n[«opposite.oppositeType.cardinalityRepresentation»" «	
		ELSEIF opposite?.oppositeName !== null
			» <--> "«opposite?.oppositeName»\n[0..*]" «
		ELSE
			» --> «
		ENDIF
		»«modelDeclaration.getExternalNameOfEntityDeclaration(referenceType)»'''
	
	def generate(ModelDeclaration it, String style) 
	'''
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
		
		«FOR entity : externalReferencedRelationReferenceTypes»
			class «getExternalNameOfEntityDeclaration(entity)» <«entity.modelDeclaration.name»> << External >> 
		«ENDFOR»

		«FOR relation : getAllRelations(true)»
			«relation.entityRelationRepresentation»
		«ENDFOR»
	}

	@enduml
	'''
}