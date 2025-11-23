# Keep port-forward alive
while ($true) {
    Write-Host "Starting port-forward..." -ForegroundColor Cyan
    kubectl port-forward -n ecs-platform svc/ecs-manager 8080:8080
    Write-Host "Port-forward died, restarting in 2 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
}
