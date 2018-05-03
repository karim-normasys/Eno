package fr.insee.eno;

import com.google.inject.AbstractModule;

import fr.insee.eno.generation.DDI2ODTGenerator;
import fr.insee.eno.generation.Generator;
import fr.insee.eno.postprocessing.NoopPostprocessor;
import fr.insee.eno.postprocessing.Postprocessor;
import fr.insee.eno.preprocessing.DDIPreprocessor;
import fr.insee.eno.preprocessing.Preprocessor;

/**
 * Defines the context on the generation, i.e. which processors and generator to
 * use for DDI to ODT generation.
 */
public class DDI2ODTContext extends AbstractModule {

	@Override
	protected void configure() {
		bind(Preprocessor.class).to(DDIPreprocessor.class);
		bind(Generator.class).to(DDI2ODTGenerator.class);
		bind(Postprocessor.class).to(NoopPostprocessor.class);
	}

}
