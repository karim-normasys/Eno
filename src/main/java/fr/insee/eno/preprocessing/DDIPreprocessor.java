package fr.insee.eno.preprocessing;

import java.io.File;
import java.io.FilenameFilter;
import java.io.InputStream;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import fr.insee.eno.Constants;
import fr.insee.eno.transform.xsl.XslTransformation;

/**
 * A DDI specific preprocessor.
 */
public class DDIPreprocessor implements Preprocessor {

	private static final Logger logger = LogManager.getLogger(DDIPreprocessor.class);

	// FIXME Inject !
	private static XslTransformation saxonService = new XslTransformation();

	@Override
	public File process(File inputFile, File parametersFile) throws Exception {
		logger.info("DDIPreprocessing Target : START");
		
		// ----- Dereferencing
		logger.debug(
				"Dereferencing : -Input : " + inputFile + " -Output : " + Constants.TEMP_NULL_TMP + " -Stylesheet : "
						+ Constants.UTIL_DDI_DEREFERENCING_XSL + " -Parameters : " + Constants.SUB_TEMP_FOLDER);
		
		saxonService.transformDereferencing(
				FileUtils.openInputStream(inputFile), 
				Constants.DDI_DEREFERENCING_XSL,
				FileUtils.openOutputStream(Constants.TEMP_NULL_TMP),
				Constants.SUB_TEMP_FOLDER); //FIXME 4th param should be a parameters file (?!!?).

		// ----- Cleaning
		logger.debug("Cleaning target");
		File f = Constants.SUB_TEMP_FOLDER;
		File[] matchCleaningInput = f.listFiles(new FilenameFilter() {

			@Override
			public boolean accept(File dir, String name) {
				return !name.startsWith("null");
			}
		});
		String cleaningInput = null;
		String cleaningOutput = null;

		logger.debug("Searching matching files in : " + Constants.SUB_TEMP_FOLDER);
		for (File file : matchCleaningInput) {
			cleaningInput = file.getAbsolutePath();
			logger.debug("Found : " + cleaningInput);
		}

		cleaningOutput = FilenameUtils.removeExtension(cleaningInput) + Constants.CLEANED_EXTENSION;
		logger.debug("Cleaned output file to be created : " + cleaningOutput);
		logger.debug("Cleaning : -Input : " + cleaningInput + " -Output : " + cleaningOutput + " -Stylesheet : "
				+ Constants.UTIL_DDI_CLEANING_XSL);
		saxonService.transform(
				FileUtils.openInputStream(new File(cleaningInput)),
				Constants.UTIL_DDI_CLEANING_XSL, 
				FileUtils.openOutputStream(new File(cleaningOutput)));

		// ----- Titling
		// titlinginput = cleaningoutput

		String outputTitling = null;

		InputStream parametersFileStream;
		// If no parameters file was provided : loading the default one
		// Else : using the provided one
		if (parametersFile == null) {
			logger.debug("Using default parameters");
			parametersFileStream = Constants.PARAMETERS_FILE;			
		} else {
			logger.debug("Using provided parameters");
			parametersFileStream = FileUtils.openInputStream(parametersFile);
		}

		outputTitling = FilenameUtils.removeExtension(cleaningInput) + Constants.FINAL_EXTENSION;

		logger.debug("Titling : -Input : " + cleaningOutput + " -Output : " + outputTitling + " -Stylesheet : "
				+ Constants.UTIL_DDI_TITLING_XSL + " -Parameters : " + (parametersFile == null ? "Default parameters": "Provided parameters"));
		saxonService.transformTitling(
				FileUtils.openInputStream(new File(cleaningOutput)),
				Constants.UTIL_DDI_TITLING_XSL,
				FileUtils.openOutputStream(new File(outputTitling)),
				parametersFileStream);

		logger.debug("DDIPreprocessing : END");
		return new File(outputTitling);
	}

}
