<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:wadl="http://wadl.dev.java.net/2009/02">
	<xsl:output method="text" omit-xml-declaration="yes"/>
	
	<xsl:include href="c_impl.xsl"/>
	
	<!-- Prefix to apply to elements.  Optional but recommended.  If not set
	     the XML complex type names will be defined as-is -->
	<xsl:param name="prefix"/>
	<!-- Module name.  Used for naming the .h and .c files.  Required. -->
	<xsl:param name="module-name"/>
	
	<xsl:template match="/">
		<xsl:if test="not($module-name)">
			<xsl:message terminate="yes">The parameter module-name is required.  This parameter sets the name of the output .c and .h files, e.g. &apos;my-module&apos;</xsl:message>
		</xsl:if>
		<xsl:variable name="hfile" select="concat($module-name, '.h')"/>
		<xsl:variable name="cfile" select="concat($module-name, '.c')"/>

		<!-- Process any included grammars (i.e. XSDs) -->
		<xsl:variable name="includes">
			<xsl:call-template name="process-includes"></xsl:call-template>
		</xsl:variable>
	</xsl:template>
	
	<xsl:template name="process-includes">
		<xsl:for-each select="/wadl:application/wadl:grammars/wadl:include">
			<xsl:variable name="href" select="@href"/>
			<!-- Build module name -->
			<xsl:variable name="inc-module-name" select="concat($module-name, '_', substring-before($href, '.xsd'))"/>
			
			<xsl:message><xsl:value-of select="concat('processing ', $href, ' as module ', $inc-module-name)" /></xsl:message>
			
			<!-- Call the xsd_to_c.xsl template on it -->
			<xsl:variable name="xsd-doc" select="document($href)"/>
			<xsl:for-each select="$xsd-doc/*">
				<xsl:call-template name="xsd-to-c">
					<xsl:with-param name="p-module-name" select="$inc-module-name"/>
				</xsl:call-template>
			</xsl:for-each>
			
			<!-- Return a text node to iterate over -->
			<xsl:value-of select="$inc-module-name"/>
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>