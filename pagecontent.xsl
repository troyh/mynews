<?xml version="1.0" encoding="UTF-8" ?>
<!--
	pagecontent
	Created by Troy Hakala on 2011-11-08.
	Copyright (c) 2011 __MyCompanyName__. All rights reserved.
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output encoding="UTF-8" indent="no" method="text" />

	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="//*">
		<xsl:call-template name="print-path"/>
		<xsl:text> </xsl:text>
		<xsl:for-each select="*">
			<xsl:text>CHILD</xsl:text>
			<xsl:if test="text()">
				<xsl:value-of select="./text()"/>
			</xsl:if>
			<xsl:if test="not(text())">
				<xsl:text>&#10;</xsl:text>
				<xsl:apply-templates select="."/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="print-path">
		<xsl:for-each select="ancestor-or-self::*">
			<xsl:call-template name="print-step"/>
	    </xsl:for-each>
	</xsl:template>
	
	<xsl:template name="print-step">
		<xsl:text>/</xsl:text>
		<xsl:value-of select="name()"/>
		<!-- <xsl:text>[</xsl:text>
		<xsl:value-of select="1+count(preceding-sibling::*)"/>
		<xsl:text>]</xsl:text> -->
    </xsl:template>

</xsl:stylesheet>
