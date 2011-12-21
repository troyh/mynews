<?xml version="1.0" encoding="UTF-8" ?>
<!--
	readabletext
	Created by Troy Hakala on 2011-12-20.
	Copyright (c) 2011 __MyCompanyName__. All rights reserved.
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output encoding="UTF-8" indent="no" method="text" />

	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="p">
		<xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

	<!-- <xsl:template match="*">
		<xsl:apply-templates/>
    </xsl:template> -->

	<xsl:template match="//script"></xsl:template>
	<xsl:template match="//ul"></xsl:template>
	<xsl:template match="//ol"></xsl:template>

</xsl:stylesheet>
