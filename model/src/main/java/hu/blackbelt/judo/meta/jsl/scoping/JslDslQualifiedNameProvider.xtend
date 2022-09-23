package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider
import com.google.inject.Singleton
import org.eclipse.emf.ecore.EObject

@Singleton
class JslDslQualifiedNameProvider extends DefaultDeclarativeQualifiedNameProvider {
	
	
	override getFullyQualifiedName(EObject obj) {
		val result = super.getFullyQualifiedName(obj);
		//if (result !== null) {
		//	System.out.println("JslDslQualifiedNameProvider.getFullyQualifiedName="+ result.toString("::") + " for " + obj);		
		//}
		result;
		
	}
	    
	override protected qualifiedName(Object obj) {
		val result = super.qualifiedName(obj)
		//if (obj instanceof ModelDeclaration) {
		//	return QualifiedName.create()
		//}
		//if (result !== null) {	
		//	System.out.println("JslDslQualifiedNameProvider.qualifiedName="+ result.toString("::") + " for " + obj);
		//}
		result
	}
	
}