package hu.blackbelt.judo.meta.jsl.runtime;

import com.google.inject.Singleton;
import org.eclipse.xtext.common.services.DefaultTerminalConverters;
import org.eclipse.xtext.conversion.IValueConverter;
import org.eclipse.xtext.conversion.ValueConverter;
import org.eclipse.xtext.conversion.ValueConverterException;
import org.eclipse.xtext.conversion.impl.IDValueConverter;
import org.eclipse.xtext.nodemodel.INode;

@Singleton
public class JslTerminalConverters extends DefaultTerminalConverters {

	private IValueConverter<String> idConverter = new IValueConverter<String>() {

		/** Must delegate, as extending it will not work with data type rules. */
		IDValueConverter delegate = new IDValueConverter() {
			@Override
			public String toValue(String string, INode node) {
				if (string == null)
					return null;
				return string.startsWith("\\") ? string.substring(1) : string;
			}
			
			@Override
			protected String toEscapedString(String value) {
				if (mustEscape(value))
					return "\\" + value;
				return value;
			}
		};

		@Override
		public String toValue(String string, INode node) {
			return delegate.toValue(string, node);
		};

		@Override
		public String toString(String value) throws ValueConverterException {
			return delegate.toString(value);
		}
	};

	@ValueConverter(rule = "ValidId")
	public IValueConverter<String> getValidIdConverter() {
		return idConverter;
	}
	
	@ValueConverter(rule = "QualifiedNameElement")
	public IValueConverter<String> getQualifiedNameElementConverter() {
		return idConverter;
	}
	
	@ValueConverter(rule = "ID")
	public IValueConverter<String> getIDConverter() {
		return idConverter;
	}
	
	@ValueConverter(rule = "FeatureName")
	public IValueConverter<String> getFeatureNameConverter() {
		return idConverter;
	}

	
	@ValueConverter(rule = "FunctionName")
	public IValueConverter<String> getFunctionNameConverter() {
		return idConverter;
	}

	@ValueConverter(rule = "DATE")
	public IValueConverter<String> getDateTerminalConverter() {
		return new IValueConverter<String>() {

			@Override
			public String toString(String value) throws ValueConverterException {
				return String.format("`%s`", value);
			}

			@Override
			public String toValue(String string, INode node) throws ValueConverterException {
				return string.substring(1, string.length() - 1);
			}

		};
	}

	@ValueConverter(rule = "TIMESTAMP")
	public IValueConverter<String> getTimeStampTerminalConverter() {
		return new IValueConverter<String>() {

			@Override
			public String toString(String value) throws ValueConverterException {
				return String.format("`%s`", value);
			}

			@Override
			public String toValue(String string, INode node) throws ValueConverterException {
				return string.substring(1, string.length() - 1);
			}

		};
	}

	@ValueConverter(rule = "TIME")
	public IValueConverter<String> getTimeTerminalConverter() {
		return new IValueConverter<String>() {

			@Override
			public String toString(String value) throws ValueConverterException {
				return String.format("`%s`", value);
			}

			@Override
			public String toValue(String string, INode node) throws ValueConverterException {
				return string.substring(1, string.length() - 1);
			}

		};
	}

	@ValueConverter(rule = "MEASURE_NAME")
	public IValueConverter<String> getMeasureNameTerminalConverter() {
		return new IValueConverter<String>() {

			@Override
			public String toString(String value) throws ValueConverterException {
				return String.format("[%s]", value);
			}

			@Override
			public String toValue(String string, INode node) throws ValueConverterException {
				return string.substring(1, string.length() - 1);
			}

		};
	}

}
