package hu.blackbelt.judo.meta.jsl.typing;

import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension
import hu.blackbelt.judo.meta.jsl.jsldsl.Feature

class JsldslTypeConformance {
	@Inject extension JslDslModelExtension

	def isEnumConformant(Feature c1, Feature c2) {
		System.out.println("JsldslTypeConformance.isEnumConformant="+ c1.toString + " VS " + c2.toString);
	}	
}
