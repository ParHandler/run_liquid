<?xml version="1.0" encoding="UTF-8"?>
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform"
            xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <output method="text" />
    <strip-space elements="*"/>
    <template match="*[@name]">
        <value-of select="concat(':', @name, ': ')"/>
        <value-of select="normalize-space(xs:annotation/xs:documentation)"/>
        <text>\n</text>
        <apply-templates/>
    </template>
    <template match="*[not(@name)]">
        <apply-templates/>
    </template>
    <template match="text()"></template>
</stylesheet>
