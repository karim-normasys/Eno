package fr.insee.eno.generation;

import java.io.File;

import org.apache.commons.io.FilenameUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import fr.insee.eno.transform.xsl.XslParameters;
import fr.insee.eno.transform.xsl.XslTransformation;
import fr.insee.eno.Constants;

public class DDI2FRGenerator implements Generator {
	
	private static final Logger logger = LogManager.getLogger(DDI2FRGenerator.class);
	
	// FIXME Inject !
	private static XslTransformation saxonService = new XslTransformation();

	@Override
	public File generate(String finalInput, String surveyName) throws Exception {
		logger.debug("DDI2FR Target : START");
		logger.debug("Arguments : finalInput : " + finalInput + " surveyName " + surveyName);
		String formNameFolder = null;
		String outputBasicForm = null;

		File f = new File(finalInput);

		formNameFolder = FilenameUtils.getBaseName(f.getAbsolutePath());
		formNameFolder = FilenameUtils.removeExtension(formNameFolder);
		formNameFolder = formNameFolder.replace(XslParameters.TITLED_EXTENSION, "");

		logger.debug("formNameFolder : " + formNameFolder);

		outputBasicForm = Constants.TEMP_XFORMS_FOLDER + "/" + formNameFolder + "/" + Constants.BASIC_FORM_TMP_FILENAME;
		logger.debug("Output folder for basic-form : " + outputBasicForm);

		logger.debug("Ddi2fr part 1 : from -final to basic-form");
		logger.debug("-Input : " + finalInput + " -Output : " + outputBasicForm + " -Stylesheet : "
				+ Constants.TRANSFORMATIONS_DDI2FR_DDI2FR_XSL);
		logger.debug("-Parameters : " + surveyName + " | " + formNameFolder + " | " + Constants.PROPERTIES_FILE);
		saxonService.transformDdi2frBasicForm(finalInput, Constants.TRANSFORMATIONS_DDI2FR_DDI2FR_XSL, outputBasicForm,
				surveyName, formNameFolder, Constants.PROPERTIES_FILE);

		String outputForm = Constants.TARGET_FOLDER + "/" + surveyName + "/" + formNameFolder + "/form/form.xhtml";

		logger.debug("Ddi2fr part 2 : from basic-form to form.xhtml");
		logger.debug("-Input : " + outputBasicForm + " -Output : " + outputForm + " -Stylesheet : "
				+ Constants.BROWSING_TEMPLATE_XSL);
		logger.debug("-Parameters : " + surveyName + " | " + formNameFolder + " | " + Constants.PROPERTIES_FILE);
		saxonService.transformDdi2frBasicForm(outputBasicForm, Constants.BROWSING_TEMPLATE_XSL, outputForm, surveyName,
				formNameFolder, Constants.PROPERTIES_FILE);

		return new File(outputForm);
	}

}