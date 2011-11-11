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

		<xsl:variable name="total">
			<xsl:call-template name="total-text-length">
				 <xsl:with-param name="nodes" select="descendant::*[text()]"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:value-of select="string-length(normalize-space(./text())) + $total"/>

		<xsl:text>&#10;</xsl:text>
		<xsl:apply-templates select="*"/>
	</xsl:template>


	<xsl:template name="total-text-length">
		<xsl:param name="nodes"/>
		<xsl:choose>
			<xsl:when test="count($nodes) > 1">
				<xsl:variable name="result">
					<xsl:call-template name="total-text-length">
						<xsl:with-param name="nodes" select="$nodes[position() > 1]"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="string-length(normalize-space($nodes[1]/text())) + $result"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="result" select="0"/>
				<xsl:value-of select="string-length(normalize-space($nodes[1]/text()))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
		
	<xsl:template name="print-path">
		<xsl:for-each select="ancestor-or-self::*">
			<xsl:call-template name="print-step"/>
	    </xsl:for-each>
	</xsl:template>
	
	<xsl:template name="print-step">
		<xsl:text>/</xsl:text>
		<xsl:value-of select="name()"/>
    </xsl:template>

</xsl:stylesheet>
