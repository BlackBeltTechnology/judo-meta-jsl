package hu.blackbelt.judo.meta.jsl.ui.preview;

import hu.blackbelt.judo.meta.jsl.generator.JsldslDefaultPlantUMLDiagramGenerator;
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration;
import net.sourceforge.plantuml.text.AbstractDiagramIntent;

public class JslDslDiagramIntent extends AbstractDiagramIntent<ModelDeclaration> {

    private JsldslDefaultPlantUMLDiagramGenerator generator;

	public JslDslDiagramIntent(JsldslDefaultPlantUMLDiagramGenerator generator, ModelDeclaration source) {
		super(source);
		this.generator = generator;
	}

	public JslDslDiagramIntent(JsldslDefaultPlantUMLDiagramGenerator generator, ModelDeclaration source, String label) {
		super(source, label);
		this.generator = generator;
	}
	
	@Override
	public String getDiagramText() {
		try {
			return String.valueOf(generator.generate(this.getSource(), null));
		} catch (Exception e) {
			e.printStackTrace(System.err);
		}
		return null;
	}

}
