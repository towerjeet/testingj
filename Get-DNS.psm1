function Get-DNS {

    [CmdletBinding()]
    param(
    )

    begin{

        $DateScanned = Get-Date -Format u
        Write-Information -InformationAction Continue -MessageData ("Started Get-DNS at {0}" -f $DateScanned)

        $stopwatch = New-Object System.Diagnostics.Stopwatch
        $stopwatch.Start()

        enum recordType {
            A = 1
            NS = 2
            CNAME = 5
            SOA = 6
            WKS = 11
            PTR = 12
            HINFO = 13
            MINFO = 14
            MX = 15
            TXT = 16
            AAAA = 28
            SRV = 33
            ALL = 255
        }

        enum recordStatus {
            Success = 0
            NotExist = 9003
            NoRecords = 9501
        }

        enum recordResponse {
            Question = 0
            Answer = 1
            Authority = 2
            Additional = 3
        }
    }

    process{

        $ResultsArray = Get-DnsClientCache

        foreach ($Result in $ResultsArray) {
            $Result | Add-Member -MemberType NoteProperty -Name "Host" -Value $env:COMPUTERNAME
            $Result | Add-Member -MemberType NoteProperty -Name "DateScanned" -Value $DateScanned
            $Result | Add-Member -MemberType NoteProperty -Name "RecordType" -Value ([recordType]$Result.Type).ToString()
            $Result | Add-Member -MemberType NoteProperty -Name "RecordStatus" -Value ([recordStatus]$Result.Status).ToString()
            $Result | Add-Member -MemberType NoteProperty -Name "RecordResponse" -Value ([recordResponse]$Result.Section).ToString()
        }

        return $ResultsArray | Select-Object Host, DateScanned, Status, RecordStatus, DataLength, Section, RecordResponse, TimeToLive, Type, RecordType, Data, Entry, Name
    }

    end{
        
        $elapsed = $stopwatch.Elapsed

        Write-Verbose ("Total time elapsed: {0}" -f $elapsed)
        Write-Verbose ("Ended at {0}" -f (Get-Date -Format u))
    }
}