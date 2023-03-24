package hu.blackbelt.judo.meta.jsl.scoping

import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.xtext.naming.QualifiedName

class JslDslImportNormalizer extends ImportNormalizer {
    String alias = null;

    new(String alias, QualifiedName importedNamespace, boolean wildCard, boolean ignoreCase) {
        super(importedNamespace, wildCard, ignoreCase)

        this.alias = alias;
    }

    override deresolve(QualifiedName fullyQualifiedName) {
        if (fullyQualifiedName.empty || fullyQualifiedName.segmentCount != importedNamespacePrefix.segmentCount + 1) return null;

        if (fullyQualifiedName.startsWith(importedNamespacePrefix)) {
            return fullyQualifiedName.skipFirst(importedNamespacePrefix.getSegmentCount());
        }

        return null;
    }

    override QualifiedName resolve(QualifiedName relativeName) {
        if (relativeName.empty) return null;

        if (alias === null) {
            return importedNamespacePrefix.append(relativeName);
        } else {
            if (relativeName.segmentCount == 2) {
                if (relativeName.segments.get(0).equals(alias)) {
                    return importedNamespacePrefix.append(relativeName.skipFirst(1));
                }
            }
        }

        return null;
    }
}
