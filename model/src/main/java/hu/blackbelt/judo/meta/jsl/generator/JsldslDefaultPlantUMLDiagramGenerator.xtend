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
import hu.blackbelt.judo.meta.jsl.jsldsl.TransferRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.Named
import org.eclipse.emf.ecore.EObject
import hu.blackbelt.judo.meta.jsl.jsldsl.ViewDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.RowDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityMemberDeclaration

@Singleton
class JsldslDefaultPlantUMLDiagramGenerator {

    @Inject extension JslDslModelExtension

    def defaultStyle() '''
        top to bottom direction

        skinparam nodesep 50
        skinparam ranksep 100

«««        hide circle
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
«««            FontColor<< Entity >> white

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

    '''

    def cardinalityRepresentation(EntityRelationDeclaration it)
    '''[«IF required»1«ELSE»0«ENDIF»..«IF isMany»*«ELSE»1«ENDIF»]'''

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
    '''«IF isAbstract» << (A,Transparent) Abstract >> «ELSE» << (E,Transparent) Entity >>«ENDIF»'''

    def entityFieldCardinalityFragment(EntityFieldDeclaration it)
    '''«IF isMany»[0..*]«ENDIF»'''

    def entityFieldModifierFragment(EntityFieldDeclaration it)
    '''«IF isIdentifier»<&key>«ELSE»<&pencil>«ENDIF»'''

    def entityFieldNameFragment(EntityFieldDeclaration it)
    '''«IF isRequired»<b>«ENDIF»«name»«IF isRequired»</b>«ENDIF»'''

    def entityRelationNameFragment(EntityRelationDeclaration it)
    '''«IF isRequired»<b>«ENDIF»«name»«IF isRequired»</b>«ENDIF»'''

    def entityFieldRepresentation(EntityFieldDeclaration it)
    '''«entityFieldModifierFragment» «entityFieldNameFragment» : «it.parentContainer(ModelDeclaration).getExternalName(referenceType)»«entityFieldCardinalityFragment»'''

    def entityRelationRepresentation(EntityRelationDeclaration it)
    '''<&pencil> «entityRelationNameFragment» : «it.parentContainer(ModelDeclaration).getExternalName(referenceType)»«cardinalityRepresentation»'''

    def entityDerivedRepresentation(EntityMemberDeclaration it)
    '''<U+00A0><U+00A0><U+00A0><U+00A0>«name» : «it.parentContainer(ModelDeclaration).getExternalName(referenceType)»«IF isMany»[0..*]«ENDIF»'''


    def entityRepresentation(EntityDeclaration it)
    '''
		class «name?:"none"»«entityStereotypeFragment» {
		    «FOR field : it.fields»
		    	«IF field.calculated»
		    		«field.entityDerivedRepresentation»
		    	«ENDIF»
		    	«IF !field.calculated»
		    		«field.entityFieldRepresentation»
		    	«ENDIF»
		    «ENDFOR»
		}
	'''
    
    def transferFieldModifierFragment(TransferFieldDeclaration it)
    '''«IF it.reads»<&caret-left>«ELSEIF it.maps»<&caret-right>«ELSE»<U+00A0><U+00A0><U+00A0>«ENDIF»'''

    def transferStereotypeFragment(TransferDeclaration it)
    '''«IF it instanceof ViewDeclaration» << (V,Transparent) Transfer >> «
        ELSEIF it instanceof RowDeclaration» << (R,Transparent) Transfer >> «
        ELSEIF it instanceof TransferDeclaration» << (T,Transparent) Transfer >> «
        ENDIF
    »'''

    def transferExternalStereotypeFragment(TransferDeclaration it)
    '''«IF it instanceof TransferDeclaration» << (T,Transparent) External >> «
        ELSEIF it instanceof ViewDeclaration» << (V,Transparent) External >> «
        ELSEIF it instanceof RowDeclaration» << (R,Transparent) External >> «
        ENDIF
    »'''
    
    def transferFieldNameFragment(TransferFieldDeclaration it)
    '''«IF isRequired»<b>«ENDIF»«name»«IF isRequired»</b>«ENDIF»'''
    
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
        
    def actorStereotypeFragment(ActorDeclaration it)
    '''«IF map !== null» << MappedActor >> «ELSE» << Actor >>«ENDIF»'''
    
