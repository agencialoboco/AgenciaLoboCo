# Agência Lobo & Co — Site institucional

Site institucional estático da **Agência Lobo & Co** (marketing digital, Rio de Janeiro).
HTML/CSS/JS puro, sem build e sem dependências.

- **Identidade:** fundo grafite `#0E1217`, acento âmbar, tipografia Poppins.
- **Conteúdo:** site WordPress antigo + Mídia Kit + Portfólio.
- **Marca em SVG:** logo, favicon e og-image são vetoriais (recriados conforme `agencia.md`),
  então o site renderiza **sem precisar rodar nenhum script**.
- **SEO:** title/description, Open Graph, JSON-LD, `sitemap.xml`, `robots.txt`.
- **Acessibilidade:** HTML semântico, skip-link, foco visível, contraste AA, `prefers-reduced-motion`.

## Estrutura

```
AgenciaLoboCo/
├── index.html            # página única (todas as seções)
├── styles.css            # estilos (mobile-first)
├── script.js             # menu mobile + ano + hook de tracking
├── robots.txt · sitemap.xml · site.webmanifest · _headers
├── preparar-assets.ps1   # copia os 2 PDFs (Materiais)
├── publicar-github.ps1   # publica tudo no GitHub de uma vez
└── assets/
    ├── img/  logo-horizontal.svg · emblema.svg · favicon.svg · og-image.svg
    └── docs/ (mídia kit e portfólio em PDF — via preparar-assets.ps1)
```

## O que já está pronto x o que falta

- **Pronto (sem ação):** todo o site e a marca (SVG). Abra `index.html` no navegador e já funciona.
- **Falta (binário, precisa rodar 1 comando):** os 2 PDFs de download da seção "Materiais".
- **Publicação:** GitHub via `publicar-github.ps1` (Cloudflare fica para depois, quando o site estiver fechado).

## Publicar no GitHub (conta `agencialoboco`)

O nome pedido "AgenciaLobo&Co" não é válido no GitHub (`&` não é aceito). Repositório: **`AgenciaLoboCo`**.

Autenticação (uma vez só):

```powershell
gh auth login      # GitHub.com > HTTPS > Login with a web browser
```

Depois, um único comando faz tudo (copia PDFs + git init + commit + push):

```powershell
powershell -ExecutionPolicy Bypass -File .\publicar-github.ps1
```

Sai em: `https://github.com/agencialoboco/AgenciaLoboCo`

### Sobre token de acesso
- **Jeito recomendado (sem token manual):** `gh auth login` pelo navegador.
- **Se preferir token:** gere um *Personal Access Token (classic)* em
  `github.com/settings/tokens` com o escopo **`repo`** e use-o como senha quando o `git push` pedir.

## Cloudflare Pages (adiado)

Deixado para depois de finalizar o site, conforme combinado. Quando for a hora:
conectar o repo `AgenciaLoboCo` em Workers & Pages → Pages → Connect to Git
(preset None, output `/`) para deploy automático a cada push.
