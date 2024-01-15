function Check-SSLCertificateExpiry($url) {
    try {
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
            Write-Host "SSL Certificate for $url will expire on: $expirationDate"
        } else {
            Write-Host "Unable to retrieve SSL certificate information for $url. Certificate not available."
        }

        # Close the TcpClient
        $tcpClient.Close()
    } catch {
        Write-Host "Error: $_"
    }
}

# Example usage
$urlToCheck = "pjtoolkit.vercel.app"
Check-SSLCertificateExpiry $urlToCheck
