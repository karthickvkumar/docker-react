# Use the official Microsoft IIS base image
# FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2019
FROM mcr.microsoft.com/windows/servercore/iis

# Set environment variables
ENV APP_DIR="C:\\inetpub\\wwwroot"

# Copy the build output to the IIS directory
COPY build ${APP_DIR}

# Optional: Copy a custom applicationHost.config file if you need to override default IIS settings
# COPY applicationHost.config C:\\inetpub\\wwwroot\\

# Copy custom applicationHost.config file
COPY applicationHost.config ${APP_DIR}

# Expose the custom port (e.g., 8080)
EXPOSE 8085

COPY IIS/rewrite_amd64_en-US.msi .
# Install IIS URL Rewrite Module
RUN msiexec.exe /i rewrite_amd64_en-US.msi /L*v installLog.log
RUN powershell -Command \
	Remove-Item ./rewrite_amd64_en-US.msi -Force


# Set up a health check (optional)
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 CMD powershell -command `if ((Get-Service w3svc).Status -ne 'Running') {exit 1}`

# Start IIS
CMD ["cmd", "/c", "C:\\ServiceMonitor.exe w3svc"]
