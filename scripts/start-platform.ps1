Write-Host "🚀 Starting ECS Platform Manager..." -ForegroundColor Cyan

# Start Minikube
Write-Host "`n📦 Starting Minikube..." -ForegroundColor Yellow
& 'C:\Program Files\Kubernetes\Minikube\minikube.exe' start --driver=docker

# Create namespace
Write-Host "`n🔧 Creating namespace..." -ForegroundColor Yellow
kubectl create namespace ecs-platform

# Create secrets
Write-Host "`n🔐 Creating secrets..." -ForegroundColor Yellow
$AWS_ACCESS_KEY = Read-Host "Enter AWS Access Key ID"
$AWS_SECRET_KEY = Read-Host "Enter AWS Secret Access Key" -AsSecureString
$AWS_SECRET_KEY_PLAIN = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($AWS_SECRET_KEY))

$GITHUB_TOKEN = Read-Host "Enter GitHub PAT Token" -AsSecureString
$GITHUB_TOKEN_PLAIN = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($GITHUB_TOKEN))

kubectl create secret generic aws-credentials `
    --from-literal=AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY `
    --from-literal=AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY_PLAIN `
    -n ecs-platform

kubectl create secret generic github-token `
    --from-literal=GITHUB_TOKEN=$GITHUB_TOKEN_PLAIN `
    --from-literal=GITHUB_REPO="alonsalasi/Platform-Engineer-test" `
    -n ecs-platform

# Deploy platform
Write-Host "`n🚀 Deploying platform..." -ForegroundColor Yellow
kubectl apply -f k8s/ecs-manager-configmap.yaml
kubectl apply -f k8s/ecs-manager-deployment.yaml
kubectl apply -f k8s/ecs-manager-service.yaml

# Wait for pod
Write-Host "`n⏳ Waiting for pod to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=ecs-manager -n ecs-platform --timeout=120s

# Start port-forward
Write-Host "`n🌐 Starting port-forward on http://localhost:8080..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "kubectl port-forward -n ecs-platform service/ecs-manager 8080:8080"

Write-Host "`n✅ Platform started successfully!" -ForegroundColor Green
Write-Host "🌐 Open browser: http://localhost:8080" -ForegroundColor Cyan
