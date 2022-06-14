package hu.blackbelt.judo.meta.jsl.scoping;

import org.eclipse.xtext.common.services.DefaultTerminalConverters;
import org.eclipse.xtext.conversion.IValueConverter;
import org.eclipse.xtext.conversion.ValueConverter;

public class JslDslSpecialValueConverterService extends DefaultTerminalConverters {
	
	@ValueConverter(rule = "JslID")
	public IValueConverter<String> JslID() {
		return ID();
	}
}
