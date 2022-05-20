/*
 * generated by Xtext 2.18.0
 */
package hu.blackbelt.judo.meta.jsl.ui.contentassist

import com.google.inject.Inject
import org.eclipse.xtext.CrossReference
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOpposite
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration

/**
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#content-assist
 * on how to customize the content assistant.
 */
class JslDslProposalProvider extends AbstractJslDslProposalProvider {
	
	@Inject extension JslDslModelExtension
	
	override completeEntityRelationOpposite_OppositeType(EObject model, Assignment assignment, 
		ContentAssistContext context, ICompletionProposalAcceptor acceptor
	) {
		// System.out.println("model: " + model + " assignment: " + assignment + " context: " + context)
		lookupCrossReference((assignment.getTerminal() as CrossReference), context, acceptor,
			[ ((model as EntityRelationOpposite).eContainer as EntityRelationDeclaration)
				.isSelectableForRelation(EObjectOrProxy as EntityRelationDeclaration)
			]
		);
	}
	
	override completeEntityDeclaration_Extends(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		// System.out.println(" - model: " + model + " assignment: " + assignment + " context: " + context)
		lookupCrossReference((assignment.getTerminal() as CrossReference), context, acceptor,
			[ 
				val entity = model as EntityDeclaration;
				val proposedEntity = EObjectOrProxy as EntityDeclaration
				val superEntities = entity.superEntityTypes				
				// System.out.println(" --- Obj: " + EObjectOrProxy + " - " + superEntities.join(", "))

				proposedEntity !== entity && !proposedEntity.superEntityTypes.contains(entity)
			]
		);
	}
	
	override completeCreateExpression_Type(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		lookupCrossReference((assignment.getTerminal() as CrossReference), context, acceptor, [
			false
		]);
	}

	override completeNavigationBase_EnumValue(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		lookupCrossReference((assignment.getTerminal() as CrossReference), context, acceptor, [			
			true
		]);
	}
	
}
