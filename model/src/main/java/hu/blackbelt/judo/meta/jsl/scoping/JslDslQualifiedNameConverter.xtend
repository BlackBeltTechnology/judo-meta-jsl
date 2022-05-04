package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.naming.QualifiedName
import org.slf4j.LoggerFactory
import org.slf4j.Logger

class JslDslQualifiedNameConverter extends IQualifiedNameConverter.DefaultImpl {
	Logger log = LoggerFactory.getLogger(JslDslQualifiedNameConverter);
	
    override getDelimiter() {
  		log.debug("JslDslQualifiedNameConverter.getDelimiter")
        return "::" //super.delimiter;
	}
	
	override toQualifiedName(String qualifiedNameAsString) {
		log.debug("JslDslQualifiedNameConverter.toQualifiedName " + qualifiedNameAsString)
		if (qualifiedNameAsString !== null) {
			super.toQualifiedName(qualifiedNameAsString)			
		} else {
			null
		}
	}
	
	override toString(QualifiedName qualifiedName) {
		log.debug("JslDslQualifiedNameConverter.toString " + qualifiedName.toString("::"))
		if (qualifiedName !== null) {
			super.toString(qualifiedName)		
		} else {
			null
		}
	}
	
}