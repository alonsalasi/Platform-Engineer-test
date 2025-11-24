# Keep port-forward alive
while ($true) {
    # Kill any existing port-forward on 8080
    Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue | ForEach-Object {
        Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "Starting port-forward..." -ForegroundColor Cyan
    kubectl port-forward -n ecs-platform svc/ecs-manager 8080:8080
    Write-Host "Port-forward died, restarting in 2 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
}
