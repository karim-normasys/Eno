<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xf="http://www.w3.org/2002/xforms"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xxf="http://orbeon.org/oxf/xml/xforms"
    xmlns:fr="http://orbeon.org/oxf/xml/form-runner" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:eno="http://xml.insee.fr/apps/eno" xmlns:enopogues="http://xml.insee.fr/apps/eno/pogues"
    exclude-result-prefixes="xd eno enopogues" version="2.0">

    <!-- Orbeon-form-runner related file -->
    <!-- This file is imported in the ddi2fr.xsl file (already in ddi2fr-fixed.xsl) -->
    <!--<xsl:import href="../../transformations/ddi2pogues/ddi2pogues.xsl"/>-->

    <!-- Parameters defined in build-non-regression.xml -->
    <xsl:param name="properties-file"/>
    <xsl:variable name="properties" select="doc($properties-file)"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Form generation</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="Form" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:variable name="languages" select="enopogues:get-form-languages($source-context)"
            as="xs:string +"/>
        <Questionnaire xmlns="http://xml.insee.fr/schema/applis/pogues">
            <xsl:attribute name="id">
                <!-- TODO : aller chercher l'ID de l'instrument -->
                <xsl:value-of select="concat($properties/proprietes/campagne,'-','v1')"/>
            </xsl:attribute>
            <xsl:attribute name="depth">0</xsl:attribute>
            <xsl:attribute name="genericName">QUESTIONNAIRE</xsl:attribute>
            <xsl:attribute name="agency">fr.insee</xsl:attribute>
            <xsl:element name="Name">
                <xsl:value-of select="$properties/proprietes/campagne"/>
            </xsl:element>
            <xsl:element name="Label">
                <xsl:value-of select="enopogues:get-form-title($source-context, $languages[1])"/>
            </xsl:element>
            
            <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                <xsl:with-param name="driver" select="eno:append-empty-element('Child', .)" tunnel="yes"/>
            </xsl:apply-templates>
            <xsl:element name="Survey">
                <xsl:attribute name="id">
                    <xsl:value-of select="$properties/proprietes/campagne"/>
                </xsl:attribute>
                <xsl:attribute name="agency">fr.insee</xsl:attribute>
                <xsl:element name="Name">POPO</xsl:element>
            </xsl:element>
            <ComponentGroup  id="j0mjlbl0">
                <Name>PAGE_1</Name>
                <Label>Components for page 1</Label>
                <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                    <xsl:with-param name="driver" select="eno:append-empty-element('Component', .)" tunnel="yes"/>
                </xsl:apply-templates>
            </ComponentGroup>
            <CodeLists>
                <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                    <xsl:with-param name="driver" select="eno:append-empty-element('CodeList', .)" tunnel="yes"/>
                </xsl:apply-templates>                
            </CodeLists>
        </Questionnaire>
    </xsl:template>
    
    <xsl:template match="Component//*" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
            <xsl:with-param name="driver" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Component//*[name() = ('Module','SubModule','Group','Table','TableLoop','MultipleQuestion','SimpleQuestion')]" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:element name="MemberReference">
            <xsl:value-of select="enopogues:get-name($source-context)"/>
        </xsl:element>
        <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
            <xsl:with-param name="driver" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="Child//*" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
            <xsl:with-param name="driver" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Child//*[name()= ('Module','SubModule','Group')]" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:variable name="language" select="enopogues:get-form-languages($source-context)"
            as="xs:string +"/>
        
        <Child>
            <xsl:attribute name="id">
                <xsl:value-of select="enopogues:get-name($source-context)"/>
            </xsl:attribute>
            <xsl:attribute name="depth">
                <xsl:choose>
                    <xsl:when test="name()='Module'">1</xsl:when>
                    <xsl:when test="name()='SubModule'">2</xsl:when>
                    <xsl:when test="name()='Group'">3</xsl:when>
                    <xsl:otherwise>-1</xsl:otherwise>
                </xsl:choose>               
            </xsl:attribute>
            <xsl:attribute name="genericName">MODULE</xsl:attribute>
            <xsl:attribute name="type">SequenceType</xsl:attribute>
            <xsl:element name="Name">
                <xsl:value-of select="enopogues:get-name($source-context)"/>
            </xsl:element>
            <xsl:element name="Label">
                <xsl:value-of select="eno:serialize(enopogues:get-label($source-context, $language))"/>
            </xsl:element>
            <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                <xsl:with-param name="driver" select="." tunnel="yes"/>
            </xsl:apply-templates>            
        </Child>
    </xsl:template>

    <xsl:template match="Child//*[name()= ('textecourt','textelong','xf-select1','xf-select')]" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:variable name="language" select="enopogues:get-form-languages($source-context)"
            as="xs:string +"/>
        
        <Child>
            <xsl:attribute name="id">
                <xsl:value-of select="enopogues:get-name($source-context)"/>
            </xsl:attribute>
            <xsl:attribute name="questionType">SINGLE_CHOICE</xsl:attribute>
            <xsl:attribute name="type">QuestionType</xsl:attribute>
            <xsl:element name="Name">
                <xsl:value-of select="enopogues:get-name($source-context)"/>
            </xsl:element>
            <xsl:element name="Label">
                <xsl:value-of select="eno:serialize(enopogues:get-label($source-context, $language))"/>
            </xsl:element>
            <Response mandatory="false">
                <Datatype typeName="TEXT" type="TextDatatypeType">
                    <MaxLength>
                        <xsl:value-of select="enopogues:get-length($source-context)"/>
                    </MaxLength>
                    <Pattern>                        
                    </Pattern>
                </Datatype>
            </Response>
            
            <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                <xsl:with-param name="driver" select="." tunnel="yes"/>
            </xsl:apply-templates>            
        </Child>
    </xsl:template>
    

    <xsl:template match="CodeList//*" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
            <xsl:with-param name="driver" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>
    <!--
    
    <xsl:template match="Form" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:variable name="languages" select="enopogues:get-form-languages($source-context)"
            as="xs:string +"/>
        <xhtml:html>
            <xhtml:head>
                <xhtml:title>
                    <xsl:value-of select="enopogues:get-form-title($source-context, $languages[1])"/>
                </xhtml:title>
                <xhtml:link rel="stylesheet"
                    href="{concat('/',$properties//css/dossier,'/',$properties//css/principale)}"/>
                <xf:model id="fr-form-model" xxf:expose-xpath-types="true"
                    xxf:noscript-support="true">

                    <!-\- Main instance -\->
                    <xf:instance id="fr-form-instance">
                        <form>
                            <xsl:apply-templates select="eno:child-fields($source-context)"
                                mode="source">
                                <xsl:with-param name="driver"
                                    select="eno:append-empty-element('Instance', .)" tunnel="yes"/>
                            </xsl:apply-templates>
                        </form>
                    </xf:instance>

                    <xf:instance id="fr-form-loop-model">
                        <LoopModels>
                            <xsl:apply-templates select="eno:child-fields($source-context)"
                                mode="source">
                                <xsl:with-param name="driver"
                                    select="eno:append-empty-element('Model', .)" tunnel="yes"/>
                            </xsl:apply-templates>
                        </LoopModels>
                    </xf:instance>

                    <!-\- Bindings -\->
                    <xf:bind id="fr-form-instance-binds" ref="instance('fr-form-instance')">
                        <xsl:apply-templates select="eno:child-fields($source-context)"
                            mode="source">
                            <xsl:with-param name="driver"
                                select="eno:append-empty-element('Bind', .)" tunnel="yes"/>
                        </xsl:apply-templates>
                    </xf:bind>

                    <!-\- Metadata -\->
                    <xf:instance id="fr-form-metadata" xxf:readonly="true">
                        <metadata>
                            <application-name>
                                <xsl:value-of select="enopogues:get-application-name($source-context)"/>
                            </application-name>
                            <form-name>
                                <xsl:value-of select="enopogues:get-form-name($source-context)"/>
                            </form-name>
                            <xsl:for-each select="$languages">
                                <title xml:lang="{.}">
                                    <xsl:value-of select="enopogues:get-form-title($source-context, .)"
                                    />
                                </title>
                            </xsl:for-each>
                        </metadata>
                    </xf:instance>

                    <!-\- Attachments -\->
                    <xf:instance id="fr-form-attachments">
                        <attachments>
                            <css mediatype="text/css" filename="" size=""/>
                            <pdf mediatype="application/pdf" filename="" size=""/>
                        </attachments>
                    </xf:instance>

                    <!-\- All form resources -\->
                    <!-\- Don't make readonly by default in case a service modifies the resources -\->
                    <xf:instance id="fr-form-resources">
                        <resources>
                            <xsl:variable name="driver" select="."/>
                            <xsl:for-each select="$languages">
                                <resource xml:lang="{.}">
                                    <xsl:apply-templates select="eno:child-fields($source-context)"
                                        mode="source">
                                        <xsl:with-param name="driver"
                                            select="eno:append-empty-element('Resource', $driver)"
                                            tunnel="yes"/>
                                        <xsl:with-param name="language" select="." tunnel="yes"/>
                                    </xsl:apply-templates>
                                </resource>
                            </xsl:for-each>
                        </resources>
                    </xf:instance>

                    <!-\- Bind of resources for the ones that are dynamic (text depends from the answer to another question) -\->
                    <xf:bind id="fr-form-resources-bind" ref="instance('fr-form-resources')">
                        <xsl:variable name="driver" select="."/>
                        <xsl:for-each select="$languages">
                            <xf:bind id="{concat('bind-resource-',.)}"
                                name="{concat('resource-',.)}"
                                ref="{concat('resource[@xml:lang=''',.,''']')}">
                                <xsl:apply-templates select="eno:child-fields($source-context)"
                                    mode="source">
                                    <xsl:with-param name="driver"
                                        select="eno:append-empty-element('ResourceBind', $driver)"
                                        tunnel="yes"/>
                                    <xsl:with-param name="language" select="." tunnel="yes"/>
                                </xsl:apply-templates>
                            </xf:bind>
                        </xsl:for-each>
                    </xf:bind>

                    <!-\- Utility instances for services -\->
                    <xf:instance id="fr-service-request-instance" xxf:exclude-result-prefixes="#all">
                        <request/>
                    </xf:instance>

                    <xf:instance id="fr-service-response-instance"
                        xxf:exclude-result-prefixes="#all">
                        <response/>
                    </xf:instance>

                </xf:model>
            </xhtml:head>
            <xhtml:body>
                <fr:view>
                    <fr:body>
                        <xsl:apply-templates select="eno:child-fields($source-context)"
                            mode="source">
                            <xsl:with-param name="driver"
                                select="eno:append-empty-element('Body', .)" tunnel="yes"/>
                            <xsl:with-param name="languages" select="$languages" tunnel="yes"/>
                            <xsl:with-param name="instance-ancestor"
                                select="'instance(''fr-form-instance'')//'" tunnel="yes"/>
                        </xsl:apply-templates>
                    </fr:body>
                </fr:view>
            </xhtml:body>
        </xhtml:html>
    </xsl:template>

    <!-\- Default template, creating the corresponding instance element, and going on on the children -\->
    <xsl:template match="Instance//*" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:element name="{enopogues:get-name($source-context)}"/>
        <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
            <xsl:with-param name="driver" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Instance//*[name() = ('xf-group', 'Module')]" priority="1" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:element name="{enopogues:get-name($source-context)}">
            <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                <xsl:with-param name="driver" select="." tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Instance//xf-output" mode="model" priority="2">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:element name="{enopogues:get-name($source-context)}"/>
    </xsl:template>

    <xsl:template match="Instance//*[name() = ('SubModule', 'TextCell', 'MultipleQuestion')]"
        mode="model" priority="2">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:element name="{enopogues:get-name($source-context)}"/>
        <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
            <xsl:with-param name="driver" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*[name() = ('Resource', 'Body')]//*[name() = ('ResponseElement')]"
        mode="model" priority="1"/>

    <xsl:template match="ResourceBind//xf-output" mode="model" priority="2">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="language" tunnel="yes"/>
        <xsl:variable name="calculate-label">
            <xsl:value-of select="enopogues:get-calculate-label($source-context)"/>
        </xsl:variable>
        <xsl:variable name="calculate-alert">
            <xsl:value-of select="enopogues:get-calculate-alert($source-context)"/>
        </xsl:variable>
        <xsl:if test="$calculate-label != '' or $calculate-alert != ''">
            <xsl:variable name="name" select="enopogues:get-name($source-context)"/>
            <xf:bind id="{$name}-resource-{$language}-bind" name="{$name}-{$language}-resource"
                ref="{$name}">
                <xsl:if test="$calculate-label != ''">
                    <xf:bind id="{$name}-resource-{$language}-bind-label"
                        name="{$name}-{$language}-resource-label" ref="label">
                        <xsl:attribute name="calculate">
                            <xsl:value-of select="$calculate-label"/>
                        </xsl:attribute>
                    </xf:bind>
                </xsl:if>
                <xsl:if test="$calculate-alert != ''">
                    <xf:bind id="{$name}-resource-{$language}-bind-alert"
                        name="{$name}-{$language}-resource-alert" ref="alert">
                        <xsl:attribute name="calculate">
                            <xsl:value-of select="$calculate-alert"/>
                        </xsl:attribute>
                    </xf:bind>
                </xsl:if>
            </xf:bind>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ResourceBind//*" mode="#all">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
            <xsl:with-param name="driver" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Instance//RowLoop" priority="1" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:variable name="name">
            <xsl:value-of select="enopogues:get-name($source-context)"/>
        </xsl:variable>
        <xsl:element name="{$name}">
            <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                <xsl:with-param name="driver" select="." tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:element>
        <xsl:element name="{concat($name,'-Count')}">
            <xsl:value-of select="enopogues:get-minimum-lines($source-context)"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Model//*[not(ancestor::Instance)]" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
            <xsl:with-param name="driver" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Model//RowLoop | Model//QuestionLoop" priority="1" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <!-\- create element with same name and acts like what is done for the instance part -\->
        <xsl:element name="{enopogues:get-name($source-context)}">
            <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                <xsl:with-param name="driver" select="eno:append-empty-element('Instance', .)"
                    tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:element>
        <!-\- keep going down the tree in case there are other loops -\->
        <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
            <xsl:with-param name="driver" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Instance//QuestionLoop" priority="1" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:element name="{enopogues:get-name($source-context)}">
            <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                <xsl:with-param name="driver" select="." tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <!-\-<xsl:template match="Model//*[parent::Cell[ancestor::RowLoop]]" priority="1" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:element name="{enopogues:get-name($source-context)}"/>
    </xsl:template>-\->

    <xsl:template match="Instance//*[name() = ('xf-item', 'EmptyCell')]" priority="1" mode="model"/>

    <xsl:template match="Instance//Table | Instance//TableLoop" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:element name="{enopogues:get-name($source-context)}"/>
        <!-\-<xsl:element name="{concat(enopogues:get-name($source-context),'-group')}"/>-\->
        <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
            <xsl:with-param name="driver" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Instance//DoubleDuration" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:variable name="name">
            <xsl:value-of select="enopogues:get-name($source-context)"/>
        </xsl:variable>
        <xsl:element name="{$name}"/>
        <xsl:element name="{replace($name,'-','-A-')}"/>
        <xsl:element name="{replace($name,'-','-B-')}"/>
        <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
            <xsl:with-param name="driver" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Bind//*" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:variable name="name">
            <xsl:value-of select="enopogues:get-name($source-context)"/>
        </xsl:variable>
        <xsl:variable name="required">
            <xsl:value-of select="enopogues:get-required($source-context)"/>
        </xsl:variable>
        <xsl:variable name="relevant">
            <xsl:value-of select="enopogues:get-relevant($source-context)"/>
        </xsl:variable>
        <xsl:variable name="calculate">
            <xsl:value-of select="enopogues:get-calculate($source-context)"/>
        </xsl:variable>
        <xsl:variable name="type">
            <xsl:value-of select="enopogues:get-type($source-context)"/>
        </xsl:variable>
        <xsl:variable name="readonly">
            <xsl:value-of select="enopogues:get-readonly($source-context)"/>
        </xsl:variable>
        <xsl:variable name="constraint">
            <xsl:value-of select="enopogues:get-constraint($source-context)"/>
        </xsl:variable>
        <xf:bind id="{$name}-bind" name="{$name}" ref="{$name}">
            <xsl:if test="not($required = ('false()', ''))">
                <xsl:attribute name="required">
                    <xsl:value-of select="$required"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$relevant != ''">
                <xsl:attribute name="relevant">
                    <xsl:value-of select="$relevant"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$calculate != ''">
                <xsl:attribute name="calculate">
                    <xsl:value-of select="$calculate"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$type = 'date'">
                <xsl:attribute name="type">
                    <xsl:value-of select="concat('xf:', $type)"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not($readonly = ('false()', ''))">
                <xsl:attribute name="readonly">
                    <xsl:value-of select="concat('not(', $readonly, ')')"
                    />
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$constraint != ''">
                <xsl:element name="xf:constraint">
                    <xsl:variable name="alert-level">
                        <xsl:value-of select="enopogues:get-alert-level($source-context)"/>
                    </xsl:variable>
                    <xsl:if test="$alert-level != ''">
                        <xsl:attribute name="level">
                            <xsl:value-of select="$alert-level"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="value">
                        <xsl:value-of select="$constraint"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:if>
        </xf:bind>
        <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
            <xsl:with-param name="driver" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Bind//ResponseElement" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:variable name="name" select="enopogues:get-name($source-context)"/>
        <xf:bind id="{$name}-bind" name="{$name}" ref="{$name}">
            <xsl:variable name="calculate">
                <xsl:value-of select="enopogues:get-calculate($source-context)"/>
            </xsl:variable>
            <xsl:if test="$calculate != ''">
                <xsl:attribute name="calculate">
                    <xsl:value-of select="$calculate"/>
                </xsl:attribute>
            </xsl:if>
        </xf:bind>
    </xsl:template>

    <xsl:template match="Bind//Module" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:variable name="name" select="enopogues:get-name($source-context)"/>
        <xsl:variable name="relevant">
            <xsl:value-of select="enopogues:get-relevant($source-context)"/>
        </xsl:variable>
        <xsl:variable name="readonly">
            <xsl:value-of select="enopogues:get-readonly($source-context)"/>
        </xsl:variable>
        <xf:bind id="{$name}-bind" name="{$name}" ref="{$name}">
            <xsl:if test="$relevant != ''">
                <xsl:attribute name="relevant">
                    <xsl:value-of select="$relevant"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not($readonly = ('false()', ''))">
                <xsl:attribute name="readonly">
                    <xsl:value-of select="concat('not(', $readonly, ')')"
                    />
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                <xsl:with-param name="driver" select="." tunnel="yes"/>
            </xsl:apply-templates>
        </xf:bind>
    </xsl:template>

    <xsl:template match="Bind//xf-group" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:variable name="name" select="enopogues:get-name($source-context)"/>
        <xsl:variable name="relevant">
            <xsl:value-of select="enopogues:get-relevant($source-context)"/>
        </xsl:variable>
        <xsl:variable name="readonly">
            <xsl:value-of select="enopogues:get-readonly($source-context)"/>
        </xsl:variable>
        <xf:bind id="{$name}-bind" name="{$name}" ref="{$name}">
            <xsl:if test="$relevant != ''">
                <xsl:attribute name="relevant">
                    <xsl:value-of select="$relevant"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not($readonly = ('false()', ''))">
                <xsl:attribute name="readonly">
                    <xsl:value-of select="concat('not(', $readonly, ')')"
                    />
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                <xsl:with-param name="driver" select="." tunnel="yes"/>
            </xsl:apply-templates>
        </xf:bind>
    </xsl:template>

    <xsl:template match="Bind//RowLoop | Bind//QuestionLoop" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:variable name="name" select="enopogues:get-name($source-context)"/>
        <xf:bind id="{$name}-bind" name="{$name}" nodeset="{$name}">
            <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                <xsl:with-param name="driver" select="." tunnel="yes"/>
            </xsl:apply-templates>
        </xf:bind>
    </xsl:template>

    <xsl:template match="Bind//*[name() = ('xf-item', 'EmptyCell')]" priority="1" mode="model"/>

    <xsl:template match="Bind//Table | Bind//TableLoop" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:variable name="name">
            <xsl:value-of select="enopogues:get-name($source-context)"/>
        </xsl:variable>
        <xsl:variable name="required">
            <xsl:value-of select="enopogues:get-required($source-context)"/>
        </xsl:variable>
        <xsl:variable name="relevant">
            <xsl:value-of select="enopogues:get-relevant($source-context)"/>
        </xsl:variable>
        <xsl:variable name="calculate">
            <xsl:value-of select="enopogues:get-calculate($source-context)"/>
        </xsl:variable>
        <xsl:variable name="type">
            <xsl:value-of select="enopogues:get-type($source-context)"/>
        </xsl:variable>
        <xsl:variable name="readonly">
            <xsl:value-of select="enopogues:get-readonly($source-context)"/>
        </xsl:variable>
        <xsl:variable name="constraint">
            <xsl:value-of select="enopogues:get-constraint($source-context)"/>
        </xsl:variable>
        <xf:bind id="{$name}-bind" name="{$name}" ref="{$name}">
            <xsl:if test="not($required = ('false()', ''))">
                <xsl:attribute name="required">
                    <xsl:value-of select="$required"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$relevant != ''">
                <xsl:attribute name="relevant">
                    <xsl:value-of select="$relevant"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$calculate != ''">
                <xsl:attribute name="calculate">
                    <xsl:value-of select="$calculate"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$type = 'date'">
                <xsl:attribute name="type">
                    <xsl:value-of select="concat('xf:', $type)"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not($readonly = ('false()', ''))">
                <xsl:attribute name="readonly">
                    <xsl:value-of select="concat('not(', $readonly, ')')"
                    />
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$constraint != ''">
                <xsl:element name="xf:constraint">
                    <xsl:variable name="alert-level">
                        <xsl:value-of select="enopogues:get-alert-level($source-context)"/>
                    </xsl:variable>
                    <xsl:if test="$alert-level != ''">
                        <xsl:attribute name="level">
                            <xsl:value-of select="$alert-level"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="value">
                        <xsl:value-of select="$constraint"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:if>
        </xf:bind>
        <xsl:variable name="name-bis" select="concat($name, '-group')"/>
        <!-\-<xf:bind id="{$name-bis}-bind" name="{$name-bis}" ref="{$name-bis}">
            <xsl:if test="enopogues:get-relevant($source-context) != ''">
                <xsl:attribute name="relevant">
                    <xsl:value-of select="enopogues:get-relevant($source-context)"/>
                </xsl:attribute>
            </xsl:if>
        </xf:bind>-\->
        <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
            <xsl:with-param name="driver" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Bind//DoubleDuration" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:variable name="name" select="enopogues:get-name($source-context)"/>
        <xsl:variable name="required">
            <xsl:value-of select="enopogues:get-required($source-context)"/>
        </xsl:variable>
        <xsl:variable name="relevant">
            <xsl:value-of select="enopogues:get-relevant($source-context)"/>
        </xsl:variable>
        <xsl:variable name="calculate">
            <xsl:value-of select="enopogues:get-calculate($source-context)"/>
        </xsl:variable>
        <xsl:variable name="readonly">
            <xsl:value-of select="enopogues:get-readonly($source-context)"/>
        </xsl:variable>
        <!-\- Creating one element that correspond to the concatenation of the two ones -\->
        <xf:bind id="{$name}-bind" name="{$name}" ref="{$name}">
            <xsl:attribute name="calculate">
                <xsl:value-of
                    select="
                        concat('if (not(instance(''fr-form-instance'')//', replace($name, '-', '-A-'),
                        ' castable as xs:integer or instance(''fr-form-instance'')//', replace($name, '-', '-B-'),
                        ' castable as xs:integer)) then '''' else (100*number(if (instance(''fr-form-instance'')//', replace($name, '-', '-A-'),
                        ' castable as xs:integer) then instance(''fr-form-instance'')//', replace($name, '-', '-A-'),
                        ' else 0)+number(if (instance(''fr-form-instance'')//', replace($name, '-', '-B-'),
                        ' castable as xs:integer) then instance(''fr-form-instance'')//', replace($name, '-', '-B-'),
                        ' else 0))')"
                />
            </xsl:attribute>
        </xf:bind>
        <xsl:variable name="nameA" select="replace($name, '-', '-A-')"/>
        <xf:bind id="{$nameA}-bind" name="{$nameA}" ref="{$nameA}">
            <xsl:if test="not($required = ('false()', ''))">
                <xsl:attribute name="required">
                    <xsl:value-of select="$required"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$relevant != ''">
                <xsl:attribute name="relevant">
                    <xsl:value-of select="$relevant"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$calculate != ''">
                <xsl:attribute name="calculate">
                    <xsl:value-of select="$calculate"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not($readonly = ('false()', ''))">
                <xsl:attribute name="readonly">
                    <xsl:value-of select="concat('not(', $readonly, ')')"
                    />
                </xsl:attribute>
            </xsl:if>
        </xf:bind>
        <xsl:variable name="nameB" select="replace($name, '-', '-B-')"/>
        <xf:bind id="{$nameB}-bind" name="{$nameB}" ref="{$nameB}">
            <xsl:if test="not($required = ('false()', ''))">
                <xsl:attribute name="required">
                    <xsl:value-of select="$required"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$relevant != ''">
                <xsl:attribute name="relevant">
                    <xsl:value-of select="$relevant"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$calculate != ''">
                <xsl:attribute name="calculate">
                    <xsl:value-of select="$calculate"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not($readonly = ('false()', ''))">
                <xsl:attribute name="readonly">
                    <xsl:value-of select="concat('not(', $readonly, ')')"
                    />
                </xsl:attribute>
            </xsl:if>
        </xf:bind>
        <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
            <xsl:with-param name="driver" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Resource//*" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="language" tunnel="yes"/>
        <xsl:element name="{enopogues:get-name($source-context)}">
            <label>
                <xsl:value-of select="eno:serialize(enopogues:get-label($source-context, $language))"/>
            </label>
            <hint>
                <xsl:value-of select="eno:serialize(enopogues:get-hint($source-context, $language))"/>
            </hint>
            <help>
                <xsl:value-of select="eno:serialize(enopogues:get-help($source-context, $language))"/>
            </help>
            <alert>
                <xsl:value-of select="eno:serialize(enopogues:get-alert($source-context, $language))"/>
            </alert>
        </xsl:element>
        <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
            <xsl:with-param name="driver" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Resource//*[starts-with(name(), 'xf-select')]" priority="1" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="language" tunnel="yes"/>
        <xsl:element name="{enopogues:get-name($source-context)}">
            <label>
                <xsl:value-of select="eno:serialize(enopogues:get-label($source-context, $language))"/>
            </label>
            <hint>
                <xsl:value-of select="eno:serialize(enopogues:get-hint($source-context, $language))"/>
            </hint>
            <help>
                <xsl:value-of select="eno:serialize(enopogues:get-help($source-context, $language))"/>
            </help>
            <alert>
                <xsl:value-of select="eno:serialize(enopogues:get-alert($source-context, $language))"/>
            </alert>
            <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                <xsl:with-param name="driver" select="." tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Resource//DoubleDuration" priority="1" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="language" tunnel="yes"/>
        <xsl:variable name="name">
            <xsl:value-of select="enopogues:get-name($source-context)"/>
        </xsl:variable>
        <xsl:variable name="label">
            <xsl:value-of select="eno:serialize(enopogues:get-label($source-context, $language))"/>
        </xsl:variable>
        <xsl:variable name="hint">
            <xsl:value-of select="eno:serialize(enopogues:get-hint($source-context, $language))"/>
        </xsl:variable>
        <xsl:element name="{replace($name,'-','-A-')}">
            <label>
                <xsl:value-of select="$label"/>
            </label>
            <hint>
                <xsl:value-of select="$hint"/>
            </hint>
            <xsl:for-each select="20 to 60">
                <item>
                    <label>
                        <xsl:value-of select="."/>
                    </label>
                    <value>
                        <xsl:value-of select="."/>
                    </value>
                </item>
            </xsl:for-each>
        </xsl:element>
        <xsl:element name="{replace($name,'-','-B-')}">
            <label>
                <xsl:value-of select="$label"/>
            </label>
            <hint>
                <xsl:value-of select="$hint"/>
            </hint>
            <xsl:for-each select="0 to 99">
                <xsl:variable name="item-label">
                    <xsl:choose>
                        <xsl:when test="number(.) &lt; 10">
                            <xsl:value-of select="concat('0', string(.))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="string(.)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <item>
                    <label>
                        <xsl:value-of select="$item-label"/>
                    </label>
                    <value>
                        <xsl:value-of select="$item-label"/>
                    </value>
                </item>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Resource//EmptyCell" priority="1" mode="model"/>

    <xsl:template match="Resource//xf-item" priority="1" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="language" tunnel="yes"/>
        <item>
            <label>
                <xsl:value-of select="enopogues:get-label($source-context, $language)"/>
            </label>
            <value>
                <xsl:value-of select="enopogues:get-value($source-context)"/>
            </value>
        </item>
    </xsl:template>

    <xsl:template match="Body//Module" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="languages" tunnel="yes"/>
        <xsl:variable name="name" select="enopogues:get-name($source-context)"/>
        <fr:section id="{$name}-control" bind="{$name}-bind" name="{$name}">
            <xf:label ref="$form-resources/{$name}/label"/>
            <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                <xsl:with-param name="driver" select="." tunnel="yes"/>
            </xsl:apply-templates>
        </fr:section>
    </xsl:template>

    <xsl:template match="Body//SubModule" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="languages" tunnel="yes"/>
        <xsl:variable name="name" select="enopogues:get-name($source-context)"/>
        <xsl:variable name="label">
            <xsl:value-of select="enopogues:get-label($source-context, $languages[1])"/>
        </xsl:variable>
        <xsl:variable name="css-class">
            <xsl:value-of select="enopogues:get-css-class($source-context)"/>
        </xsl:variable>
        <xhtml:div>
            <xsl:if test="$css-class != ''">
                <xsl:attribute name="class">
                    <xsl:value-of select="$css-class"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not($label = '')">
                <xhtml:h3>
                    <xf:output id="{$name}-control" bind="{$name}-bind">
                        <xf:label ref="$form-resources/{$name}/label">
                            <xsl:if test="$css-class != ''">
                                <xsl:attribute name="class">
                                    <xsl:value-of select="$css-class"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:if test="eno:is-rich-content($label)">
                                <xsl:attribute name="mediatype">text/html</xsl:attribute>
                            </xsl:if>
                        </xf:label>
                    </xf:output>
                </xhtml:h3>
            </xsl:if>
            <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                <xsl:with-param name="driver" select="." tunnel="yes"/>
            </xsl:apply-templates>
        </xhtml:div>
    </xsl:template>

    <xsl:template match="Body//Group" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="languages" tunnel="yes"/>
        <xsl:variable name="name" select="enopogues:get-name($source-context)"/>
        <xsl:variable name="label">
            <xsl:value-of select="enopogues:get-label($source-context, $languages[1])"/>
        </xsl:variable>
        <xsl:variable name="css-class">
            <xsl:value-of select="enopogues:get-css-class($source-context)"/>
        </xsl:variable>
        <xhtml:div>
            <xsl:if test="$css-class != ''">
                <xsl:attribute name="class">
                    <xsl:value-of select="$css-class"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not($label = '')">
                <xhtml:h4>
                    <xf:output id="{$name}-control" bind="{$name}-bind">
                        <xf:label ref="$form-resources/{$name}/label">
                            <xsl:if test="$css-class != ''">
                                <xsl:attribute name="class">
                                    <xsl:value-of select="$css-class"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:if test="eno:is-rich-content($label)">
                                <xsl:attribute name="mediatype">text/html</xsl:attribute>
                            </xsl:if>
                        </xf:label>
                    </xf:output>
                </xhtml:h4>
            </xsl:if>
            <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                <xsl:with-param name="driver" select="." tunnel="yes"/>
            </xsl:apply-templates>
        </xhtml:div>
    </xsl:template>

    <xsl:template match="Body//xf-group" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="languages" tunnel="yes"/>
        <xsl:variable name="name" select="enopogues:get-name($source-context)"/>
        <xf:group id="{$name}-control" bind="{$name}-bind">
            <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                <xsl:with-param name="driver" select="." tunnel="yes"/>
            </xsl:apply-templates>
        </xf:group>
    </xsl:template>

    <xsl:template match="Body//MultipleQuestion" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="languages" tunnel="yes"/>
        <xhtml:div class="question">
            <xsl:variable name="question-title">
                <Body>
                    <xf-output/>
                </Body>
            </xsl:variable>
            <xsl:apply-templates select="$question-title//xf-output" mode="model"/>
            <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                <xsl:with-param name="driver" select="." tunnel="yes"/>
            </xsl:apply-templates>
        </xhtml:div>
    </xsl:template>

    <xsl:template match="*[name() = ('Instance', 'Bind', 'Resource')]//*[name() = ('Cell')]"
        mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="language" tunnel="yes"/>
        <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
            <xsl:with-param name="driver" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Body//TextCell" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="languages" tunnel="yes"/>
        <xsl:variable name="depth">
            <xsl:value-of select="enopogues:get-code-depth($source-context)"/>
        </xsl:variable>
        <xhtml:th colspan="{enopogues:get-colspan($source-context)}"
            rowspan="{enopogues:get-rowspan($source-context)}">
            <xsl:if
                test="$depth!='1' and $depth!=''">
                <xsl:attribute name="class"
                    select="concat('depth',$depth)"/>
            </xsl:if>
            <xsl:variable name="cell-text">
                <Body>
                    <xf-output/>
                </Body>
            </xsl:variable>
            <xsl:apply-templates select="$cell-text//xf-output" mode="model"/>
            <!-\-            <xsl:value-of select="enopogues:get-label($source-context, $languages[1])"/>-\->
        </xhtml:th>
    </xsl:template>

    <xsl:template match="Body//Cell" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="languages" tunnel="yes"/>
        <xhtml:td align="center">
            <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                <xsl:with-param name="driver" select="." tunnel="yes"/>
            </xsl:apply-templates>
        </xhtml:td>
    </xsl:template>

    <xsl:template match="Body//EmptyCell" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="languages" tunnel="yes"/>
        <xhtml:td colspan="{enopogues:get-colspan($source-context)}"/>
    </xsl:template>

    <xsl:template match="Body//Table" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="languages" tunnel="yes"/>
        <xsl:variable name="table-title">
            <Body>
                <xf-output/>
            </Body>
        </xsl:variable>
        <xsl:apply-templates select="$table-title//xf-output" mode="model"/>

        <xsl:variable name="ancestors">
            <xsl:copy-of select="root(.)"/>
        </xsl:variable>
        <xsl:variable name="css-class">
            <xsl:value-of select="enopogues:get-css-class($source-context)"/>
        </xsl:variable>
        <xhtml:table name="{enopogues:get-name($source-context)}">
            <xsl:if test="$css-class != ''">
                <xsl:attribute name="class">
                    <xsl:value-of select="$css-class"/>
                </xsl:attribute>
            </xsl:if>
            <xhtml:colgroup>
                <xhtml:col span="{count(enopogues:get-header-columns($source-context))}"/>
            </xhtml:colgroup>
            <xhtml:thead>
                <xsl:for-each select="enopogues:get-header-lines($source-context)">
                    <xhtml:tr>
                        <xsl:apply-templates
                            select="enopogues:get-header-line($source-context, position())"
                            mode="source">
                            <xsl:with-param name="driver"
                                select="$ancestors//*[not(child::*) and not(name() = 'driver')]"
                                tunnel="yes"/>
                        </xsl:apply-templates>
                    </xhtml:tr>
                </xsl:for-each>
            </xhtml:thead>
            <xhtml:tbody>
                <xsl:for-each select="enopogues:get-body-lines($source-context)">
                    <xhtml:tr>
                        <xsl:apply-templates
                            select="enopogues:get-body-line($source-context, position())" mode="source">
                            <xsl:with-param name="driver"
                                select="$ancestors//*[not(child::*) and not(name() = 'driver')]"
                                tunnel="yes"/>
                        </xsl:apply-templates>
                    </xhtml:tr>
                </xsl:for-each>
            </xhtml:tbody>
        </xhtml:table>
    </xsl:template>

    <xsl:template match="Body//QuestionLoop" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="languages" tunnel="yes"/>
        <xsl:param name="instance-ancestor" tunnel="yes"/>
        <xsl:variable name="loop-name" select="enopogues:get-name($source-context)"/>
        <xf:repeat nodeset="{concat($instance-ancestor,$loop-name)}"
            id="{$loop-name}">
            <xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
                <xsl:with-param name="driver" select="." tunnel="yes"/>
                <xsl:with-param name="instance-ancestor"
                    select="concat($instance-ancestor,'*[name()=''',$loop-name,
                    ''' and count(preceding-sibling::*)=count(current()/ancestor::*[name()=''',
                    $loop-name,''']/preceding-sibling::*)]//')"
                    tunnel="yes"/>
            </xsl:apply-templates>
        </xf:repeat>
    </xsl:template>

    <xsl:template match="Body//TableLoop" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="languages" tunnel="yes"/>
        <xsl:param name="instance-ancestor" tunnel="yes"/>
        <xsl:variable name="table-title">
            <Body>
                <xf-output/>
            </Body>
        </xsl:variable>
        <xsl:apply-templates select="$table-title//xf-output" mode="model"/>

        <xsl:variable name="ancestors">
            <xsl:copy-of select="root(.)"/>
        </xsl:variable>
        
        <xsl:variable name="name" select="enopogues:get-name($source-context)"/>
        <xsl:variable name="css-class">
            <xsl:value-of select="enopogues:get-css-class($source-context)"/>
        </xsl:variable>

        <xhtml:table name="{$name}">
            <xsl:if test="$css-class != ''">
                <xsl:attribute name="class">
                    <xsl:value-of select="$css-class"/>
                </xsl:attribute>
            </xsl:if>
            <xhtml:colgroup>
                <xhtml:col span="{count(enopogues:get-header-columns($source-context))}"/>
            </xhtml:colgroup>
            <xhtml:thead>
                <xsl:for-each select="enopogues:get-header-lines($source-context)">
                    <xhtml:tr>
                        <xsl:apply-templates
                            select="enopogues:get-header-line($source-context, position())"
                            mode="source">
                            <xsl:with-param name="driver"
                                select="$ancestors//*[not(child::*) and not(name() = 'driver')]"
                                tunnel="yes"/>
                        </xsl:apply-templates>
                    </xhtml:tr>
                </xsl:for-each>
            </xhtml:thead>
            <xhtml:tbody>
                <xf:repeat
                    nodeset="{concat($instance-ancestor,$name,'-RowLoop')}"
                    id="{concat($name,'-RowLoop')}">
                    <xhtml:tr>
                        <xsl:apply-templates select="enopogues:get-body-line($source-context, 1)"
                            mode="source">
                            <xsl:with-param name="driver"
                                select="$ancestors//*[not(child::*) and not(name() = 'driver')]"
                                tunnel="yes"/>
                            <xsl:with-param name="instance-ancestor"
                                select="concat($instance-ancestor,'*[name()=''',$name,
                                ''' and count(preceding-sibling::*)=count(current()/ancestor::*[name()=''',
                                $name,''']/preceding-sibling::*)]//')"
                                tunnel="yes"/>
                        </xsl:apply-templates>
                    </xhtml:tr>
                </xf:repeat>
            </xhtml:tbody>
        </xhtml:table>
        <xf:trigger>
            <xf:label>Ajouter une ligne</xf:label>
            <xf:insert ev:event="DOMActivate" context="."
                nodeset="{concat('//',$name,'-RowLoop')}"
                origin="{concat('instance(''fr-form-loop-model'')/',$name,'-RowLoop')}"
            />
        </xf:trigger>
    </xsl:template>

    <xsl:template match="Body//*" mode="model">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="languages" tunnel="yes"/>
        <xsl:param name="instance-ancestor" tunnel="yes"/>
        <xsl:variable name="name" select="enopogues:get-name($source-context)"/>
        <xsl:variable name="appearance">
            <xsl:value-of select="enopogues:get-appearance($source-context)"/>
        </xsl:variable>
        <xsl:variable name="css-class">
            <xsl:value-of select="enopogues:get-css-class($source-context)"/>
        </xsl:variable>
        <xsl:variable name="length">
            <xsl:value-of select="enopogues:get-length($source-context)"/>
        </xsl:variable>
        <xsl:variable name="suffix">
            <xsl:value-of select="enopogues:get-suffix($source-context, $languages[1])"/>
        </xsl:variable>
        <xsl:element name="{translate(name(), '-', ':')}">
            <xsl:attribute name="id">
                <xsl:value-of select="concat($name, '-control')"/>
            </xsl:attribute>
            <xsl:attribute name="name">
                <xsl:value-of select="$name"/>
            </xsl:attribute>
            <xsl:attribute name="bind">
                <xsl:value-of select="concat($name, '-bind')"/>
            </xsl:attribute>
            <xsl:if test="$appearance != ''">
                <xsl:attribute name="appearance">
                    <xsl:value-of select="$appearance"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$css-class != ''">
                <xsl:attribute name="class">
                    <xsl:value-of select="$css-class"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="xxf:order">
                <xsl:value-of select="'label control hint help alert'"/>
            </xsl:attribute>
            <xsl:if test="not($length='')">
                <xsl:attribute name="xxf:maxlength">
                    <xsl:value-of select="$length"/>
                </xsl:attribute>
            </xsl:if>
            <xf:label ref="$form-resources/{$name}/label">
                <xsl:if test="eno:is-rich-content(enopogues:get-label($source-context, $languages[1]))">
                    <xsl:attribute name="mediatype">text/html</xsl:attribute>
                </xsl:if>
            </xf:label>
            <xf:hint ref="$form-resources/{$name}/hint">
                <xsl:if test="eno:is-rich-content(enopogues:get-hint($source-context, $languages[1]))">
                    <xsl:attribute name="mediatype">text/html</xsl:attribute>
                </xsl:if>
            </xf:hint>
            <xf:help ref="$form-resources/{$name}/help">
                <xsl:if test="eno:is-rich-content(enopogues:get-help($source-context, $languages[1]))">
                    <xsl:attribute name="mediatype">text/html</xsl:attribute>
                </xsl:if>
            </xf:help>
            <xf:alert ref="$form-resources/{$name}/alert">
                <xsl:if test="enopogues:get-alert-level($source-context) != ''">
                    <xsl:attribute name="level">
                        <xsl:value-of select="enopogues:get-alert-level($source-context)"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="eno:is-rich-content(enopogues:get-alert($source-context, $languages[1]))">
                    <xsl:attribute name="mediatype">text/html</xsl:attribute>
                </xsl:if>
            </xf:alert>
            <xsl:if test="self::xf-select1 or self::xf-select">
                <xsl:if test="$appearance = 'minimal'">
                    <xf:item>
                        <xf:label/>
                        <xf:value/>
                    </xf:item>
                </xsl:if>
                <xf:itemset ref="$form-resources/{$name}/item">
                    <xf:label ref="label"/>
                    <xf:value ref="value"/>
                </xf:itemset>
            </xsl:if>
            <!-\- In this select case, if there is still someting after a space in the current value, that means that 2 boxes are checked.
            We replace the value with what was after the space and that correspond the value of the last checked box.
            This unchecks the first box that was checked -\->
            <xsl:if test="self::xf-select">
                <xf:action ev:event="xforms-value-changed"
                    if="{concat('substring-after(',$instance-ancestor,$name,','' '') ne ''''')}">
                    <xf:setvalue ref="{concat($instance-ancestor,$name)}"
                        value="{concat('substring-after(',$instance-ancestor,$name,','' '')')}"/>
                </xf:action>
            </xsl:if>
            <!-\- For each element which relevance depends on this field, we erase the data if it became unrelevant -\->
            <xsl:for-each select="enopogues:get-relevant-dependencies($source-context)">
                <xf:action ev:event="xforms-value-changed"
                    if="{concat('not(xxf:evaluate-bind-property(''',.,'-bind'',''relevant''))')}"
                    iterate="{concat($instance-ancestor,.,'//*[not(descendant::*)]')}">
                    <xf:setvalue ref="." value="''"/>
                </xf:action>
            </xsl:for-each>
            <!-\- For each element which readonly status depends on this field, we erase the data if it became readonly -\->
            <!-\- change in the point of view : we keep then now -\->
