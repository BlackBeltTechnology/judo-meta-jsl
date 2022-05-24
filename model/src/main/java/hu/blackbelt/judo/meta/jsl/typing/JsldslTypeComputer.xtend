package hu.blackbelt.judo.meta.jsl.typing;

import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslFactory
import hu.blackbelt.judo.meta.jsl.jsldsl.EnumDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.NavigationExpression

class JsldslTypeComputer {
	private static val factory = JsldslFactory.eINSTANCE
	static val ENUM_DECLARATION_TYPE = factory.createEnumDeclaration => [name = 'enumDeclarationType']
	
	def EnumDeclaration typeFor(NavigationExpression e) {
		System.out.println("JsldslTypeComputer.typeFor=" + e.toString);
		
		return null;
	}

}
