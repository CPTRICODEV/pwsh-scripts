function Show-PallepadehatBanner() {
    @"
    ooooooooo.             oooo  oooo                                       .o8            oooo                      .   
    `888   `Y88.           `888  `888                                      "888            `888                    .o8   
     888   .d88'  .oooo.    888   888   .ooooo.  oo.ooooo.   .oooo.    .oooo888   .ooooo.   888 .oo.    .oooo.   .o888oo 
     888ooo88P'  `P  )88b   888   888  d88' `88b  888' `88b `P  )88b  d88' `888  d88' `88b  888P"Y88b  `P  )88b    888   
     888          .oP"888   888   888  888ooo888  888   888  .oP"888  888   888  888ooo888  888   888   .oP"888    888   
     888         d8(  888   888   888  888    .o  888   888 d8(  888  888   888  888    .o  888   888  d8(  888    888 . 
    o888o        `Y888""8o o888o o888o `Y8bod8P'  888bod8P' `Y888""8o `Y8bod88P" `Y8bod8P' o888o o888o `Y888""8o   "888" 
                                                  888                                                                    
                                                 o888o                                                                                                      
"@    
}

function Check-SSLCertificateExpiry($url) {
    try {
        Show-PallepadehatBanner
        Write-Host "Checking SSL certificate for $url..."
        
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