<!-\-            <xsl:for-each select="enopogues:get-readonly-dependencies($source-context)">
                <xf:action ev:event="xforms-value-changed"
                    if="{concat('xxf:evaluate-bind-property(''',.,'-bind'',''readonly'')')}"
                    iterate="{concat($instance-ancestor,.,'//*[not(descendant::*)]')}">
                    <xf:setvalue ref="." value="''"/>
                </xf:action>
            </xsl:for-each>-\->

            <xsl:for-each select="enopogues:get-constraint-dependencies($source-context)">
                <xsl:element name="xf:dispatch">
                    <xsl:attribute name="ev:event">
                        <xsl:text>DOMFocusOut xforms-value-changed</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="name">
                        <xsl:text>DOMFocusOut</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="target">
                        <xsl:value-of select="concat(., '-control')"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
        <xsl:if test="not($suffix='')">
            <xsl:element name="xhtml:span">
                <xsl:attribute name="class" select="'suffixe'"/>
                <xsl:copy-of select="$suffix"
                    copy-namespaces="no"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="Body//DoubleDuration" mode="model" priority="1">
        <xsl:param name="source-context" as="item()" tunnel="yes"/>
        <xsl:param name="languages" tunnel="yes"/>
        <xsl:variable name="appearance">
            <xsl:value-of select="enopogues:get-appearance($source-context)"/>
        </xsl:variable>
        <xsl:variable name="length">
            <xsl:value-of select="enopogues:get-length($source-context)"/>
        </xsl:variable>
        <xsl:variable name="name" select="replace(enopogues:get-name($source-context), '-', '-A-')"/>
        <xsl:element name="xf:select1">
            <xsl:attribute name="id">
                <xsl:value-of select="concat($name, '-control')"/>
            </xsl:attribute>
            <xsl:attribute name="bind">
                <xsl:value-of select="concat($name, '-bind')"/>
            </xsl:attribute>
            <xsl:if test="$appearance != ''">
                <xsl:attribute name="appearance">
                    <xsl:value-of select="$appearance"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="class">
                <xsl:value-of select="'double-duration'"/>
            </xsl:attribute>
            <xsl:attribute name="xxf:order">
                <xsl:value-of select="'label control hint help alert'"/>
            </xsl:attribute>
            <xsl:if test="not($length='')">
                <xsl:attribute name="xxf:maxlength">
                    <xsl:value-of select="$length"/>
                </xsl:attribute>
            </xsl:if>
            <xf:label ref="$form-resources/{$name}/label">
                <xsl:if test="eno:is-rich-content(enopogues:get-label($source-context, $languages[1]))">
                    <xsl:attribute name="mediatype">text/html</xsl:attribute>
                </xsl:if>
            </xf:label>
            <xf:hint ref="$form-resources/{$name}/hint">
                <xsl:if test="eno:is-rich-content(enopogues:get-hint($source-context, $languages[1]))">
                    <xsl:attribute name="mediatype">text/html</xsl:attribute>
                </xsl:if>
            </xf:hint>
            <xf:item>
                <xf:label/>
                <xf:value/>
            </xf:item>
            <xf:itemset ref="$form-resources/{$name}/item">
                <xf:label ref="label"/>
                <xf:value ref="value"/>
            </xf:itemset>
        </xsl:element>
        <xsl:element name="xhtml:span">
            <xsl:attribute name="class" select="'double-duration-suffix'"/>
            <xsl:text>heure(s)</xsl:text>
        </xsl:element>

        <xsl:variable name="name" select="replace(enopogues:get-name($source-context), '-', '-B-')"/>
        <xsl:element name="xf:select1">
            <xsl:attribute name="id">
                <xsl:value-of select="concat($name, '-control')"/>
            </xsl:attribute>
            <xsl:attribute name="bind">
                <xsl:value-of select="concat($name, '-bind')"/>
            </xsl:attribute>
            <xsl:if test="$appearance != ''">
                <xsl:attribute name="appearance">
                    <xsl:value-of select="$appearance"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="class">
                <xsl:value-of select="'double-duration'"/>
            </xsl:attribute>
            <xsl:attribute name="xxf:order">
                <xsl:value-of select="'label control hint help alert'"/>
            </xsl:attribute>
            <xsl:if test="$length">
                <xsl:attribute name="xxf:maxlength">
                    <xsl:value-of select="$length"/>
                </xsl:attribute>
            </xsl:if>
            <xf:label ref="$form-resources/{$name}/label">
                <xsl:if test="eno:is-rich-content(enopogues:get-label($source-context, $languages[1]))">
                    <xsl:attribute name="mediatype">text/html</xsl:attribute>
                </xsl:if>
            </xf:label>
            <xf:hint ref="$form-resources/{$name}/hint">
                <xsl:if test="eno:is-rich-content(enopogues:get-hint($source-context, $languages[1]))">
                    <xsl:attribute name="mediatype">text/html</xsl:attribute>
                </xsl:if>
            </xf:hint>
            <xf:item>
                <xf:label/>
                <xf:value/>
            </xf:item>
            <xf:itemset ref="$form-resources/{$name}/item">
                <xf:label ref="label"/>
                <xf:value ref="value"/>
            </xf:itemset>
        </xsl:element>
        <xsl:element name="xhtml:span">
            <xsl:attribute name="class" select="'double-duration-suffix'"/>
            <xsl:text>centième(s)</xsl:text>
        </xsl:element>
    </xsl:template>

--></xsl:stylesheet>
