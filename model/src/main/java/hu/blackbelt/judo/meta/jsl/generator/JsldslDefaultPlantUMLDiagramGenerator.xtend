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
import java.util.Collection
import java.util.HashSet
import java.util.Set
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityQueryDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeInjected
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeReferenced
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOpposite
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.AnnotationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ServiceDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ServiceDataDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ServiceFunctionDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ServiceReturnDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ServiceReturnAlternateDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorDeclaration

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

            BackgroundColor<< AutoMapped >> white|#f9f4cb
            HeaderBackgroundColor<< AutoMapped >> #f4f0c7/#f7f0b9
            FontStyle<< AutoMapped >> italic

            BackgroundColor<< Transfer >> white|#f9f4cb
            HeaderBackgroundColor<< Transfer >> #f4f0c7/#f7f0b9

            BackgroundColor<< MappedService >> white|#d4e5c9
            HeaderBackgroundColor<< MappedService >> #d1e0c5/#c9dcbb
            FontStyle<< MappedService >> italic

            BackgroundColor<< Service >> white|#d4e5c9
            HeaderBackgroundColor<< Service >> #d1e0c5/#c9dcbb

            BackgroundColor<< MappedActor >> white|#dddddd
            HeaderBackgroundColor<< MappedActor >> #dddddd/#dddddd
            FontStyle<< MappedActor >> italic

            BackgroundColor<< Actor >> white|#dddddd
            HeaderBackgroundColor<< Actor >> #dddddd/#dddddd

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

	def annotationRepresentation(AnnotationDeclaration it)
    '''
        annotation @«name?:"none"»
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
    '''«FOR param : parameters BEFORE '(' SEPARATOR ', ' AFTER ')'»«param.name» : «param.referenceType.name» =«param.^default»«ENDFOR»'''

    def entityDerivedRepresentation(EntityDerivedDeclaration it)
    '''~<i>«name»</i> : «referenceType.name»«IF isIsMany»[0..*]«ENDIF»'''

    def entityQueryRepresentation(EntityQueryDeclaration it)
    '''~«name»«entityQueryParameterFragment» : «referenceType.name»[0..*]'''


//    def constraintParameterFragment(ConstraintDeclaration it)
//    '''«FOR param : error.parameters BEFORE '(' SEPARATOR ', ' AFTER ')'»«param.errorFieldType.name» =«param.expession.sourceCode»«ENDFOR»'''
//
//    def constraintRepresentation(ConstraintDeclaration it)
//    '''-«error.errorDeclarationType.name»«constraintParameterFragment»'''


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
«««            «FOR constraint : constraints»
«««                «constraint.constraintRepresentation»
«««            «ENDFOR»
        }
    '''
    
    def transferStereotypeFragment(TransferDeclaration it)
    '''«IF automap» << AutoMapped >> «ELSE» << Transfer >>«ENDIF»'''
    
    def transferFieldNameFragment(TransferFieldDeclaration it)
    '''«IF isRequired»<b>«ENDIF»«name»«IF isRequired»</b>«ENDIF»'''
    
    def transferFieldCardinalityFragment(TransferFieldDeclaration it)
    '''«IF isIsMany»[0..*]«ENDIF»'''
    
    def transferFieldRepresentation(TransferFieldDeclaration it)
    '''«transferFieldNameFragment» : «referenceType.name»«transferFieldCardinalityFragment»«IF it.maps !== null» <b>maps</b> «it.maps.sourceCode» «ENDIF»«IF it.reads !== null» <b>reads</b> «it.reads.sourceCode» «ENDIF»
	'''

    def transferRepresentation(TransferDeclaration it)
    '''
        class «name?:"none"»«transferStereotypeFragment» {
            «FOR field : it.fields»
                «field.transferFieldRepresentation»
            «ENDFOR»
        }
    '''
    
    def serviceStereotypeFragment(ServiceDeclaration it)
    '''«IF map !== null» << MappedService >> «ELSE» << Service >>«ENDIF»'''
    
    def dataFunctionNameFragment(ServiceDataDeclaration it)
    '''«name»'''
    
    def dataFunctionCardinalityFragment(ServiceDataDeclaration it)
    '''«IF isIsMany»[0..*]«ENDIF»'''
    
    def dataFunctionRepresentation(ServiceDataDeclaration it)
    '''{method}«dataFunctionNameFragment» : «it.^return.referenceType.name»«dataFunctionCardinalityFragment» <b>=></b> «it.expression.sourceCode»
	'''
	
	def functionNameFragment(ServiceFunctionDeclaration it)
    '''«name»'''
    
    def functionUnionReturnConcatenated(ServiceReturnAlternateDeclaration it)
    '''«it.referenceTypes.map[r | r.referenceType.name].join(' | ')»'''
    
    def functionRepresentation(ServiceFunctionDeclaration it)
    '''{method}«functionNameFragment»(«IF it.parameter !== null»«it.parameter.referenceType.name» «it.parameter.name»«ENDIF») «IF it.^return instanceof ServiceReturnDeclaration»: «it.^return.referenceType.name»«ENDIF»«IF it.alternateReturn !== null»: «it.alternateReturn.functionUnionReturnConcatenated»«ENDIF»
	'''
    
    def serviceRepresentation(ServiceDeclaration it)
    '''
        class «name?:"none"»«serviceStereotypeFragment» {
            «FOR dataFunction : it.dataDeclarationsForService»
                «dataFunction.dataFunctionRepresentation»
            «ENDFOR»
            «FOR function : it.functionDeclarationsForService»
                «function.functionRepresentation»
            «ENDFOR»
        }
    '''
    
    def actorStereotypeFragment(ActorDeclaration it)
    '''«IF map !== null» << MappedActor >> «ELSE» << Actor >>«ENDIF»'''
    
    def actorRepresentation(ActorDeclaration it)
    '''
        class «name?:"none"»«actorStereotypeFragment» {
            «IF realm !== null»realm "«realm.value»"«ENDIF»
            «IF claim !== null»claim "«claim.value»"«ENDIF»
            «IF identity !== null»identity "«identity.sourceCode»"«ENDIF»
        }
    '''

    def entityExtends(EntityDeclaration it)
    '''
        «FOR supertype : it.extends»
            «name» --|> «supertype.name»
        «ENDFOR»
    '''
    
    def transferMaps(TransferDeclaration it)
    '''
        «IF it.map !== null»
            «name» ...> "«it.map.name»" «it.map.entity.name»«IF it.automap» : <<automapped>>«ENDIF»
        «ENDIF»
    '''
    
    def serviceMaps(ServiceDeclaration it)
    '''
        «IF it.map !== null»
            «name» ...> "«it.map.name»" «it.map.entity.name»
        «ENDIF»
    '''
    
    def actorMaps(ActorDeclaration it)
    '''
        «IF it.map !== null»
            «name» ...> "«it.map.name»" «it.map.entity.name»
        «ENDIF»
    '''
    
    def actorExports(ActorDeclaration it)
    '''
		«FOR exp : it.exports»
            «name» ...> «exp.name» : <<exports>>
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
        «FOR annotation : annotationDeclarations»
            «annotation.annotationRepresentation»
        «ENDFOR»
    }

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
    	«FOR transfer : transferDeclarations»
            «transfer.transferRepresentation»
        «ENDFOR»
        
        «FOR transfer : transferDeclarations»
            «transfer.transferMaps»
        «ENDFOR»

        «FOR service : serviceDeclarations»
            «service.serviceRepresentation»
        «ENDFOR»
        
        «FOR service : serviceDeclarations»
            «service.serviceMaps»
        «ENDFOR»
    }
    
    together {
     	«FOR actor : actorDeclarations»
	        «actor.actorRepresentation»
	    «ENDFOR»

	    «FOR actor : actorDeclarations»
	        «actor.actorMaps»
	    «ENDFOR»

	    «FOR actor : actorDeclarations»
	        «actor.actorExports»
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
            val importList = imports.filter[i | i.model.name.equals(entityDeclaration.parentContainer(ModelDeclaration).name)]
                .map[i | i.alias !== null ? i.alias + "::" + entityDeclaration.name : entityDeclaration.name]
            if (importList !== null && importList.size > 0) {
                return importList.get(0)
            } else {
                return entityDeclaration.name
            }
        } else {
            return entityDeclaration.name
        }
    }

}
