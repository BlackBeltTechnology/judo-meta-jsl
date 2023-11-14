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
import hu.blackbelt.judo.meta.jsl.jsldsl.DiagramDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.DiagramGroupDeclaration

@Singleton
class JsldslDefaultPlantUMLDiagramGenerator {

    @Inject extension JslDslModelExtension

    def defaultStyle() '''
        'top to bottom direction

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


    def entityExtendsFragment(EntityDeclaration it)
    '''«FOR extend : extends BEFORE 'extends ' SEPARATOR ', '»«extend.name»«ENDFOR»'''

    def entityStereotypeFragment(EntityDeclaration it)
    '''«IF isAbstract» << (A,Transparent) Abstract >> «ELSE» << (E,Transparent) Entity >>«ENDIF»'''

    def entityRelationNameFragment(EntityRelationDeclaration it)
    '''«IF isRequired»<b>«ENDIF»«name»«IF isRequired»</b>«ENDIF»'''

    def entityRelationRepresentation(EntityRelationDeclaration it)
    '''<&pencil> «entityRelationNameFragment» : «it.parentContainer(ModelDeclaration).getExternalName(referenceType)»«cardinalityRepresentation»'''

    def entityFieldModifierFragment(EntityFieldDeclaration it)
    '''«IF isIdentifier»<&key>«ELSEIF isCalculated»<U+00A0><U+00A0><U+00A0>«ELSE»<&pencil>«ENDIF»'''

    def entityFieldNameFragment(EntityFieldDeclaration it)
    '''«IF isRequired»<b>«ENDIF»«name»«IF isRequired»</b>«ENDIF»'''

    def entityFieldRepresentation(EntityFieldDeclaration it)
    '''«entityFieldModifierFragment» «entityFieldNameFragment» : «it.parentContainer(ModelDeclaration).getExternalName(referenceType)»«IF isMany»[0..*]«ENDIF»'''

	def entityBackgroundColors(boolean external)
    '''«IF external»#back:white|efefef;header:dedede|d7d7d7«ELSE»#back:white|cfe3e8;header:cee2e6|bed8df«ENDIF»'''

    def entityRepresentation(EntityDeclaration it, ModelDeclaration model, boolean external, boolean showAttr)
    '''
		class «model.getExternalName(it)»«entityStereotypeFragment» «entityBackgroundColors(external)» {
			«IF showAttr»
			    «FOR field : it.fields»
		    		«field.entityFieldRepresentation»
			    «ENDFOR»
		    «ENDIF»
		}
	'''
    
    def transferStereotypeFragment(TransferDeclaration it)
    '''«IF it instanceof ViewDeclaration» << (V,Transparent) >> «
        ELSEIF it instanceof RowDeclaration» << (R,Transparent) >> «
        ELSEIF it instanceof ErrorDeclaration» << (E,Transparent) >> «
        ELSEIF it instanceof TransferDeclaration» << (T,Transparent) >> «
        ENDIF
    »'''

    def transferFieldModifierFragment(TransferFieldDeclaration it)
    '''«IF it.reads»<&caret-left>«ELSEIF it.maps»<&caret-right>«ELSE»<U+00A0><U+00A0><U+00A0>«ENDIF»'''

    def transferFieldNameFragment(TransferFieldDeclaration it)
    '''«IF isRequired»<b>«ENDIF»«name»«IF isRequired»</b>«ENDIF»'''
    
    def transferFieldRepresentation(TransferFieldDeclaration it)
    '''«transferFieldModifierFragment» «transferFieldNameFragment» : «it.parentContainer(ModelDeclaration).getExternalName(referenceType)»'''

	def transferBackgroundColors(boolean external)
    '''«IF external»#back:white|efefef;header:dedede|d7d7d7«ELSE»#back:white|f9f4cb;header:f4f0c7|f7f0b9«ENDIF»'''

    def transferRepresentation(TransferDeclaration it, ModelDeclaration model, boolean external, boolean showAttr)
    '''
        class «model.getExternalName(it)»«transferStereotypeFragment» «transferBackgroundColors(external)» {
			«IF showAttr»
	            «FOR field : it.fields»
	                «field.transferFieldRepresentation»
	            «ENDFOR»
		    «ENDIF»
        }
    '''
        
    def actorStereotypeFragment(ActorDeclaration it)
    '''«IF map !== null» << MappedActor >> «ELSE» << Actor >>«ENDIF»'''
    
