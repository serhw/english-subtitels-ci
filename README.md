# English Subtitles API - CI/CD Deployment

This repository contains the CI/CD setup for deploying the English Subtitles API to Docker Swarm on a Hetzner VM using GitHub Actions.

## 🚀 Deployment Overview

The deployment pipeline automatically:
- Builds Docker images from your code
- Pushes images to GitHub Container Registry (GHCR)
- Deploys to Docker Swarm on your Hetzner VM (128.140.2.122)
- Uses rolling updates with zero downtime
- Includes health checks and automatic rollback

## 📋 Prerequisites

### 1. Hetzner VM Setup

Run the setup script on your Hetzner VM:

```bash
curl -fsSL https://raw.githubusercontent.com/serhw/english-subtitels-ci/main/setup-swarm.sh | bash
```

This script will:
- Install Docker and Docker Compose
- Initialize Docker Swarm
- Create deployment directories
- Install required tools

### 2. GitHub Secrets Configuration

Add these secrets to your GitHub repository (`Settings` > `Secrets and variables` > `Actions`):

| Secret Name | Value | Description |
|-------------|--------|-------------|
| `DEPLOY_HOST` | `128.140.2.122` | Your Hetzner VM IP address |
| `DEPLOY_USER` | `root` or your username | SSH username for the VM |
| `DEPLOY_SSH_KEY` | Your private SSH key | SSH private key for accessing the VM |

### 3. SSH Key Setup

Generate an SSH key pair for deployment:

```bash
# On your local machine
ssh-keygen -t ed25519 -C "deployment@english-subtitels-ci" -f ~/.ssh/english-subtitels-deploy

# Copy public key to your Hetzner VM
ssh-copy-id -i ~/.ssh/english-subtitels-deploy.pub user@128.140.2.122
```

Add the **private key** content to the `DEPLOY_SSH_KEY` GitHub secret.

## 🏗️ Architecture

```
┌─────────────────┐    ┌───────────────────┐    ┌─────────────────────┐
│   GitHub        │    │   Hetzner VM      │    │   Docker Swarm      │
│   Actions       │────▶│   128.140.2.122   │────▶│   english-subtitels │
│   Runner        │    │                   │    │   Stack             │
└─────────────────┘    └───────────────────┘    └─────────────────────┘
```

### Services:
- **API Service**: Your Node.js application (2 replicas for HA)
- **NGINX**: Load balancer and reverse proxy
- **Health Checks**: Automated health monitoring

## 🔄 Deployment Process

### Automatic Deployment

Every push to the `main` branch triggers automatic deployment:

1. **Build Phase**: Creates Docker image
2. **Push Phase**: Uploads to GitHub Container Registry
3. **Deploy Phase**: Updates Docker Swarm services

### Manual Deployment

You can also trigger deployment manually:

1. Go to `Actions` tab in GitHub
2. Select "Deploy to Docker Swarm"
3. Click "Run workflow"

## 🛠️ Local Development

```bash
# Clone the repository
git clone https://github.com/serhw/english-subtitels-ci.git
cd english-subtitels-ci

# Install dependencies
npm install

# Run in development mode
npm run dev

# Build Docker image locally
docker build -t english-subtitels-api .

# Test with Docker Compose
docker-compose -f docker-compose.production.yml up
```

## 📊 Monitoring

### Service Status
```bash
# Check stack status
docker stack services english-subtitels

# Check service logs
docker service logs english-subtitels_api
docker service logs english-subtitels_nginx
```

### Health Checks
- API Health: `http://128.140.2.122/health`
- Service Status: `http://128.140.2.122/api/subtitles`

## 🔧 Configuration

### Environment Variables

Modify `docker-compose.production.yml` to add environment variables:

```yaml
services:
  api:
    environment:
      - NODE_ENV=production
      - PORT=3000
      - DATABASE_URL=your_database_url
      - API_KEY=your_api_key
```

### Scaling Services

Scale your API service:

```bash
docker service scale english-subtitels_api=3
```

## 🚨 Troubleshooting

### Common Issues

1. **Deployment fails with SSH errors**
   - Verify SSH key is correct in GitHub secrets
   - Check VM accessibility: `ssh user@128.140.2.122`

2. **Services not starting**
   - Check logs: `docker service logs english-subtitels_api`
   - Verify image availability: `docker images`

3. **Health check failures**
   - Ensure your app responds to `/health` endpoint
   - Check port configuration

### Rollback

If deployment fails, rollback to previous version:

```bash
docker service rollback english-subtitels_api
```

## 📝 Files Structure

```
.
├── .github/workflows/deploy.yml    # GitHub Actions workflow
├── docker-compose.production.yml   # Docker Swarm configuration
├── Dockerfile                      # Container build instructions
├── nginx.conf                     # NGINX configuration
├── package.json                   # Node.js dependencies
├── server.js                      # Application entry point
├── deploy.sh                      # Manual deployment script
├── setup-swarm.sh                # VM setup script
└── README.md                      # This file
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📜 License

This project is licensed under the MIT License.

---

**Need help?** Check the [GitHub Actions logs](../../actions) or create an [issue](../../issues).
