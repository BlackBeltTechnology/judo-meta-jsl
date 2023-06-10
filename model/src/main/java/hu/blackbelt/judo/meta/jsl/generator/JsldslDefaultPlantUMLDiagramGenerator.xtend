package hu.blackbelt.judo.meta.jsl.generator

import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration
import com.google.inject.Singleton
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension
import hu.blackbelt.judo.meta.jsl.jsldsl.DataTypeDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ErrorDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ErrorField
import java.util.Collection
import java.util.HashSet
import java.util.Set
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeInjected
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeReferenced
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOpposite
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.AnnotationDeclaration
//import hu.blackbelt.judo.meta.jsl.jsldsl.ServiceDeclaration
//import hu.blackbelt.judo.meta.jsl.jsldsl.ServiceDataDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.ActorDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityStoredRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityStoredFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityCalculatedMemberDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityCalculatedFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityCalculatedRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.Named
import org.eclipse.emf.ecore.EObject

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

		skinparam actorStyle awesome
        
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

«««        skinparam rectangle {
«««            BorderColor Transparent
«««            FontColor Transparent
«««        }
    '''

    def cardinalityRepresentation(EntityStoredRelationDeclaration it)
    '''[«IF required»1«ELSE»0«ENDIF»..«IF isMany»*«ELSE»1«ENDIF»]'''

    def cardinalityRepresentation(EntityCalculatedRelationDeclaration it)
    '''[0..«IF isMany»*«ELSE»1«ENDIF»]'''

    def cardinalityRepresentation(TransferRelationDeclaration it)
    '''[«IF required»1«ELSE»0«ENDIF»..«IF isMany»*«ELSE»1«ENDIF»]'''

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
    '''«IF isAbstract» << Abstract >> «ELSE» << Entity >>«ENDIF»'''

    def entityFieldCardinalityFragment(EntityStoredFieldDeclaration it)
    '''«IF isMany»[0..*]«ENDIF»'''

    def entityFieldModifierFragment(EntityStoredFieldDeclaration it)
    '''«IF isIdentifier»<&key>«ELSE»<&pencil>«ENDIF»'''

    def entityFieldNameFragment(EntityStoredFieldDeclaration it)
    '''«IF isRequired»<b>«ENDIF»«name»«IF isRequired»</b>«ENDIF»'''

    def entityFieldRepresentation(EntityStoredFieldDeclaration it)
    '''«entityFieldModifierFragment» «entityFieldNameFragment» : «it.parentContainer(ModelDeclaration).getExternalName(referenceType)»«entityFieldCardinalityFragment»'''

//    def entityQueryParameterFragment(EntityQueryDeclaration it)
//    '''«FOR param : parameters BEFORE '(' SEPARATOR ', ' AFTER ')'»«param.name» : «param.referenceType.name» =«param.^default»«ENDFOR»'''

    def entityDerivedRepresentation(EntityCalculatedMemberDeclaration it)
    '''<U+00A0><U+00A0><U+00A0><U+00A0>«name» : «it.parentContainer(ModelDeclaration).getExternalName(referenceType)»«IF isMany»[0..*]«ENDIF»'''

//    def entityQueryRepresentation(EntityQueryDeclaration it)
//    '''~«name»«entityQueryParameterFragment» : «referenceType.name»[0..*]'''


//    def constraintParameterFragment(ConstraintDeclaration it)
//    '''«FOR param : error.parameters BEFORE '(' SEPARATOR ', ' AFTER ')'»«param.errorFieldType.name» =«param.expession.sourceCode»«ENDFOR»'''
//
//    def constraintRepresentation(ConstraintDeclaration it)
//    '''-«error.errorDeclarationType.name»«constraintParameterFragment»'''


    def entityRepresentation(EntityDeclaration it)
    '''
        class «name?:"none"»«entityStereotypeFragment» {
            «FOR member : members»
            	«IF member instanceof EntityCalculatedFieldDeclaration»
                «member.entityDerivedRepresentation»
                «ENDIF»
            	«IF member instanceof EntityStoredFieldDeclaration»
                «member.entityFieldRepresentation»
                «ENDIF»
            «ENDFOR»
        }
    '''
    
    def transferFieldModifierFragment(TransferFieldDeclaration it)
    '''«IF it.reads»<&caret-left>«ELSEIF it.maps»<&caret-right>«ELSE»<U+00A0><U+00A0><U+00A0>«ENDIF»'''

    def transferStereotypeFragment(TransferDeclaration it)
    '''«IF automap» << AutoMapped >> «ELSE» << Transfer >>«ENDIF»'''
    
    def transferFieldNameFragment(TransferFieldDeclaration it)
    '''«IF isRequired»<b>«ENDIF»«name»«IF isRequired»</b>«ENDIF»'''
    
//    def transferFieldCardinalityFragment(TransferFieldDeclaration it)
//    '''«IF isIsMany»[0..*]«ENDIF»'''
    
    def transferFieldRepresentation(TransferFieldDeclaration it)
    '''«transferFieldModifierFragment»«transferFieldNameFragment» : «it.parentContainer(ModelDeclaration).getExternalName(referenceType)»
	'''

    def transferRepresentation(TransferDeclaration it)
    '''
        class «name?:"none"»«transferStereotypeFragment» {
            «FOR field : it.fields»
                «field.transferFieldRepresentation»
            «ENDFOR»
        }
    '''
    
//    def serviceStereotypeFragment(ServiceDeclaration it)
//    '''«IF map !== null» << MappedService >> «ELSE» << Service >>«ENDIF»'''
//    
//    def dataFunctionNameFragment(ServiceDataDeclaration it)
//    '''«name»'''
//    
//    def dataFunctionCardinalityFragment(ServiceDataDeclaration it)
//    '''«IF isIsMany»[0..*]«ENDIF»'''
//    
//    def dataFunctionModifierFragment(ServiceDataDeclaration it)
//    '''«IF it.guard !== null»~«ELSE»+«ENDIF»'''
//    
//    def dataFunctionRepresentation(ServiceDataDeclaration it)
//    '''{method}«dataFunctionModifierFragment»«dataFunctionNameFragment» : «it.^return.referenceType.name»«dataFunctionCardinalityFragment» <b>=></b> «it.expression.sourceCode»
//	'''
	
