function Get-CustomLogs {
    [CmdletBinding()]
    param(
        [Parameter()]
        [datetime] $StartTime,

        [Parameter()]
        [datetime] $EndTime
    )

    begin{

        $DateScanned = Get-Date -Format u
        Write-Information -InformationAction Continue -MessageData ("Started Get-EventLogs at {0}" -f $DateScanned)

        $stopwatch = New-Object System.Diagnostics.Stopwatch
        $stopwatch.Start()

        if(!($StartTime)){
            $StartTime = (Get-Date) - (New-TimeSpan -Hours 2)
        }

        if(!($EndTime)){
            $EndTime = (Get-Date)
        }
    }

    process{

            $Logs = Get-WinEvent -ListLog * | Where-Object { ($_.RecordCount -gt 0) }

            $ResultsArray = Foreach ($Log in $Logs){

                Get-WinEvent -FilterHashTable @{ LogName=$Log.LogName; StartTime=$StartTime; EndTime=$EndTime } -ErrorAction SilentlyContinue
            }

            foreach ($Result in $ResultsArray) {
                $Result | Add-Member -MemberType NoteProperty -Name "Host" -Value $env:COMPUTERNAME
                $Result | Add-Member -MemberType NoteProperty -Name "DateScanned" -Value $DateScanned
            }

            return $ResultsArray | Select-Object Host, DateScanned, TimeCreated
	  }
    end{

        $elapsed = $stopwatch.Elapsed

        Write-Verbose ("Total time elapsed: {0}" -f $elapsed)
        Write-Verbose ("Ended at {0}" -f (Get-Date -Format u))
    }
}