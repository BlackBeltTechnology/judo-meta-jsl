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
import java.util.List;
import java.util.Map;

import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.parser.IParseResult;
import org.eclipse.xtext.validation.Issue;

@SuppressWarnings("serial")
public class JslParseException extends RuntimeException {

    private final Map<IParseResult, Collection<Issue>> errors;

    public JslParseException(String jslExpression, Map<IParseResult, Collection<Issue>> errors) {
        super("Error parsing JSL expression (" + jslExpression + ")");
        this.errors = errors;
    }

    public JslParseException(Map<IParseResult, Collection<Issue>> errors) {
        super("Error parsing JSL expression");
        this.errors = errors;
    }

    public Map<IParseResult, Collection<Issue>> getErrors() {
        return errors;
    }

    @Override
    public String getMessage() {
        StringBuilder sb = new StringBuilder();
        if (errors == null || errors.size() == 0) {
            sb.append(super.getMessage());
        }
        errors.entrySet().stream().forEach(e -> {
            IParseResult parseResult = e.getKey();
            Collection<Issue> issues = e.getValue();

            for (Issue error : issues) {
                sb.append(error.getMessage());
                String errorLocation = error.getUriToProblem().toString();
                if (errorLocation.contains("#")) {
                    errorLocation = errorLocation.split("#")[0];
                }
                sb.append(" in " + errorLocation);
                if (error.getLineNumber() != null && error.getLineNumber() > 0) {
                    sb.append(" at [" + error.getLineNumber() + ", " + error.getColumn() +  "]\n");
                }
                StringBuilder line = new StringBuilder();
                for (INode x : parseResult.getRootNode().getLeafNodes()) {
                    if (x.getStartLine() == error.getLineNumber()) {
                        line.append(x.getText());
                    }
                }
                sb.append("\t" + line);
                sb.append("\t" + (" ".repeat(error.getColumn() - 2)) + ("^".repeat(error.getColumnEnd() - error.getColumn())));
                sb.append("\n\n");
            }

        });
        return sb.toString();
    }
}
