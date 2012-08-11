﻿##############################################################################
# Copyright (c) 2012 
# Ulf Björklund
# http://average-uffe.blogspot.com/
# http://twitter.com/codeplanner
# http://twitter.com/ulfbjo
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
##############################################################################

function Add-CodeToMethod([string]$ProjectName, [string]$Folder = "", [string]$FileName,[string]$ClassName, [string]$MethodName, [string]$Code){

	$filepath = Get-File $ProjectName $Folder $FileName	
	$file = $DTE.Solution.FindProjectItem($filepath)
	if($file -eq $null){
		return
	}
	$file.Open().Activate()
		
	$ns = $DTE.ActiveDocument.ProjectItem.FileCodeModel.CodeElements | Where-Object{$_.Kind -eq 5}
	$classes = $ns | ForEach{$_.Children}	
	$classes | ForEach{	
		if(!($_.Name -eq $null)){						
			if($_.Name -eq $ClassName){
				$_.Children | ForEach{
					if($_.Name -eq $MethodName){	
						$addCode = $true
						$edit = $_.EndPoint.CreateEditPoint()
						$edit.GetLines($_.StartPoint.Line,$_.EndPoint.Line).split("`n") | ForEach{													
							if($_.Contains($Code)){								
								$addCode = $false
							}
						}												
						if($addCode -eq $true){
							$edit.StartOfLine()																	
							$edit.Insert($Code)
						}
					}					
				}	
			}
		}
	}	
	$DTE.ExecuteCommand("Edit.FormatDocument")
	$file.Save()	
	#$file.Close()
}


function Add-Namespace([string]$ProjectName, [string]$Folder = "", [string]$FileName,[string]$Namespace){

	$filepath = Get-File $ProjectName $Folder $FileName
	
	$file = $DTE.Solution.FindProjectItem($filepath)
	$file.Open().Document.Activate()
	
	$checkForThis = "using $($Namespace);" 
	$exists = $false
	
	Get-Content $filepath | foreach-Object {  if($_.Contains($checkForThis)){ $exists = $true }}
	
	if($exists -eq $false){
		$DTE.ActiveDocument.Selection.StartOfDocument()
		$DTE.ActiveDocument.Selection.NewLine()
		$DTE.ActiveDocument.Selection.LineUp()
		$DTE.ActiveDocument.Selection.Insert($checkForThis)
		$DTE.ExecuteCommand("Edit.FormatDocument")
		$file.Save()
	}	
}

function Get-Class($classname){

	$namespaces = $DTE.Documents | ForEach{$_.ProjectItem.FileCodeModel.CodeElements | Where-Object{$_.Kind -eq 5}}	
	#Write-Host $classname
	$classes = $namespaces | ForEach{$_.Children}
	$ret = $null
	#Write-Host $classes
	$classes | ForEach{	
		if(!($_.Name -eq $null)){						
			if($_.Name.Trim() -eq $classname){					
				$ret = $_
			}
		}
	}		
	#Write-Host $ret
	return $ret
}

function Get-Properties($type){
	if($type -eq $null){
		Write-Host "You have to provide a DTE class. Use Get-Domain 'BaseClass' or Get-Class 'classname' to get the class(es) you want"
		return $null
	}
	return ForEach{$type.Children | Where-Object{$_.Kind -eq 4}}
}

function Get-LineOfMethod([string]$type, [string]$methodName){	
	
	$t = Get-Class($type)
	$ret = $null
	$t.Children | ForEach{
		if($_.Name -eq $methodName){
			Write-Host "Method found"
			Write-Host $_
			$ret = $_.EndPoint.Line
		}
	}
	
	return $ret	
}

function Add-Text([string]$type = "", [string]$methodName, [string]$text){		
	$m = Get-LineOfMethod($type,$methodName)
	Write-Host $m
	return $m	
}

function Add-AssemblyReferenceToProject($project, $assembly){
	(Get-Project $project).Object.References.Add($assembly)
}

function Add-ProjectReferenceToProject($project, $reference){
	(Get-Project $project).Object.References.AddProject((Get-Project $reference))
}

function Has-Package($project, $package){
	return (get-package | Select-Object -ExpandProperty ID) -contains $package;
}

function Add-ClassLibraryToSolution($projectName, $path, $sln){	
	if(($DTE.Solution.Projects | Select-Object -ExpandProperty Name) -notcontains $projectName){
		Write-Host "Creating project" $projectName
		$templatePath = $sln.GetProjectTemplate("ClassLibrary.zip","CSharp")						
		$sln.AddFromTemplate($templatePath, $path+$projectName,$projectName)
		$file = Get-ProjectItem "Class1.cs" -Project $projectName
		$file.Remove()
		$testPath = $path + $projectName + "\Class1.cs"
		#Write-Host $testPath
		if(Test-Path $testPath){
			Remove-Item $testPath
		}
	}	
}

function Add-Template($projectName, $outputPath, $template, [switch]$force, $templateFolders){
	Add-ProjectItemViaTemplate $outputPath -Template $template `
		-Model @{ Namespace = $namespace } `
		-SuccessMessage "Successfully Added $template at {0}" `
		-Project $projectName `
		-Force:$Force `
		-TemplateFolders $templateFolders
}

function Add-TemplateWithModel($projectName, $outputPath, $template, $model, $force, $templateFolders){
		
	Add-ProjectItemViaTemplate $outputPath -Template $template `
		-Model $model `
		-SuccessMessage "Successfully Added $template at {0}" `
		-Project $projectName `
		-Force:$Force `
		-TemplateFolders $templateFolders
}

function Add-NamespacesToHost($projectName) {
	##############################################################
	# NAMESPACE
	##############################################################
	$global:namespace = (Get-Project $ProjectName).Properties.Item("DefaultNamespace").Value
	$global:rootNamespace = $namespace
	$dotIX = $namespace.LastIndexOf('.')
	if($dotIX -gt 0){
		$global:rootNamespace = $namespace.Substring(0,$namespace.LastIndexOf('.'))
	}

	##############################################################
	# Project Name
	##############################################################
	
}

Export-ModuleMember Get-Domain
Export-ModuleMember Get-Class
Export-ModuleMember Get-LineOfMethod
Export-ModuleMember Get-Properties
Export-ModuleMember Add-CodeToMethod
Export-ModuleMember Add-Namespace
Export-ModuleMember Add-ProjectReferenceToProject
Export-ModuleMember Add-AssemblyReferenceToProject
Export-ModuleMember Has-Package
Export-ModuleMember Add-ClassLibraryToSolution
Export-ModuleMember Add-NamespacesToHost
Export-ModuleMember Add-Template
Export-ModuleMember Add-TemplateWithModel
