package hu.blackbelt.judo.meta.jsl.runtime;

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

import java.util.Collection;

import org.eclipse.xtext.validation.Issue;

@SuppressWarnings("serial")
public class JslParseException extends RuntimeException {

    private final Collection<Issue> errors;

    public JslParseException(String jslExpression, Collection<Issue> errors) {
        super("Error parsing JSL expression (" + jslExpression + ")");
        this.errors = errors;
    }

    public JslParseException(Collection<Issue> errors) {
        super("Error parsing JSL expression");
        this.errors = errors;
    }

    public Collection<Issue> getErrors() {
        return errors;
    }
    
    @Override
    public String getMessage() {
    	StringBuilder sb = new StringBuilder();
    	
    	sb.append(super.getMessage());
    	
    	for (Issue error : errors) {
    		sb.append("\n\t" + error.getMessage());
			//sb.append(" " + error.getCode() + " ");
    		sb.append(" in " + error.getUriToProblem());

    		if (error.getLineNumber() != null && error.getLineNumber() > 0) {
    			sb.append(" at [" + error.getLineNumber() + ", " + error.getColumn() +  "]");
    		}
    	}
    	
    	return sb.toString();
    }    
}
