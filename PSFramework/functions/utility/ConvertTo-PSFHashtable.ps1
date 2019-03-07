﻿function ConvertTo-PSFHashtable
{
<#
	.SYNOPSIS
		Converts an object into a hashtable.
	
	.DESCRIPTION
		Converts an object into a hashtable.
		Can exclude individual properties from being included.
	
	.PARAMETER Exclude
		The propertynames to exclude.
		Must be full property-names, no wildcard/regex matching.
	
	.PARAMETER InputObject
		The object(s) to convert
	
	.EXAMPLE
		PS C:\> Get-ChildItem | ConvertTo-PSFHashtable
	
		Scans all items in the current path and converts those objects into hashtables.
#>
	[OutputType([System.Collections.Hashtable])]
	[CmdletBinding()]
	Param (
		[string[]]
		$Exclude,
		
		[string[]]
		$Include,
		
		[Parameter(ValueFromPipeline = $true)]
		$InputObject
	)
	
	process
	{
		foreach ($item in $InputObject)
		{
			if ($null -eq $item) { continue }
			if ($item -is [System.Collections.Hashtable])
			{
				$hashTable = $item.Clone()
				foreach ($name in $Exclude) { $hashTable.Remove($name) }
				if ($Include)
				{
					foreach ($key in ([object[]]$hashTable.Keys))
					{
						if ($key -notin $Include) { $hashTable.Remove($key) }
					}
				}
				$hashTable
			}
			elseif ($item -is [System.Collections.IDictionary])
			{
				$hashTable = @{ }
				foreach ($name in $item.Keys)
				{
					if ($name -in $Exclude) { continue }
					if ($Include -and ($name -notin $Include)) { continue }
					$hashTable[$name] = $item[$name]
				}
				$hashTable
			}
			else
			{
				$hashTable = @{ }
				foreach ($property in $item.PSObject.Properties)
				{
					if ($property.Name -in $Exclude) { continue }
					if ($Include -and ($property.Name -notin $Include)) { continue }
					
					$hashTable[$property.Name] = $property.Value
				}
				$hashTable
			}
		}
	}
}