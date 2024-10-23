function Setup-Certs {
    # Path to store the combined certificates
    $certPath = "$env:USERPROFILE\.certs\all.pem"
    $certDir = Split-Path -Parent $certPath

    # Create directory if it doesn't exist
    if (-not (Test-Path $certDir)) {
        New-Item -ItemType Directory -Path $certDir
    }

    # Combine the system certificates (using certutil for Windows)
    certutil -generateSSTFromWU roots.sst
    certutil -dump roots.sst > $certPath
    Remove-Item roots.sst

    # Configure environment variables for commonly used tools
    $env:GIT_SSL_CAINFO = $certPath
    [System.Environment]::SetEnvironmentVariable('GIT_SSL_CAINFO', $certPath, [System.EnvironmentVariableTarget]::User)
    
    $env:AWS_CA_BUNDLE = $certPath
    [System.Environment]::SetEnvironmentVariable('AWS_CA_BUNDLE', $certPath, [System.EnvironmentVariableTarget]::User)

    $env:NODE_EXTRA_CA_CERTS = $certPath
    [System.Environment]::SetEnvironmentVariable('NODE_EXTRA_CA_CERTS', $certPath, [System.EnvironmentVariableTarget]::User)

    # Configure npm and yarn to use the certificates
    npm config set cafile $certPath -g
    npm config set strict-ssl true -g
}

# Call the function
Setup-Certs