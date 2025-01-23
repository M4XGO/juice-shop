# Infrastructure Juice Shop AWS

Ce projet utilise Terraform pour déployer [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) sur AWS dans la région eu-west-3 (Paris).

## Architecture

L'infrastructure déploie :

- Une instance EC2 t2.micro avec Ubuntu Server AMI
- Un VPC avec CIDR 10.0.0.0/16
- Un sous-réseau public 10.0.0.0/24 
- Une passerelle Internet
- Une table de routage
- Un groupe de sécurité autorisant :
  - HTTP/HTTPS entrant (0.0.0.0/0)  
  - SSH entrant (0.0.0.0/0)
  - Tout le trafic sortant

## Prérequis

- Terraform >= 1.0.0
- Un compte AWS 
- Les credentials AWS configurés dans `.aws/credentials.ini`
- Une paire de clés SSH (deployer-key)

## Déploiement

1. Initialiser Terraform :
```sh
terraform init
```
2. Déployer l'infrastructure :
```sh
terraform apply
```
3. Se connecter à l'instance EC2 :
```sh
ssh -i deployer-key.pem ubuntu@<output de la commande terrafomr>
```

## Nettoyage
Pour supprimer toute l'infrastructure :
```sh
terraform apply --destroy