//	def functionNameFragment(ServiceFunctionDeclaration it)
//    '''«name»'''
//    
//    def functionUnionReturnConcatenated(ServiceReturnAlternateDeclaration it)
//    '''«it.referenceTypes.map[r | r.referenceType.name].join(' | ')»'''
    
//    def functionModifierFragment(ServiceFunctionDeclaration it)
//    '''«IF it.guard !== null»~«ELSE»+«ENDIF»'''
//    
//    def functionRepresentation(ServiceFunctionDeclaration it)
//    '''{method}«functionModifierFragment»«functionNameFragment»(«IF it.parameter !== null»«it.parameter.referenceType.name» «it.parameter.name»«ENDIF») «IF it.^return instanceof ServiceReturnDeclaration»: «it.^return.referenceType.name»«ENDIF»«IF it.alternateReturn !== null»: «it.alternateReturn.functionUnionReturnConcatenated»«ENDIF»
//	'''
    
//    def serviceRepresentation(ServiceDeclaration it)
//    '''
//        class «name?:"none"»«serviceStereotypeFragment» {
//            «FOR dataFunction : it.dataDeclarationsForService»
//                «dataFunction.dataFunctionRepresentation»
//            «ENDFOR»
//            «FOR function : it.functionDeclarationsForService»
//                «function.functionRepresentation»
//            «ENDFOR»
//        }
//    '''
    
    def actorStereotypeFragment(ActorDeclaration it)
    '''«IF map !== null» << MappedActor >> «ELSE» << Actor >>«ENDIF»'''
    
    def actorRepresentation(ActorDeclaration it)
    '''
           actor «name?:"none"»
«««        class «name?:"none"»«actorStereotypeFragment» {
«««            «IF realm !== null»realm "«realm.value.value»"«ENDIF»
«««            «IF claim !== null»claim "«claim.value.value»"«ENDIF»
«««            «IF identity !== null»identity "«identity.expression»"«ENDIF»
«««        }
    '''

    def entityExtends(EntityDeclaration it)
    '''
        «FOR supertype : it.extends»
            «name» -up-|> «supertype.name»
        «ENDFOR»
    '''
    
    def transferMaps(TransferDeclaration it, ModelDeclaration base)
    '''
        «IF it.map !== null»
            «name» -down[dotted]-> «base.getExternalName(it.map.entity)»
        «ENDIF»
    '''
    
    def entityRelationOppositeInjectedRepresentation(EntityRelationOppositeInjected it)
    '''"«name»  \n«IF many»[0..*]  «ELSE»[0..1]  «ENDIF»" -- '''

    def entityRelationOppositeReferencedRepresentation(EntityRelationOppositeReferenced it)
    '''"«oppositeType?.name»  \n«oppositeType?.cardinalityRepresentation»" -- '''

    def entityRelationOppositeRepresentation(EntityRelationOpposite it) {
        switch it {
            EntityRelationOppositeInjected : it.entityRelationOppositeInjectedRepresentation
            EntityRelationOppositeReferenced : it.entityRelationOppositeReferencedRepresentation
        }
    }

    def entityRelationRepresentation(EntityStoredRelationDeclaration it, ModelDeclaration base)
    '''« base.getExternalName(eContainer as EntityDeclaration)» «
        IF opposite !== null» «opposite.entityRelationOppositeRepresentation» «ELSE» --> «ENDIF
        » "«name»\n«cardinalityRepresentation»" «base.getExternalName(referenceType as EntityDeclaration)»'''

    def entityRelationRepresentation(EntityCalculatedRelationDeclaration it, ModelDeclaration base)
    '''«IF referenceType !== null
         »« base.getExternalName(eContainer as EntityDeclaration)» ..> "«name»  \n«cardinalityRepresentation»  " «base.getExternalName(referenceType as EntityDeclaration)»
	   «ENDIF»'''

    def transferRelationRepresentation(TransferRelationDeclaration it, ModelDeclaration base)
    '''«IF referenceType !== null
    	»« base.getExternalName(it.parentContainer(TransferDeclaration))» -«IF it.parentContainer(TransferDeclaration) instanceof ActorDeclaration»right«ENDIF»-> "«name»  \n«cardinalityRepresentation»  " «base.getExternalName(referenceType)»
	   «ENDIF»'''

    def generate(ModelDeclaration it, String style) '''
    @startuml «name?:"none"»
    allow_mixing
    '!pragma layout smetana
    «IF style === null || style.blank»«defaultStyle»«ELSE»«style»«ENDIF»

    package «name» {

«««    together {
«««        «FOR annotation : annotationDeclarations»
«««            «annotation.annotationRepresentation»
«««        «ENDFOR»
«««    }

«««    together {
«««        «FOR type : dataTypeDeclarations»
«««            «type.dataTypeRepresentation»
«««        «ENDFOR»
«««
«««        «FOR enumt : enumDeclarations»
«««            «enumt.enumRepresentation»
«««        «ENDFOR»
«««    }

«««    together {
«««        «FOR error : errorDeclarations»
«««            «error.errorRepresentation»
«««        «ENDFOR»
«««    }
	
	together {
		together {
			«FOR transfer : simpleTransferDeclarations»
				«transfer.transferRepresentation»
		    «ENDFOR»
	
			«FOR transfer : viewDeclarations»
				«transfer.transferRepresentation»
			«ENDFOR»
	
	    	«FOR transfer : rowDeclarations»
	            «transfer.transferRepresentation»
	        «ENDFOR»
	
	        «FOR relation : allSimpleTransferRelations»
	            «relation.transferRelationRepresentation(it)»
	        «ENDFOR»
	
	        «FOR relation : allViewTransferRelations»
	            «relation.transferRelationRepresentation(it)»
	        «ENDFOR»
	    }
	
	    together {
	        «FOR entity : entityDeclarations»
	            «entity.entityRepresentation»
	        «ENDFOR»
	
	        «FOR entity : externalReferencedRelationReferenceTypes»
	            class «getExternalName(entity)» <«entity.parentContainer(ModelDeclaration)?.name»> << External >>
	        «ENDFOR»
	
	        «FOR entity : entityDeclarations»
	            «entity.entityExtends»
	        «ENDFOR»
	
	        «FOR relation : getAllRelations(true)»
	            «relation.entityRelationRepresentation(it)»
	        «ENDFOR»
	
	        «FOR relation : getAllCalculatedRelations(true)»
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
	}

	together {
     	«FOR actor : actorDeclarations»
	        «actor.actorRepresentation»
	    «ENDFOR»
	}

    «FOR relation : allActorTransferRelations»
        «relation.transferRelationRepresentation(it)»
    «ENDFOR»

    «FOR transfer : transferDeclarations»
        «transfer.transferMaps(it)»
    «ENDFOR»

	}
    @enduml
    '''


    def Collection<EntityDeclaration> getExternalReferencedRelationReferenceTypes(ModelDeclaration it) {
        val Set<EntityDeclaration> externalEntities = new HashSet()
        for (entity : it.entityDeclarations) {
            for (relation : entity.relations) {
                if (relation.referenceType?.parentContainer(ModelDeclaration)?.name !== it.name) {
                    externalEntities.add(relation.referenceType as EntityDeclaration)
                }
            }
            for (relation : entity.calculatedRelations) {
                if (relation.referenceType?.parentContainer(ModelDeclaration)?.name !== it.name) {
                    externalEntities.add(relation.referenceType as EntityDeclaration)
                }
            }
            for (superType : entity.extends) {
                if (superType.parentContainer(ModelDeclaration)?.name !== it.name) {
                    externalEntities.add(superType)
                }
            }
        }

        for (transfer : it.transferDeclarations) {
    		if (transfer.map !== null && transfer.map.entity.parentContainer(ModelDeclaration)?.name !== it.name) {
    			externalEntities.add(transfer.map.entity)
    		}
    	}
        externalEntities
    }

    def String getExternalName(ModelDeclaration it, EObject object) {
    	if (!(object instanceof Named)) {
    		return "<none>";
    	}
    	
    	val Named named = object as Named;
    	
        if (named.parentContainer(ModelDeclaration) === null) {
            return named.name
        }

        if (it.name !== named?.parentContainer(ModelDeclaration).name) {
            val importList = imports.filter[i | i.model.name.equals(named.parentContainer(ModelDeclaration).name)]
                .map[i | i.alias !== null ? i.alias + "::" + named.name : named.name]
            if (importList !== null && importList.size > 0) {
                return importList.get(0)
            } else {
                return named.name
            }
        } else {
            return named.name
        }
    }
}
