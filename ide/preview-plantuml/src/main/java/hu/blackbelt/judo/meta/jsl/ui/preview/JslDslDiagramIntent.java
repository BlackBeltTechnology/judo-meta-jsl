package hu.blackbelt.judo.meta.jsl.ui.preview;

import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration;
import hu.blackbelt.judo.meta.jsl.runtime.JslParser;
import net.sourceforge.plantuml.text.AbstractDiagramIntent;

public class JslDslDiagramIntent extends AbstractDiagramIntent<ModelDeclaration> {

    private JslParser parser;

	public JslDslDiagramIntent(JslParser parser, ModelDeclaration source) {
		super(source);
		this.parser = parser;
	}

	public JslDslDiagramIntent(JslParser parser, ModelDeclaration source, String label) {
		super(source, label);
		this.parser = parser;
	}
	
	@Override
	public String getDiagramText() {
		return String.valueOf(parser.getDefaultPlantUMLDiagramGenerator().generate(this.getSource(), null));
	}

}
