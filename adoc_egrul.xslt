<?xml version="1.0" encoding="UTF-8"?>
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform"
            xmlns:ep="uri:asciidoc:doc:automation"
            extension-element-prefixes="ep">
    <output method="text" />
    <strip-space elements="*"/>
    <template match="/">
        <apply-templates/>
    </template>
    <template match="*[count(@*|*) > 0 and count(ancestor::*) > 0]">
        <value-of select="'\n='"/>
        <for-each select="ancestor::*"><value-of select="'='"/></for-each>
        <value-of select="' '"/>
        <value-of select="concat('{',local-name(),'}')"/><text>\n\n</text>
        <text>|===\n</text>
        <for-each select="(@*)|(*[./text()])">
            <text>|</text><value-of select="concat('{',local-name(),'}')"/>
            <text>|</text><value-of select="ep:iformat(current())"/>
            <text>\n</text>
        </for-each>
        <text>|===\n</text>
        <apply-templates/>
    </template>
    <template match="text()"/>
</stylesheet>