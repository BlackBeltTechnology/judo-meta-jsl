package hu.blackbelt.judo.meta.jsl.runtime;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.resource.Resource.Diagnostic;

public class JslParseException extends RuntimeException {

    private final EList<Diagnostic> errors;

    public JslParseException(String jslExpression, EList<Diagnostic> errors) {
        super("Error parsing JSL expression (" + jslExpression + "): " + errors.toString());
        this.errors = errors;
    }

    public EList<Diagnostic> getErrors() {
        return errors;
    }

}
