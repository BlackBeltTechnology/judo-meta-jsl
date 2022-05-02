package hu.blackbelt.judo.meta.jsl.generator

import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration
import com.google.inject.Singleton
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension

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
	
	def generate(ModelDeclaration it, String style) 
	'''
	@startuml «name»
	'!pragma layout smetana
	«IF style === null || style.blank»«defaultStyle»«ELSE»«style»«ENDIF»
	
	package «name» {
	
	together {
		«FOR type : dataTypeDeclarations»
			class «type.name» <<  «type.primitive» >>
			show «type.name» stereotype
		«ENDFOR»

		«FOR type : enumDeclarations»
			class «type.name» <<  Enumeration >> {
				«FOR literal : type.literals»
					<b>«literal.name»</b> = «literal.value»
				«ENDFOR»
			}
		«ENDFOR»
	}
	
	together {
		«FOR error : errorDeclarations»
			class «error.name» <<  Error >> «
				IF error.extends !== null» extends «
					error.extends.name»«
				ENDIF» {
				«FOR field : error.fields»
					+«
					IF field.isRequired
						»<b>«
					ENDIF
					»«field.name»«
					IF field.isRequired
						»</b>«
					ENDIF
					» : «field.referenceType.name»
				«ENDFOR»
			}
		«ENDFOR»
	}

	together {
		«FOR entity : entityDeclarations»
			class «entity.name»«
			IF entity.isIsAbstract
				» <<  Abstract >> «
			ELSE
				» << Entity >>«
			ENDIF»«
			FOR extend : entity.extends BEFORE ' extends ' SEPARATOR ', '»«extend.name»«ENDFOR» {
				«FOR field : entity.fields»
					«IF field instanceof EntityDeclaration
						»#«
					ELSE
						»+«
					ENDIF»«
					IF field.isRequired
						»<b>«
					ENDIF
					»«field.name
					»«IF field.isRequired
						»</b>«
					ENDIF
					» : «field.referenceType.nameForEntityFieldSingleType»«
					IF field.isIsMany
						»[0..*]«
					ENDIF»
				«ENDFOR»
				«FOR identifier : entity.identifiers»
					+<u>«
					IF identifier.isRequired
						»<b>«
					ENDIF
					»«identifier.name»«
					IF identifier.isRequired
						»</b>«
					ENDIF
					»</u> : «identifier.referenceType.nameForEntityFieldSingleType»
				«ENDFOR»
				«FOR derived : entity.derivedes»
					~«derived.name»«
					FOR param : derived.parameters BEFORE '(' SEPARATOR ', ' AFTER ')'
						»«param.name» : «param.referenceType.name» =«param.^default.sourceCode»«
					ENDFOR
					» : «derived.referenceType.nameForEntityDerivedSingleType
					»«IF derived.isIsMany
						»[0..*]«
					ENDIF
					»
				«ENDFOR»
				«FOR constraint : entity.constraints»
					-«constraint.error.errorDeclarationType.name»«
					FOR param : constraint.error.parameters BEFORE '(' SEPARATOR ', ' AFTER ')'
						»«param.errorFieldType.name» =«param.expession.sourceCode»«
					ENDFOR»
				«ENDFOR»
			}
		«ENDFOR»
		
		«FOR entity : externalReferencedRelationReferenceTypes»
			class «getExternalNameOfEntityDeclaration(entity)» <«entity.modelDeclaration.name»> << External >> 
		«ENDFOR»

		«FOR relation : getAllRelations(true)»
			«(relation.eContainer as EntityDeclaration).name» "«relation.name»\n[«
			IF relation.isIsRequired
				»1«
			ELSE
				»0«						
			ENDIF
			»..«
			IF relation.isIsMany
				»*«
			ELSE
				»1«
			ENDIF
			»]" «
			IF relation.opposite?.oppositeType !== null
				» <--> "«relation.opposite.oppositeType.name»\n[«
					IF relation.opposite.oppositeType.isIsRequired
						»1«
					ELSE
						»0«						
					ENDIF
				»..«
					IF relation.opposite.oppositeType.isIsMany
						»*«
					ELSE
						»1«						
					ENDIF
				»]" «
	
			ELSEIF relation.opposite?.oppositeName !== null
				» <--> "«relation.opposite?.oppositeName»\n[0..*]" «
			ELSE
				» --> «
			ENDIF
			»«getExternalNameOfEntityDeclaration(relation.referenceType)»
		«ENDFOR»
	}

	@enduml
	'''
}