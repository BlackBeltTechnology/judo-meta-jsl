package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.naming.QualifiedName

class JslDslQualifiedNameConverter extends IQualifiedNameConverter.DefaultImpl {
    override getDelimiter() {
    	// System.out.println("JslDslQualifiedNameConverter.getDelimiter")
        return "::" //super.delimiter;
	}
	
	override toQualifiedName(String qualifiedNameAsString) {
		if (qualifiedNameAsString !== null) {
			val qn = super.toQualifiedName(qualifiedNameAsString)			
			// System.out.println("JslDslQualifiedNameConverter.toQualifiedName " + qualifiedNameAsString + " qn: " + qn)
			qn
		} else {
			null
		}
	}
	
	override toString(QualifiedName qualifiedName) {
		if (qualifiedName !== null) {
			val str = super.toString(qualifiedName)		
			// System.out.println("JslDslQualifiedNameConverter.toString " + qualifiedName.toString("::") + " str: " + str)
			str
		} else {
			null
		}
	}
	
}