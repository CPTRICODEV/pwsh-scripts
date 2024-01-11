function Check-SSLCertificateExpiration($url) {
    try {
        $request = [System.Net.WebRequest]::Create($url)
        $request.Method = "HEAD"
        $response = $request.GetResponse()
        $cert = $response.GetResponseStream().GetLifetimeService()

        $expirationDate = [System.Security.Cryptography.X509Certificates.X509Certificate2]$cert | Select-Object -ExpandProperty NotAfter
        $timeUntilExpiration = $expirationDate - (Get-Date)

        $years = [math]::floor($timeUntilExpiration.Days / 365)
        $months = $timeUntilExpiration.Days % 365 / 30
        $days = $timeUntilExpiration.Days % 30

        Write-Output "SSL certificate for $url expires on: $expirationDate"

        $formattedTime = "{0} years, {1} months, {2} days" -f $years, $months, $days
        Write-Output "Time until expiration: $formattedTime"
    }
    catch {
        Write-Error "Error: $_"
    }
}

# Example: Check SSL certificate for "https://www.example.com"
Check-SSLCertificateExpiration "https://pjtoolkit.vercel.app"
