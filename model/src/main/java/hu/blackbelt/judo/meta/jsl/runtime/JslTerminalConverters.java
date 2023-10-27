package hu.blackbelt.judo.meta.jsl.runtime;

import com.google.common.collect.ImmutableSet;
import com.google.inject.Inject;

/*-
 * #%L
 * Judo :: Jsl :: Model
 * %%
 * Copyright (C) 2018 - 2022 BlackBelt Technology
 * %%
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 * 
 * This Source Code may also be made available under the following Secondary
 * Licenses when the conditions for such availability set forth in the Eclipse
 * Public License, v. 2.0 are satisfied: GNU General Public License, version 2
 * with the GNU Classpath Exception which is
 * available at https://www.gnu.org/software/classpath/license.html.
 * 
 * SPDX-License-Identifier: EPL-2.0 OR GPL-2.0 WITH Classpath-exception-2.0
 * #L%
 */

import com.google.inject.Singleton;

import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;

import org.apache.commons.text.StringEscapeUtils;
import org.eclipse.xtext.IGrammarAccess;
import org.eclipse.xtext.common.services.DefaultTerminalConverters;
import org.eclipse.xtext.conversion.IValueConverter;
import org.eclipse.xtext.conversion.ValueConverter;
import org.eclipse.xtext.conversion.ValueConverterException;
import org.eclipse.xtext.conversion.impl.IDValueConverter;
import org.eclipse.xtext.nodemodel.INode;

@Singleton
public class JslTerminalConverters extends DefaultTerminalConverters {
	private Set<String> valuesToEscape = ImmutableSet.of("self", "true", "false", "not");
	
	private IValueConverter<String> idConverter;

	private IValueConverter<String> fqNameConverter;

    @Inject
    JslTerminalConverters(IGrammarAccess grammarAccess) {

  		/** Must delegate, as extending it will not work with data type rules. */
  		IDValueConverter delegate = new IDValueConverter() {
  			@Override
  			public String toValue(String string, INode node) {
  				if (string == null)
  					return null;
  				if (string.startsWith("`") && string.endsWith("`")) {
  					return string.substring(1, string.length() - 1);
  				}
  				return string;
  			}
  			
  			@Override
  			protected String toEscapedString(String value) {
  				if (value != null && valuesToEscape.contains(value))
  					return "`" + value + "`";
  				return value;
  			}
  		};
  		delegate.setGrammarAccess(grammarAccess);

    	
  		this.idConverter = new IValueConverter<String>() {
	
	  		@Override
	  		public String toValue(String string, INode node) {
	  			return delegate.toValue(string, node);
	  		};
	
	  		@Override
	  		public String toString(String value) throws ValueConverterException {
	  			if (value.trim().length() == 0) return null;
	  			return delegate.toString(value);
	  		}  		
	  	};
	  	
	  	this.fqNameConverter = new IValueConverter<String>() {

			@Override
			public String toString(String value) throws ValueConverterException {
				if (value == null) {
					return null;
				}
				return Arrays.stream(value.split("::")).map(s -> idConverter.toString(s)).collect(Collectors.joining("::"));
			}

			@Override
			public String toValue(String string, INode node) throws ValueConverterException {
				if (string == null) {
					return null;
				}
				return Arrays.stream(string.split("::")).map(s -> idConverter.toValue(s, node)).collect(Collectors.joining("::"));
			}
		};

	  	
    }

	@ValueConverter(rule = "ModelName")
	public IValueConverter<String> getModelNameConverter() {
		return fqNameConverter;
	}

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
	
	@ValueConverter(rule = "JSLID")
	public IValueConverter<String> JSLID() {
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

	@ValueConverter(rule = "QueryParameterName")
	public IValueConverter<String> getQueryParameterNameConverter() {
		return idConverter;
	}

	@ValueConverter(rule = "EnumLiteralName")
	public IValueConverter<String> getEnumLiteralNameConverter() {
		return idConverter;
	}
	
	@ValueConverter(rule = "LocalName")
	public IValueConverter<String> getLocalNameConverter() {
		return fqNameConverter;
	}
	
	@ValueConverter(rule = "STRING")
	public IValueConverter<String> getStringLiteralConverter() {

		return new IValueConverter<String>() {

			@Override
			public String toString(String value) throws ValueConverterException {
				return String.format("\"%s\"", StringEscapeUtils.escapeJava(value));
			}
	
			@Override
			public String toValue(String string, INode node) throws ValueConverterException {
				return StringEscapeUtils.unescapeJava(string.substring(1, string.length() - 1));
			}

		};
	}

	@ValueConverter(rule = "RAW_STRING")
	public IValueConverter<String> getRawStringLiteralConverter() {

		return new IValueConverter<String>() {

			@Override
			public String toString(String value) throws ValueConverterException {
				return String.format("r\"%s\"", value);
			}
	
			@Override
			public String toValue(String string, INode node) throws ValueConverterException {
				return string.substring(2, string.length() - 1);
			}

		};
	}

	@ValueConverter(rule = "TIMESTAMP")
	public IValueConverter<String> getTimestampTerminalConverter() {
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


}
