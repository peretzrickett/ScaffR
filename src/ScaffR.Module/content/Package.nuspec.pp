<?xml version="1.0"?>
<package>
  <metadata>
    <id>$rootnamespace$</id>
    <version>1.1.1</version>
    <authors>Rod Johnson</authors>
    <owners>World-Class Programmers, LLC</owners>
    <projectUrl>http://scaffr.codeplex.com</projectUrl>
    <iconUrl>http://www.scaffr.com/favicon.ico</iconUrl>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <description>
      Installs the powershell commands that make this awesome
    </description>
    <releaseNotes>
    </releaseNotes>
    <copyright>World-Class Programmers 2012</copyright>
    <tags></tags>
    <dependencies>
      <dependency id="T4Scaffolding" version="1.0.6" />
      <dependency id="ScaffR.Core" version="1.1.1" />
    </dependencies>
  </metadata>
  <files>
    <file src="lib\**" target="lib" />
    <file src="tools\**" target="tools" />
    <file src="content\**" target="content" />
  </files>
</package>