package hu.blackbelt.judo.meta.jsl.generator.engine;

/*-
 * #%L
 * JUDO Generator commons
 * %%
 * Copyright (C) 2018 - 2023 BlackBelt Technology
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

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;
import org.slf4j.Logger;

import java.util.Map;
import java.util.Set;

public enum LogLevel {
    ERROR, WARN, INFO, DEBUG, TRACE;

    private static Map<LogLevel, Set<LogLevel>> logLevelSetMap = ImmutableMap.<LogLevel, Set<LogLevel>>builder()
            .put(LogLevel.ERROR, ImmutableSet.of(LogLevel.ERROR))
            .put(LogLevel.WARN, ImmutableSet.of(LogLevel.ERROR, LogLevel.WARN))
            .put(LogLevel.INFO, ImmutableSet.of(LogLevel.ERROR, LogLevel.WARN, LogLevel.INFO))
            .put(LogLevel.DEBUG, ImmutableSet.of(LogLevel.ERROR, LogLevel.WARN, LogLevel.INFO, LogLevel.DEBUG))
            .put(LogLevel.TRACE, ImmutableSet.of(LogLevel.ERROR, LogLevel.WARN, LogLevel.INFO, LogLevel.DEBUG, LogLevel.TRACE))
            .build();

    public static Set<LogLevel> getMatchingLogLevels(LogLevel logLevel) {
        return logLevelSetMap.get(logLevel);
    }

    public static LogLevel determinateLogLevel(Logger log) {
        if (log.isTraceEnabled()) {
            return  LogLevel.TRACE;
        } else if (log.isDebugEnabled()) {
            return  LogLevel.DEBUG;
        } else if (log.isInfoEnabled()) {
            return  LogLevel.INFO;
        } else if (log.isWarnEnabled()) {
            return LogLevel.WARN;
        } else if (log.isErrorEnabled()) {
            return LogLevel.ERROR;
        }
        return  LogLevel.INFO;
    }
}