    def actorRepresentation(ActorDeclaration it, ModelDeclaration model, String prefix)
    '''
           actor :«model.getExternalName(it)»: «IF !prefix.empty»as «prefix».«name»«ENDIF»
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
    ''' «base.getExternalName(eContainer as EntityDeclaration)»  «
        IF opposite !== null» «opposite.entityRelationOppositeRepresentation» «ELSE» --> «ENDIF
        » "«name»\n«cardinalityRepresentation» " «base.getExternalName(referenceType as EntityDeclaration)»'''

    def entityCalculatedRelationRepresentation(EntityRelationDeclaration it, ModelDeclaration base)
    '''«IF referenceType !== null
         »« base.getExternalName(eContainer as EntityDeclaration)» ..> "«name»  \n«cardinalityRepresentation»  " «base.getExternalName(referenceType as EntityDeclaration)»
	   «ENDIF»'''

    def transferRelationRepresentation(TransferRelationDeclaration it, ModelDeclaration base)
    '''«IF referenceType !== null
    	»« base.getExternalName(it.parentContainer(TransferDeclaration))» -«IF it.parentContainer(TransferDeclaration) instanceof ActorDeclaration»right«ENDIF»-> "«name»  \n«cardinalityRepresentation»  " «base.getExternalName(referenceType)»
	   «ENDIF»'''

    def diagramRepresentation(ModelDeclaration model, DiagramDeclaration diagram, DiagramDeclaration group)
	    '''
	    	«IF group instanceof DiagramGroupDeclaration»together«ELSE»package «diagram.name»«ENDIF» {
	    		«FOR show : group.diagramShowDeclarations»
			        «FOR cls : show.showClassDeclarations(model)»
			        	«IF cls instanceof EntityDeclaration»
			            	«(cls as EntityDeclaration).entityRepresentation(model, false, show.diagramShowFields)»
			        	«ELSEIF cls instanceof ActorDeclaration»
							«(cls as ActorDeclaration).actorRepresentation(model, diagram.name)»
			        	«ELSEIF cls instanceof TransferDeclaration»
							«(cls as TransferDeclaration).transferRepresentation(model, false, show.diagramShowFields)»
			        	«ENDIF»
			        «ENDFOR»
		        «ENDFOR»
		        «FOR grp : group.diagramGroupDeclarations»
		            «model.diagramRepresentation(diagram, grp)»
		        «ENDFOR»
			}
	    '''

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

«««    package «name» {
«««	
«««	together {
«««		together {
«««			«FOR transfer : transferDeclarations»
«««				«transfer.transferRepresentation(false, true)»
«««		    «ENDFOR»
«««	
«««	        «FOR transfer : getExternalReferencedTransfers»
«««				«transfer.transferRepresentation(true, false)»
«««	        «ENDFOR»
«««	
«««	        «FOR relation : allTransferRelations»
«««	            «relation.transferRelationRepresentation(it)»
«««	        «ENDFOR»
«««	    }
«««	
«««	    together {
«««	        «FOR entity : entityDeclarations»
«««	            «entity.entityRepresentation(false, true)»
«««	        «ENDFOR»
«««	
«««	        «FOR entity : getExternalReferencedEntities»
«««	            «entity.entityRepresentation(true, false)»
«««	        «ENDFOR»
«««	
«««	        «FOR entity : entityDeclarations»
«««	            «entity.entityExtends»
«««	        «ENDFOR»
«««	
«««	        «FOR relation : getAllStoredRelations(true)»
«««	            «relation.entityStoredRelationRepresentation(it)»
«««	        «ENDFOR»
«««	
«««	        «FOR relation : getAllCalculatedRelations(true)»
«««	            «relation.entityCalculatedRelationRepresentation(it)»
«««	        «ENDFOR»
«««	
«««	        «FOR external : getExternalReferencedEntities»
«««	            «FOR relation : external.storedRelations»
«««					«IF relation.opposite instanceof EntityRelationOppositeInjected && relation.referenceType?.parentContainer(ModelDeclaration)?.name === it.name»
«««					«relation.entityStoredRelationRepresentation(it)»
«««					«ENDIF»
«««	            «ENDFOR»
«««	        «ENDFOR»
«««	    }
«««	}
«««
«««	together {
«««     	«FOR actor : actorDeclarations»
«««	        «actor.actorRepresentation("")»
«««	    «ENDFOR»
«««	}
«««
«««    «FOR relation : allActorTransferRelations»
«««        «relation.transferRelationRepresentation(it)»
«««    «ENDFOR»
«««
«««    «FOR transfer : transferDeclarations»
«««        «transfer.transferMaps(it)»
«««    «ENDFOR»
«««
««« 	«FOR actor : actorDeclarations»
«««        «actor.transferMaps(it)»
«««    «ENDFOR»
«««	}

 	«FOR diagram : diagramDeclarations»
        «diagramRepresentation(diagram, diagram)»
        
		«FOR relation : diagram.getDiagramRelations(it)»
			«relation.entityStoredRelationRepresentation(it)»
		«ENDFOR»
    «ENDFOR»
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
}
