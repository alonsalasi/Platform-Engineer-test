Write-Host "🛑 Stopping ECS Platform Manager..." -ForegroundColor Red

# Kill port-forward processes
Write-Host "`n🔌 Stopping port-forward..." -ForegroundColor Yellow
Get-Process -Name kubectl -ErrorAction SilentlyContinue | Stop-Process -Force
Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }

# Stop minikube
Write-Host "`n📦 Stopping Minikube..." -ForegroundColor Yellow
& 'C:\Program Files\Kubernetes\Minikube\minikube.exe' stop

# Delete minikube cluster
Write-Host "`n🗑️ Deleting Minikube cluster..." -ForegroundColor Yellow
& 'C:\Program Files\Kubernetes\Minikube\minikube.exe' delete

Write-Host "`n✅ Platform stopped and removed!" -ForegroundColor Green
