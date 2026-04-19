# Como Criar Repositorio no GitHub com GH CLI

Este guia mostra como instalar o `gh` (GitHub CLI) no Windows e Linux e, em seguida, criar um repositorio via terminal.

## 1. Instalar o GH no Windows

Opcao com `winget`:

```powershell
winget install --id GitHub.cli
```

Opcao com `choco`:

```powershell
choco install gh
```

## 2. Instalar o GH no Linux

Ubuntu/Debian:

```bash
sudo apt update
sudo apt install gh -y
```

Fedora:

```bash
sudo dnf install gh -y
```

Arch Linux:

```bash
sudo pacman -S gh
```

## 3. Autenticar no GitHub

Depois da instalacao, faca login no GitHub:

```bash
gh auth login
```

## 4. Criar um novo repositorio

Dentro da pasta do projeto que voce quer publicar:

```bash
gh repo create nome-do-repositorio --private --source . --remote origin --push
```

Se quiser criar como publico, troque `--private` por `--public`.

### Observacao importante sobre `--push`

O parametro `--push` so funciona quando ja existe pelo menos um commit local.
Se o repositorio estiver vazio, execute:

```bash
git add .
git commit -m "chore: estrutura inicial do repositorio"
git branch -M main
git push -u origin main
```

Se o Git solicitar identificacao, configure antes do commit:

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu-email@exemplo.com"
```

## 5. Criar repositorio pelo browser (site do GitHub)

Se preferir, voce pode criar o repositorio direto pela interface web:

1. Acesse `https://github.com` e faca login.
2. Clique no botao `New` (ou `+` no canto superior direito > `New repository`).
3. Preencha o campo `Repository name`.
4. Escolha a visibilidade: `Public` ou `Private`.
5. (Opcional) Marque `Add a README file`.
6. Clique em `Create repository`.

Depois disso, se seu projeto ja existir localmente, conecte o remoto e envie:

```bash
git remote add origin https://github.com/seu-usuario/nome-do-repositorio.git
git branch -M main
git push -u origin main
```