    def actorRepresentation(ActorDeclaration it)
    '''
           actor «name?:"none"»
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

    def entityStoredRelationRepresentation(EntityRelationDeclaration it, ModelDeclaration base)
    '''« base.getExternalName(eContainer as EntityDeclaration)» «
        IF opposite !== null» «opposite.entityRelationOppositeRepresentation» «ELSE» --> «ENDIF
        » "«name»\n«cardinalityRepresentation»" «base.getExternalName(referenceType as EntityDeclaration)»'''

    def entityCalculatedRelationRepresentation(EntityRelationDeclaration it, ModelDeclaration base)
    '''«IF referenceType !== null
         »« base.getExternalName(eContainer as EntityDeclaration)» ..> "«name»  \n«cardinalityRepresentation»  " «base.getExternalName(referenceType as EntityDeclaration)»
	   «ENDIF»'''

    def transferRelationRepresentation(TransferRelationDeclaration it, ModelDeclaration base)
    '''«IF referenceType !== null
    	»« base.getExternalName(it.parentContainer(TransferDeclaration))» -«IF it.parentContainer(TransferDeclaration) instanceof ActorDeclaration»right«ENDIF»-> "«name»  \n«cardinalityRepresentation»  " «base.getExternalName(referenceType)»
	   «ENDIF»'''

    def generate(ModelDeclaration it, String style) '''
    @startuml «name?:"none"»
    <style>
    spot{
      spotClass {
        FontColor: grey;
        LineColor: grey;
      }
    </style>
    allow_mixing
    '!pragma layout smetana
    «IF style === null || style.blank»«defaultStyle»«ELSE»«style»«ENDIF»

    package «name» {
	
	together {
		together {
			«FOR transfer : transferDeclarations»
				«transfer.transferRepresentation»
		    «ENDFOR»
	
«««			«FOR transfer : viewDeclarations»
«««				«transfer.transferRepresentation»
«««			«ENDFOR»
	
	    	«FOR transfer : rowDeclarations»
	            «transfer.transferRepresentation»
	        «ENDFOR»
	
	        «FOR transfer : getExternalReferencedTransfers»
	            class «getExternalName(transfer)» <«transfer.parentContainer(ModelDeclaration)?.name»> «transfer.transferExternalStereotypeFragment»
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
	
	        «FOR entity : getExternalReferencedEntities»
	            class «getExternalName(entity)» <«entity.parentContainer(ModelDeclaration)?.name»> << (E, Transparent) External >>
	        «ENDFOR»
	
	        «FOR entity : entityDeclarations»
	            «entity.entityExtends»
	        «ENDFOR»
	
	        «FOR relation : getAllStoredRelations(true)»
	            «relation.entityStoredRelationRepresentation(it)»
	        «ENDFOR»
	
	        «FOR relation : getAllCalculatedRelations(true)»
	            «relation.entityCalculatedRelationRepresentation(it)»
	        «ENDFOR»
	
	        «FOR external : getExternalReferencedEntities»
	            «FOR relation : external.storedRelations»
	                «IF relation.opposite instanceof EntityRelationOppositeInjected && relation.referenceType?.parentContainer(ModelDeclaration)?.name === it.name»
	                    «relation.entityStoredRelationRepresentation(it)»
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


    def Collection<EntityDeclaration> getExternalReferencedEntities(ModelDeclaration it) {
        val Set<EntityDeclaration> externalEntities = new HashSet()
        for (entity : it.entityDeclarations) {
            for (relation : entity.storedRelations) {
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

    def Collection<TransferDeclaration> getExternalReferencedTransfers(ModelDeclaration it) {
        val Set<TransferDeclaration> externalTransfers = new HashSet()
        for (transfer : it.transferDeclarations) {
            for (member : transfer.members) {
                if (member instanceof TransferRelationDeclaration && (member as TransferRelationDeclaration).referenceType?.parentContainer(ModelDeclaration)?.name !== it.name) {
                    externalTransfers.add((member as TransferRelationDeclaration).referenceType)
                }
            }
        }
        externalTransfers
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
            val importList = imports.filter[i | i.model.name.equals(named.parentContainer(ModelDeclaration)?.name)]
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
