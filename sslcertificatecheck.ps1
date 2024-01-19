function Show-Banner() {
    @"                                                                                                                          
    _____ _____ _   _ _____ _____  ___  
    /  ___|  ___| \ | |_   _|_   _|/ _ \ 
    \ `--.| |__ |  \| | | |   | | / /_\ \
     `--. \  __|| . ` | | |   | | |  _  |
    /\__/ / |___| |\  | | |  _| |_| | | |
    \____/\____/\_| \_/ \_/  \___/\_| |_/   
    Powered By @PJ - Copyright©2024                                                                                                                                                                                                                                                              
"@    
}

function CheckSSLCertificateExpiry() {
    [CmdletBinding()]

    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$url,

        [Parameter()]
        [int]$port = 443,

        [Parameter()]
        [int]$alertThreshold = 30,

        [Parameter()]
        [switch]$selfsigned
    )

    try {
        Show-Banner
        Write-Host "Checking SSL certificate for $url..."

        # Set up a TcpClient to connect to the server
        $tcpClient = [System.Net.Sockets.TcpClient]::new()
        $tcpClient.Connect($url, $port)

        if ($selfsigned.IsPresent) {
            # Set up an SslStream to negotiate the SSL/TLS handshake with the callback to allow self-signed certificates
            $sslStream = [System.Net.Security.SslStream]::new($tcpClient.GetStream(), $false, { $true })        
        }
        else {
            # Set up an SslStream to negotiate the SSL/TLS handshake
            $sslStream = [System.Net.Security.SslStream]::new($tcpClient.GetStream())
        }       
        $sslStream.AuthenticateAsClient($url)

        # Get the SSL certificate from the SslStream
        $sslCertificate = $sslStream.RemoteCertificate

        # Check if the certificate is null (not available)
        if ($sslCertificate -ne $null) {
            # Check the expiration date
            $expirationDate = $sslCertificate.NotAfter
            $expirationDateString = $sslCertificate.GetExpirationDateString()
        
            # Calculate the remaining days until expiration
            $daysUntilExpiration = ($expirationDate - (Get-Date)).Days
		 
            Write-Host "SSL Certificate for $url will expire on: $expirationDateString in $daysUntilExpiration days"
             
            # Check if the certificate is expiring soon and send an alert
            if ($daysUntilExpiration -lt $alertThreshold) {
                $subject = "Certificate Expiration Alert"
                $body = "The self-signed certificate for $url is expiring in $daysUntilExpiration days. Please renew or replace it."
                $smtpServer = "ip/name"
                $smtpFrom = "mail sender"
                $smtpTo = "mail recipient"

                Send-MailMessage -SmtpServer $smtpServer -From $smtpFrom -To $smtpTo -Subject $subject -Body $body -BodyAsHtml
            }
        }
        else {
            Write-Host "Unable to retrieve SSL certificate information for $url. Certificate not available."
        }
        # Close the Sessions
        $tcpClient.Close()
        $sslStream.Close()
    }
    catch {
        Write-Host "Error: $_"
    }
}

#Parameters:
# URL is mandatory.
# Port is default 443, but can be changed.
# A Public cert is default, apply -selfsigned to check a self signed certificate.(without chain validation) 
# Alertthreshold is default to 30 days remaning. 

#Examples
#CheckSSLCertificateExpiry -url "google.com"
#CheckSSLCertificateExpiry -url "ip/name" -selfsigned 
#CheckSSLCertificateExpiry -url "ip/name" -port 3000 -alertThreshold 50