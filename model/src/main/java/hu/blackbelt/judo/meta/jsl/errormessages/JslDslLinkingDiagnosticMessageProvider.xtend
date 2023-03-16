package hu.blackbelt.judo.meta.jsl.errormessages

import org.eclipse.xtext.linking.impl.LinkingDiagnosticMessageProvider
import org.eclipse.xtext.diagnostics.DiagnosticMessage

class JslDslLinkingDiagnosticMessageProvider extends LinkingDiagnosticMessageProvider {

    override DiagnosticMessage getUnresolvedProxyMessage(ILinkingDiagnosticContext context) {
        val DiagnosticMessage diagnostic = super.getUnresolvedProxyMessage(context)
        return diagnostic
    }
}