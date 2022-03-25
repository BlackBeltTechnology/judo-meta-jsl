package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.naming.QualifiedName

class JslDslQualifiedNameConverter extends IQualifiedNameConverter.DefaultImpl {
    override getDelimiter() {
  //  	System.out.println("JslDslQualifiedNameConverter.getDelimiter")
        return "::" //super.delimiter;
	}
	
	override toQualifiedName(String qualifiedNameAsString) {
//		System.out.println("JslDslQualifiedNameConverter.toQualifiedName " + qualifiedNameAsString)
		if (qualifiedNameAsString !== null) {
			super.toQualifiedName(qualifiedNameAsString)			
		} else {
			null
		}
	}
	
	override toString(QualifiedName qualifiedName) {
//		System.out.println("JslDslQualifiedNameConverter.toString " + qualifiedName.toString("::"))
		if (qualifiedName !== null) {
			super.toString(qualifiedName)		
		} else {
			null
		}
	}
	
}