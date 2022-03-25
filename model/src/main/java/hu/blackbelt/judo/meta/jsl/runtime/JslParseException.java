package hu.blackbelt.judo.meta.jsl.runtime;

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
