function Show-PallepadehatBanner() {
    @"                                                                                                                          
    _____ _____ _   _ _____ _____  ___  
    /  ___|  ___| \ | |_   _|_   _|/ _ \ 
    \ `--.| |__ |  \| | | |   | | / /_\ \
     `--. \  __|| . ` | | |   | | |  _  |
    /\__/ / |___| |\  | | |  _| |_| | | |
    \____/\____/\_| \_/ \_/  \___/\_| |_/                                                                                                                                                                                                                                                                 
"@    
}

function Check-SSLCertificateExpiry($url) {
    try {
        Show-PallepadehatBanner
        Write-Host "Checking public SSL certificate for $url..."

        # Set up a TcpClient to connect to the server
        $tcpClient = [System.Net.Sockets.TcpClient]::new()
        $tcpClient.Connect("$url", 443)

        # Set up an SslStream to negotiate the SSL/TLS handshake
        $sslStream = [System.Net.Security.SslStream]::new($tcpClient.GetStream())
        $sslStream.AuthenticateAsClient($url)

        # Get the SSL certificate from the SslStream
        $sslCertificate = $sslStream.RemoteCertificate

        # Check if the certificate is null (not available)
        if ($sslCertificate -ne $null) {
            # Check the expiration date
            $expirationDate = $sslCertificate.GetExpirationDateString()
            Write-Host "Public SSL Certificate for $url will expire on: $expirationDate"
        } else {
            Write-Host "Unable to retrieve public SSL certificate information for $url. Certificate not available."
        }

        # Close the TcpClient
        $tcpClient.Close()
    } catch {
        Write-Host "Error: $_"
    }
}

function Check-SelfSignedCertificateExpiry($url) {
    try {
        Show-PallepadehatBanner
        Write-Host "Checking self-signed SSL certificate for $url..."

        # Use the IP address 127.0.0.1 instead of localhost
        $ip = "127.0.0.1"

        # Set up a TcpClient to connect to the server
        $tcpClient = [System.Net.Sockets.TcpClient]::new()
        $tcpClient.Connect("$ip", 3000)

        # Set up an SslStream to negotiate the SSL/TLS handshake with the callback to allow self-signed certificates
        $sslStream = [System.Net.Security.SslStream]::new($tcpClient.GetStream(), $false, { $true })
        $sslStream.AuthenticateAsClient($url)

        # Get the SSL certificate from the SslStream
        $sslCertificate = $sslStream.RemoteCertificate

        # Check if the certificate is null (not available)
        if ($sslCertificate -ne $null) {
            # Check the expiration date
            $expirationDate = $sslCertificate.GetExpirationDateString()
            Write-Host "Self-signed SSL Certificate for $url will expire on: $expirationDate"
        } else {
            Write-Host "Unable to retrieve self-signed SSL certificate information for $url. Certificate not available."
        }

        # Close the TcpClient
        $tcpClient.Close()
    } catch {
        Write-Host "Error: $_"
    }
}

# Prompt for certificate type (self-signed or public)
$checkSelfSigned = Read-Host "Do you want to check a self-signed certificate? (Y/N)"
$urlToCheck = Read-Host "Enter the URL for SSL certificate"
if ($checkSelfSigned -eq 'Y' -or $checkSelfSigned -eq 'y') {
    Check-SelfSignedCertificateExpiry $urlToCheck
} else {
    Check-SSLCertificateExpiry $urlToCheck
}