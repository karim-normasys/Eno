<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:fn="http://www.w3.org/2005/xpath-functions" 
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
	xmlns:eno="http://xml.insee.fr/apps/eno" 
	xmlns:enoodt="http://xml.insee.fr/apps/eno/out/odt" 
	xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" 
	xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" 
	xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" 
	xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
	xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" 
	xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" 
	exclude-result-prefixes="xs fn xd eno enoodt" version="2.0">
	
	<xsl:import href="../../../styles/style.xsl"/>
	
	<xsl:param name="properties-file"/>
	<xsl:param name="parameters-file"/>
	<xsl:param name="labels-folder"/>
	
	<xsl:variable name="properties" select="doc($properties-file)"/>
	
	<xsl:variable name="header-content" select="doc($properties//HeaderFile)"/>
	
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p>An xslt stylesheet who transforms an input into Odt through generic driver templates.</xd:p>
			<xd:p>The real input is mapped with the drivers.</xd:p>
		</xd:desc>
	</xd:doc>
	
	
	<xsl:variable name="varName" select="parent"/>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Forces the traversal of the whole driver tree. Must be present once in the transformation.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="*" mode="model" priority="-1">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
			<xsl:with-param name="driver" select="." tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Match on Form driver.</xd:p>
			<xd:p>It writes the root of the document with the main title.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="Form" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:variable name="languages" select="enoodt:get-form-languages($source-context)" as="xs:string +"/>
		
		<office:document office:version="1.2" office:mimetype="application/vnd.oasis.opendocument.text"
			xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" 
			xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0">
			<office:font-face-decls>
				<style:font-face style:name="Arial" svg:font-family="Arial" style:font-family-generic="system" style:font-pitch="variable"/>
			</office:font-face-decls>
			
			<office:styles>
				<style:style style:name="Standard" style:family="paragraph" style:class="text"/>
				<style:style style:name="Title" style:family="paragraph" style:class="chapter">
					<style:paragraph-properties fo:text-align="center" fo:margin-top="3cm"
						style:justify-single-word="false"/>
					<style:text-properties fo:font-size="36pt" fo:font-weight="bold" fo:color="#7b7c7c"/>
				</style:style>
				<style:style style:name="TitleComment" style:family="paragraph">
					<style:paragraph-properties fo:text-align="center" fo:margin-top="3cm"
						style:justify-single-word="false"/>
					<style:text-properties fo:font-size="22pt" fo:font-weight="bold"/>
				</style:style>
				<style:style style:name="Module" style:family="paragraph" style:default-outline-level="1"
					style:class="text">
					<style:paragraph-properties fo:text-align="center" fo:break-before="page"/>
					<style:text-properties fo:font-size="14pt" fo:font-weight="bold"/>
				</style:style>
				<style:style style:name="SubModule" style:family="paragraph" style:default-outline-level="2"
					style:class="text">
					<style:paragraph-properties fo:margin-top="0.6cm" fo:text-align="left"/>
					<style:text-properties fo:font-size="14pt" fo:font-weight="bold"/>
				</style:style>
				<style:style style:name="QuestionName" style:family="paragraph" style:default-outline-level="2"
					style:class="text">
					<style:paragraph-properties fo:margin-top="0.4cm" fo:text-align="left"/>
					<style:text-properties fo:font-size="10pt" fo:font-style="italic" fo:font-weight="bold"
						fo:color="#a5106c"/>
				</style:style>
				<style:style style:name="Question" style:family="paragraph" style:default-outline-level="2"
					style:class="text">
					<style:paragraph-properties fo:margin-top="0.1cm" fo:text-align="left"/>
					<style:text-properties fo:font-size="10pt"/>
				</style:style>
				<style:style style:name="Format" style:family="paragraph" style:default-outline-level="2"
					style:class="text">
					<style:paragraph-properties fo:text-align="left"/>
					<style:text-properties fo:font-size="10pt"/>
				</style:style>
				<!-- <style:style style:name="QuestionSelect" style:family="paragraph"
					style:default-outline-level="2" style:class="text">
					<style:paragraph-properties fo:text-align="left"/>
					<style:text-properties fo:font-size="10pt" fo:font-weight="bold"/>
					</style:style> -->
				<style:style style:name="Comment" style:family="paragraph" style:default-outline-level="2"
					style:class="text">
					<style:paragraph-properties fo:margin-top="0.1cm" fo:text-align="left"/>
					<style:text-properties fo:font-size="10pt" fo:color="#006600"/>
				</style:style>
				<style:style style:name="Help" style:family="paragraph" style:default-outline-level="2"
					style:class="text">
					<style:paragraph-properties fo:margin-top="0.1cm" fo:text-align="left"/>
					<style:text-properties fo:font-size="10pt" fo:color="#0000ff" style:text-underline-style="solid"
					/>
				</style:style>
				<style:style style:name="Instruction" style:family="paragraph" style:default-outline-level="2"
					style:class="text">
					<style:paragraph-properties fo:margin-top="0.1cm" fo:text-align="left"/>
					<style:text-properties fo:font-size="10pt" fo:color="#0000ff"/>
				</style:style>
				<style:style style:name="Warning" style:family="paragraph" style:default-outline-level="2"
					style:class="text">
					<style:paragraph-properties fo:text-align="left" fo:border="0.05pt solid #000000"
						fo:margin-top="0.1cm"/>
					<style:text-properties fo:font-size="10pt" fo:font-weight="bold" fo:color="#ff3333"/>
				</style:style>
				<style:style style:name="CodeItem" style:family="paragraph" style:default-outline-level="2"
					style:class="text">
					<style:paragraph-properties fo:text-align="left" fo:margin-left="1cm" fo:margin-top="0.1cm"/>
					<style:text-properties fo:font-size="10pt"/>
				</style:style>
				<style:style style:name="CalculatedVariableTitle" style:family="paragraph"
					style:default-outline-level="2" style:class="text">
					<style:paragraph-properties fo:text-align="left" fo:margin-top="0.7cm"/>
					<style:text-properties fo:font-size="10pt" fo:font-weight="bold"/>
				</style:style>
				<style:style style:name="CalculatedVariableContent" style:family="paragraph"
					style:default-outline-level="2" style:class="text">
					<style:paragraph-properties fo:text-align="left" fo:margin-top="0.3cm"/>
					<style:text-properties fo:font-size="10pt"/>
				</style:style>
				<style:style style:name="Control" style:family="paragraph" style:default-outline-level="2"
					style:class="text">
					<style:paragraph-properties fo:text-align="left" fo:margin-top="0.7cm"
						fo:border="0.05pt solid #000000"/>
					<style:text-properties fo:font-size="10pt" fo:font-weight="bold" fo:color="#0000ff"/>
				</style:style>
				<style:style style:name="MultipleChoice" style:family="table">
					<style:table-properties fo:break-before="page"/>
				</style:style>
				<style:style style:name="MultipleChoice.Column" style:family="table-column"> </style:style>
				<style:style style:name="MultipleChoice.Cell" style:family="table-cell"> </style:style>
				<style:style style:name="Table" style:family="table">
					<style:table-properties fo:margin-top="1cm"/>
				</style:style>
				<style:style style:name="Table.Column" style:family="table-column"> </style:style>
				<style:style style:name="Table.Cell" style:family="table-cell"> </style:style>
				<style:style style:name="ColumnHeader" style:family="paragraph" style:default-outline-level="2"
					style:class="text">
					<style:paragraph-properties fo:text-align="center"/>
					<style:text-properties fo:font-size="10pt" fo:font-weight="bold"/>
				</style:style>
			</office:styles>
			
			
			<!--
				<xsl:copy-of select="$header-content/office:document/@*"/>
				<xsl:copy-of select="$header-content/office:document/node()[not(name()='office:body')]"/>
			-->
			<office:body>
				<office:text>
					<text:p text:style-name="Title"><xsl:value-of select="enoodt:get-label($source-context, $languages[1])"/></text:p>
					<text:p text:style-name="TitleComment">
						<!--  <xsl:value-of select="concat('Specification generated on: ',format-dateTime(current-dateTime(), '[D01]/[M01]/[Y0001] - [H1]:[m01]:[s01]'))"/>-->
						Specification generated from Eno
					</text:p>
					<!-- Go to the children -->
					<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
						<xsl:with-param name="driver" select="." tunnel="yes"/>
					</xsl:apply-templates>
				</office:text>
			</office:body>
		</office:document>
	</xsl:template>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Match on Module driver.</xd:p>
			<xd:p>It writes module label.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="Module" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:variable name="languages" select="enoodt:get-form-languages($source-context)" as="xs:string +"/>
		
		<text:p text:style-name="Module"><xsl:value-of select="enoodt:get-label($source-context, $languages[1])"/></text:p>
		
		<!-- Go to the children -->
		<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
			<xsl:with-param name="driver" select="." tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Match on SubModule driver.</xd:p>
			<xd:p>It writes sub-module label.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="SubModule" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:variable name="languages" select="enoodt:get-form-languages($source-context)" as="xs:string +"/>
		
		<text:p text:style-name="SubModule"><xsl:value-of select="enoodt:get-label($source-context, $languages[1])"/></text:p>
		
		<!-- Go to the children -->
		<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
			<xsl:with-param name="driver" select="." tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Match on xf-input driver.</xd:p>
			<xd:p>It writes the short name, the label and its response format of a question.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="xf-input" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:variable name="languages" select="enoodt:get-form-languages($source-context)" as="xs:string +"/>
		<xsl:variable name="typeResponse" select="enoodt:get-type($source-context)"/>
		<xsl:variable name="lengthResponse" select="enoodt:get-length($source-context)"/>
		<xsl:variable name="numberOfDecimals" select="enoodt:get-number-of-decimals($source-context)"/>
		<xsl:variable name="minimumResponse" select="enoodt:get-minimum($source-context)"/>
		<xsl:variable name="maximumResponse" select="enoodt:get-maximum($source-context)"/>
		<xsl:variable name="questionName" select="enoodt:get-question-name($source-context)"/>
		<xsl:variable name="questionLabel" select="enoodt:get-label($source-context, $languages[1])"/>
		
		<xsl:if test="$questionName != ''">
			<text:p text:style-name="QuestionName">
				<xsl:value-of select="concat('[',$questionName,']')"/>
			</text:p>
		</xsl:if>
		<xsl:if test="$typeResponse!=''">
			<text:p text:style-name="Format">
				<xsl:choose>
					<xsl:when test="$typeResponse='text'">
						<xsl:value-of select="concat('Car ',$lengthResponse)"/>
					</xsl:when>
					<xsl:when test="$typeResponse='number' and fn:string-length($numberOfDecimals)>0">
						<xsl:value-of select="concat('num ',fn:substring-before($minimumResponse,'.'),'..',fn:substring-before($maximumResponse,'.'),' - ',$numberOfDecimals,' chiffre(s) après la virgule')"/>
					</xsl:when>
					<xsl:when test="$typeResponse='number' and fn:string-length($numberOfDecimals)=0">
						<xsl:value-of select="concat('num ',$minimumResponse,'..',$maximumResponse)"/>
					</xsl:when>
					<xsl:when test="$typeResponse='date'">
						<xsl:value-of select="$typeResponse"/>
					</xsl:when>
					<xsl:when test="$typeResponse='boolean'">
						<xsl:value-of select="'Booléen'"/>
					</xsl:when>
				</xsl:choose>
			</text:p>
		</xsl:if>		
		<xsl:if test="$questionLabel!=''">
			<text:p text:style-name="Question"><xsl:value-of select="$questionLabel"/></text:p>
		</xsl:if>
			
		
		<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
			<xsl:with-param name="driver" select="." tunnel="yes"/>
		</xsl:apply-templates>
		
	</xsl:template>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Match on xf-textarea driver.</xd:p>
			<xd:p>It writes the short name, the label and its response format of a question.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="xf-textarea" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:variable name="languages" select="enoodt:get-form-languages($source-context)" as="xs:string +"/>
		<xsl:variable name="typeResponse" select="enoodt:get-type($source-context)"/>
		<xsl:variable name="format" select="enoodt:get-format($source-context)"/>
		<xsl:variable name="lengthResponse" select="enoodt:get-length($source-context)"/>
		<xsl:variable name="numberOfDecimals" select="enoodt:get-number-of-decimals($source-context)"/>
		<xsl:variable name="minimumResponse" select="enoodt:get-minimum($source-context)"/>
		<xsl:variable name="maximumResponse" select="enoodt:get-maximum($source-context)"/>
		<xsl:variable name="questionName" select="enoodt:get-question-name($source-context)"/>
		<xsl:variable name="questionLabel" select="enoodt:get-label($source-context, $languages[1])"/>
		<xsl:if test="$questionName !=''">
			<text:p text:style-name="QuestionName">
				<xsl:value-of select="concat('[',$questionName,']')"/>
			</text:p>
		</xsl:if>
		<xsl:if test="$typeResponse !=''">
			<text:p text:style-name="Format">
				<xsl:choose>
					<xsl:when test="$typeResponse='text'">
						<xsl:value-of select="concat('Car ',$lengthResponse)"/>
					</xsl:when>
					<xsl:when test="$typeResponse='date'">
						<xsl:value-of select="$typeResponse"/>
					</xsl:when>
					<xsl:when test="$typeResponse='number' and fn:string-length($numberOfDecimals)=0">
						<xsl:value-of select="concat('num ',$minimumResponse,'..',$maximumResponse)"/>
					</xsl:when>
					<xsl:when test="$typeResponse='number' and fn:string-length($numberOfDecimals)>0">
						<xsl:value-of select="concat('num ',fn:substring-before($minimumResponse,'.'),'..',fn:substring-before($maximumResponse,'.'),' - ',$numberOfDecimals,' chiffre(s) après la virgule')"/>
					</xsl:when>
				</xsl:choose>
			</text:p>
		</xsl:if>
		<xsl:if test="$questionLabel!=''">
			<text:p text:style-name="Question"><xsl:value-of select="$questionLabel"/></text:p>
		</xsl:if>

		
		<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
			<xsl:with-param name="driver" select="." tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Match on xf-select driver.</xd:p>
			<xd:p>It writes the short name, the label and its response format of a question.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="xf-select " mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:param name="typeOfAncestor" tunnel="yes"/>		
		<xsl:variable name="languages" select="enoodt:get-form-languages($source-context)" as="xs:string +"/>
		<xsl:variable name="typeResponse" select="enoodt:get-type($source-context)"/>
		<xsl:variable name="idQuestion" select="enoodt:get-name($source-context)"/>
		<xsl:variable name="questionName" select="enoodt:get-question-name($source-context)"/>
		<xsl:variable name="maximumLengthCode" select="enoodt:get-code-maximum-length($source-context)"/>
		<xsl:variable name="questionLabel" select="enoodt:get-label($source-context, $languages[1])"/>
		
		<xsl:if test="$questionName != ''">
			<text:p text:style-name="QuestionName">
				<xsl:value-of select="concat('[',$questionName,']')"/>
			</text:p>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$maximumLengthCode != ''">
				<!-- remove Format in the cell for table 'question multiple-choice-question'-->
				<xsl:if test="$typeOfAncestor!='question multiple-choice-question'">
					<text:p text:style-name="Format">
						<xsl:value-of select="concat('Car ',$maximumLengthCode,' - ','liste de modalités')"/>
					</text:p>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$typeResponse='boolean' and ($typeOfAncestor!='' or $questionName!='')">
				<text:p text:style-name="Format"><xsl:value-of select="'Booléen'"/></text:p>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="$questionLabel!=''">
			<text:p text:style-name="Question"><xsl:value-of select="enoodt:get-label($source-context, $languages[1])"/></text:p>
		</xsl:if>		
		<!-- Go to the children -->
		<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
			<xsl:with-param name="driver" select="." tunnel="yes"/>
			<xsl:with-param name="typeResponse" select="$typeResponse" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Match on xf-select1 driver.</xd:p>
			<xd:p>It writes the short name, the label and its response format of a question.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="xf-select1" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:param name="typeOfAncestor" tunnel="yes"/>
		
		<xsl:variable name="languages" select="enoodt:get-form-languages($source-context)" as="xs:string +"/>
		<xsl:variable name="typeResponse" select="enoodt:get-type($source-context)"/>
		<xsl:variable name="lengthResponse" select="enoodt:get-length($source-context)"/>
		<xsl:variable name="questionName" select="enoodt:get-question-name($source-context)"/>
		<xsl:variable name="maximumLengthCode" select="enoodt:get-code-maximum-length($source-context)"/>
		<xsl:variable name="questionLabel" select="enoodt:get-label($source-context, $languages[1])"/>

		<xsl:if test="$questionName != ''">
			<text:p text:style-name="QuestionName">
				<xsl:value-of select="concat('[',$questionName,']')"/>
			</text:p>
		</xsl:if>
		
		<xsl:choose>
			<xsl:when test="$maximumLengthCode != ''">
				<xsl:if test="$typeOfAncestor!='question multiple-choice-question'">
					<text:p text:style-name="Format">
						<xsl:value-of select="concat('Car ',$maximumLengthCode,' - ','liste de modalités')"/>
					</text:p>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<text:p text:style-name="Format"><xsl:value-of select="'Booléen'"/></text:p>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$questionLabel!=''">
			<text:p text:style-name="QuestionSelect"><xsl:value-of select="$questionLabel"/></text:p>
		</xsl:if>
		
		<!-- Go to the children -->
		<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
			<xsl:with-param name="driver" select="." tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Match on the Table driver and TableLoop driver.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="Table | TableLoop" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:variable name="languages" select="enoodt:get-form-languages($source-context)" as="xs:string +"/>
		<xsl:variable name="ancestors">
			<xsl:copy-of select="root(.)"/>
		</xsl:variable>
		<xsl:variable name="questionName" select="enoodt:get-question-name($source-context)"/>
		<xsl:variable name="maximumLengthCode" select="enoodt:get-code-maximum-length($source-context)"/>
		<xsl:variable name="nbLine" select="count(enoodt:get-body-lines($source-context))"/>
		<xsl:variable name="headerCol" select="enoodt:get-body-line($source-context,position())"/>
		<xsl:variable name="type" select="enoodt:get-css-class($source-context)"/>
		
		<xsl:if test="$questionName != ''">
			<text:p text:style-name="QuestionName">
				<xsl:value-of select="concat('[',$questionName,']')"/>
			</text:p>
		</xsl:if>
		<xsl:if test="$type='question multiple-choice-question'">
			<text:p>
				<xsl:value-of select="concat('Car ',$maximumLengthCode)"/>
			</text:p>
		</xsl:if>
		
		<text:p text:style-name="Question"><xsl:value-of select="enoodt:get-label($source-context, $languages[1])"/></text:p>
				
		<table:table table:name="{enoodt:get-name($source-context)}">
			<xsl:for-each select="$headerCol">
				<table:table-column/>
			</xsl:for-each>
			<!--    Header   -->
			<xsl:for-each select="enoodt:get-header-lines($source-context)">
				<table:table-row>		
					<xsl:apply-templates 
						select="enoodt:get-header-line($source-context,position())" mode="source">
						<xsl:with-param name="ancestorTable" select="'headerLine'" tunnel="yes"/>
					</xsl:apply-templates>
				</table:table-row>
			</xsl:for-each>			
			<!--   Body    -->
			<xsl:for-each select="enoodt:get-body-lines($source-context)">
				<table:table-row>
					<xsl:apply-templates
						select="enoodt:get-body-line($source-context, position())" mode="source">
						<xsl:with-param name="ancestorTable" select="'line'" tunnel="yes"/>
						<xsl:with-param name="typeOfAncestor" select="$type" tunnel="yes"/>
					</xsl:apply-templates>
				</table:table-row>
			</xsl:for-each>
		</table:table>
		
		<xsl:variable name="nbMaximumLines" select="enoodt:get-maximum-lines($source-context)"/>
		<xsl:variable name="nbMinimumLines" select="enoodt:get-minimum-lines($source-context)"/>
		<xsl:if test="$nbMinimumLines!=''">
			<text:p><xsl:value-of select="concat('Nb line(s) minimum required : ',$nbMinimumLines)"/></text:p>
		</xsl:if>
		<xsl:if test="$nbMaximumLines!=''">
			<text:p><xsl:value-of select="concat('Nb line(s) maximum allowed : ',$nbMaximumLines)"/></text:p>
		</xsl:if>		
		
		<!-- Go to the children -->
		<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
			<xsl:with-param name="driver" select="." tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Match on the TextCell driver.</xd:p>
			<xd:p>It displays the headers on the top and the left.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="TextCell" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:param name="ancestorTable" tunnel="yes"/>
		<xsl:variable name="languages" select="enoodt:get-form-languages($source-context)" as="xs:string +"/>
		<xsl:variable name="col-span" select="number(enoodt:get-colspan($source-context))"/>
		<xsl:variable name="row-span" select="number(enoodt:get-rowspan($source-context))"/>
		
		<xsl:choose>
			<xsl:when test="$ancestorTable!=''">
				<table:table-cell table:number-rows-spanned="{$row-span}" 
					table:number-columns-spanned="{$col-span}">
					<xsl:variable name="label" select="enoodt:get-label($source-context,$languages)"/>
					<xsl:choose>
						<xsl:when test="$label!='' and $ancestorTable='line'">
							<text:p text:style-name="Question"><xsl:value-of select="$label"/></text:p>
						</xsl:when>
						<xsl:when test="$label!='' and $ancestorTable='headerLine'">
							<text:p text:style-name="ColumnHeader"><xsl:value-of select="$label"/></text:p>
						</xsl:when>
					</xsl:choose>
				</table:table-cell>
				
				<!-- To add spanned rows / columns -->
				<xsl:if test="$row-span &gt;1">
					<xsl:for-each select="2 to xs:integer(floor($row-span))">
						<table:covered-table-cell/>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="$col-span &gt;1">
					<xsl:for-each select="2 to xs:integer(floor($col-span))">
						<table:covered-table-cell/>
					</xsl:for-each>
				</xsl:if>
				
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="label" select="enoodt:get-label($source-context,$languages)"/>
				<xsl:if test="$label!='' and $ancestorTable='no'">
					<text:p text:style-name="CodeItem">
						<xsl:value-of select="fn:concat(enoodt:get-value($source-context), ' - ', $label)"/>
					</text:p>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Match on the Cell driver.</xd:p>
			<xd:p>Create a cell and call templates for children to fill the cell.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="Cell" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:param name="ancestorTable" tunnel="yes"/>
		<xsl:variable name="languages" select="enoodt:get-form-languages($source-context)" as="xs:string +"/>
		<xsl:variable name="col-span" select="number(enoodt:get-colspan($source-context))"/>
		<xsl:variable name="row-span" select="number(enoodt:get-rowspan($source-context))"/>
		<xsl:if test="$ancestorTable!=''">
			<table:table-cell table:number-rows-spanned="{$row-span}" 
				table:number-columns-spanned="{$col-span}">
				<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
					<xsl:with-param name="driver" select="." tunnel="yes"/>
				</xsl:apply-templates>
			</table:table-cell>
				
			<!-- To add spanned rows / columns -->
			<xsl:if test="$row-span &gt;1">
				<xsl:for-each select="2 to xs:integer(floor($row-span))">
					<table:covered-table-cell/>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="$col-span &gt;1">
				<xsl:for-each select="2 to xs:integer(floor($col-span))">
					<table:covered-table-cell/>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>	
	</xsl:template>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Match on the EmptyCell driver.</xd:p>
			<xd:p>Create a cell and call templates for children to fill the cell (a priori nothing).</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="EmptyCell" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:param name="ancestorTable" tunnel="yes"/>
		<xsl:variable name="languages" select="enoodt:get-form-languages($source-context)" as="xs:string +"/>
		<xsl:variable name="col-span" select="number(enoodt:get-colspan($source-context))"/>
		<xsl:variable name="row-span" select="number(enoodt:get-rowspan($source-context))"/>
		<xsl:if test="$ancestorTable!=''">
			<table:table-cell table:number-rows-spanned="{$row-span}" 
				table:number-columns-spanned="{$col-span}">
				<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
					<xsl:with-param name="driver" select="." tunnel="yes"/>
				</xsl:apply-templates>
			</table:table-cell>
			
			<!-- To add spanned rows / columns -->
			<xsl:if test="$row-span &gt;1">
				<xsl:for-each select="2 to xs:integer(floor($row-span))">
					<table:covered-table-cell/>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="$col-span &gt;1">
				<xsl:for-each select="2 to xs:integer(floor($col-span))">
					<table:covered-table-cell/>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Match on the xf-item driver.</xd:p>
			<xd:p>It writes the code value and the label of the item.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="xf-item" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:param name="ancestorTable" tunnel="yes"/>
		<xsl:param name="typeResponse" tunnel="yes"/>
		<xsl:variable name="languages" select="enoodt:get-form-languages($source-context)" as="xs:string +"/>
		<xsl:variable name="label" select="enoodt:get-label($source-context, $languages[1])"/>
		
		<!-- remove item in the cell for table when the response is boolean-->
		<xsl:if test="$label !='' and $typeResponse!='boolean'">
			<text:p text:style-name="CodeItem">
				<xsl:value-of select="fn:concat(enoodt:get-value($source-context), ' - ', $label)"/>
			</text:p>
		</xsl:if>
			
		<!-- Got to the children -->
		<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
			<xsl:with-param name="driver" select="." tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Match on the xf-output driver.</xd:p>
			<xd:p>It writes the instruction text, with a different styles for comments, instructions, warning and help.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="xf-output" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:variable name="languages" select="enoodt:get-form-languages($source-context)" as="xs:string +"/>
		<xsl:variable name="instructionFormat" select="enoodt:get-format($source-context)"/>
		<xsl:variable name="instructionLabel" select="enoodt:get-label($source-context, $languages)"/>
		<xsl:variable name="instructionFormatMaj" select="concat(upper-case(substring($instructionFormat,1,1)),
			substring($instructionFormat,2))" as="xs:string"></xsl:variable>
		<xsl:choose>
			<xsl:when test="$instructionFormat='comment'">
				<text:p text:style-name="Comment"><xsl:value-of select="$instructionLabel"/></text:p>
			</xsl:when>
			<xsl:when test="$instructionFormat='instruction'">
				<text:p text:style-name="Instruction"><xsl:value-of select="$instructionLabel"/></text:p>
			</xsl:when>
			<xsl:when test="$instructionFormat='warning'">
				<text:p text:style-name="Warning"><xsl:value-of select="$instructionLabel"/></text:p>
			</xsl:when>
			<xsl:when test="$instructionFormat='help'">
				<text:p text:style-name="Help"><xsl:value-of select="$instructionLabel"/></text:p>
			</xsl:when>
			<!--<xsl:otherwise>
				<text:p text:style-name="Instruction"><xsl:value-of select="$instructionFormat"/></text:p>
			</xsl:otherwise>-->
		</xsl:choose>
		
		<!-- Go to the children -->
		<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
			<xsl:with-param name="driver" select="." tunnel="yes"/>
		</xsl:apply-templates>
		
	</xsl:template>

	<xd:doc>
		<xd:desc>
			<xd:p>Match on the CalculatedVariable driver.</xd:p>
			<xd:p>Its displays the formula of the calculated variable.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="CalculatedVariable" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:variable name="languages" select="enoodt:get-form-languages($source-context)" as="xs:string +"/>
		<xsl:variable name="variableCalculation" select="enoodt:get-calculate($source-context)"/>
		<xsl:variable name="variableCalculationLabel" select="enoodt:get-calculate-text($source-context,$languages[1],'label')"/>
		<xsl:variable name="variableCalculationAlert" select="enoodt:get-calculate-text($source-context,$languages[1],'alert')"/>
		
		<text:p><xsl:value-of select="$variableCalculation"/></text:p>
		<text:p><xsl:value-of select="$variableCalculationLabel"/></text:p>
		<text:p><xsl:value-of select="$variableCalculationAlert"/></text:p>
		
		<!-- Go to the children -->
		<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
			<xsl:with-param name="driver" select="." tunnel="yes"/>
		</xsl:apply-templates>		
	</xsl:template>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Match on the ConsistencyCheck driver.</xd:p>
			<xd:p>It writes the formula of the check.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="ConsistencyCheck" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:variable name="languages" select="enoodt:get-form-languages($source-context)" as="xs:string +"/>
		<xsl:variable name="name" select="enoodt:get-label-conditioner($source-context,$languages[1])"/>
		<xsl:variable name="nameOfControl" select="enoodt:get-check-name($source-context,$languages)"/>
		<xsl:variable name="control" select="enoodt:get-constraint($source-context)"/>
		<xsl:variable name="instructionFormat" select="enoodt:get-css-class($source-context)"/>
		<xsl:variable name="vars" select="enoodt:get-label-conditioning-variables($source-context,$languages)"/>
		<xsl:variable name="instructionLabel">
			<xsl:call-template name="replaceVariablesInInstruction">
				<xsl:with-param name="instruction" select="enoodt:get-label($source-context, $languages)"/>
				<xsl:with-param name="variables" select="$vars"/>
			</xsl:call-template>	
		</xsl:variable>
		
		<text:p text:style-name="CalculatedVariableTitle"><xsl:value-of select="'Calcul de la variable'"/></text:p>
		<text:p text:style-name="CalculatedVariableContent">
			<xsl:value-of select="'here compute'"/>
		</text:p>
		
		<xsl:if test="$control!=''">
			<text:p text:style-name="Control"><xsl:value-of select="concat('Contrôle bloquant : ',$nameOfControl)"/></text:p>
			<xsl:variable name="idVariables" select="enoodt:get-control-variables($source-context)"/>
			<text:p text:style-name="Control">
				<xsl:value-of select="'Expression du contrôle : '"/>
				<xsl:call-template name="replaceVariablesInFormula">
					<xsl:with-param name="formula" select="$control"/>
					<xsl:with-param name="variables" select="$idVariables"/>
				</xsl:call-template>				
			</text:p>	
		</xsl:if>
		
		<xsl:choose>
			<xsl:when test="$instructionFormat=''">
				<text:p text:style-name="Warning"><xsl:value-of select="concat('Message d','''','erreur : ',$instructionLabel)"/></text:p>
			</xsl:when>
			<xsl:when test="$instructionFormat='hint'">
				<text:p text:style-name="Instruction"><xsl:value-of select="$instructionLabel"/></text:p>
			</xsl:when>
			<xsl:when test="$instructionFormat='help'">
				<text:p text:style-name="Help"><xsl:value-of select="$instructionLabel"/></text:p>
			</xsl:when>
		</xsl:choose>		
		
		<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
			<xsl:with-param name="driver" select="." tunnel="yes"/>
		</xsl:apply-templates>		
	</xsl:template>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Template named:replaceVariablesInFormula.</xd:p>
			<xd:p>It replaces variables in a formula.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template name="replaceVariablesInFormula">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:param name="formula"/>
		<xsl:param name="variables" as="xs:string*"/>
		
		<xsl:variable name="regex1" select="'number\(if\s\(//'" as="xs:string"/>
		<xsl:variable name="regex2" select="'=''''\)\sthen\s''0''\selse\s//'" as="xs:string"/>
		<xsl:variable name="regex3" select="'\)'" as="xs:string"/>
		
		<xsl:choose>
			<xsl:when test="count($variables)=1">
				<xsl:variable name="regex" select="concat($regex1,$variables[1],$regex2,$variables[1],$regex3)"/>
				<xsl:value-of select="replace($formula,$regex,enoodt:get-business-name($source-context,$variables[1]))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="regex" select="concat($regex1,$variables[1],$regex2,$variables[1],$regex3)"/>
				<xsl:variable name="newFormula" select="replace($formula,$regex,enoodt:get-business-name($source-context,$variables[1]))"/>
				
				<xsl:call-template name="replaceVariablesInFormula">
					<xsl:with-param name="formula" select="$newFormula"></xsl:with-param>
					<xsl:with-param name="variables" select="$variables[position() &gt; 1]"></xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Template named: replaceVariablesInInstruction.</xd:p>
			<xd:p>It replaces variables in a formula.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template name="replaceVariablesInInstruction">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:param name="instruction"/>
		<xsl:param name="variables" as="xs:string*"/>
		
		<xsl:variable name="regex1" select="'¤'" as="xs:string"/>
		<xsl:variable name="regex2" select="'¤'" as="xs:string"/>
		
		<xsl:choose>
			<xsl:when test="count($variables)=1">
				<xsl:variable name="regex" select="concat($regex1,$variables[1],$regex2)"/>
				<xsl:value-of select="replace($instruction,$regex,enoodt:get-business-name($source-context,$variables[1]))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="regex" select="concat($regex1,$variables[1],$regex2)"/>
				<xsl:variable name="newInstruction" select="replace($instruction,$regex,enoodt:get-business-name($source-context,$variables[1]))"/>
				
				<xsl:call-template name="replaceVariablesInInstruction">
					<xsl:with-param name="instruction" select="$newInstruction"></xsl:with-param>
					<xsl:with-param name="variables" select="$variables[position() &gt; 1]"></xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	
</xsl:stylesheet>
