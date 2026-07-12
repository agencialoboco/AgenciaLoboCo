# Agência Lobo & Co — Site institucional

Site institucional estático da **Agência Lobo & Co** (marketing digital, Rio de Janeiro).
HTML/CSS/JS puro, sem build e sem dependências — pronto para o Cloudflare Pages.

- **Identidade:** fundo grafite `#0E1217`, acento âmbar, tipografia Poppins.
- **Conteúdo:** herdado e melhorado a partir do site WordPress antigo + Mídia Kit + Portfólio.
- **Performance:** zero JS de terceiros, fontes com `preload`, imagens com `width/height` e `lazy`.
- **SEO:** title/description, Open Graph, JSON-LD (ProfessionalService), `sitemap.xml`, `robots.txt`.
- **Acessibilidade:** HTML semântico, skip-link, foco visível, contraste AA, `prefers-reduced-motion`.

## Estrutura

```
AgenciaLoboCo/
├── index.html            # página única (todas as seções)
├── styles.css            # estilos (mobile-first)
├── script.js             # menu mobile + ano + hook de tracking
├── robots.txt
├── sitemap.xml
├── site.webmanifest
├── _headers              # headers de segurança/cache (Cloudflare Pages)
├── preparar-assets.ps1   # copia/otimiza logos e PDFs para /assets
└── assets/
    ├── img/              # logos, favicon, og-image (geradas pelo script)
    └── docs/             # mídia kit e portfólio em PDF
```

## Passo 1 — Preparar os assets (obrigatório antes de publicar)

As logos e PDFs oficiais ficam fora do projeto. Rode uma vez para copiá-los/otimizá-los:

```powershell
powershell -ExecutionPolicy Bypass -File .\preparar-assets.ps1
```

Isso gera em `assets/img`: `logo-horizontal-positiva.png`, `logo-positiva.png`, `favicon.png`, `og-image.png`
e em `assets/docs`: `midia-kit-agencia-lobo-co.pdf`, `portfolio-agencia-lobo-co.pdf`.

> Regra da marca: sobre o fundo escuro do site usa-se sempre a logo **POSITIVA (branca)**. Não usar a negativa (preta) aqui.

## Passo 2 — GitHub

O nome pedido "AgenciaLobo&Co" não é válido no GitHub (`&` não é aceito). Repositório: **`AgenciaLoboCo`**.

Com o GitHub CLI (`gh`) autenticado:

```powershell
git init
git add .
git commit -m "Site institucional da Agência Lobo & Co"
gh repo create AgenciaLoboCo --public --source . --push
```

Sem o `gh`, crie o repo pelo site do GitHub e depois:

```powershell
git init
git add .
git commit -m "Site institucional da Agência Lobo & Co"
git branch -M main
git remote add origin https://github.com/<seu-usuario>/AgenciaLoboCo.git
git push -u origin main
```

## Passo 3 — Cloudflare Pages

**Opção A (recomendada): conectar o repositório no painel.** Deploy automático a cada `git push`.
1. Cloudflare Dashboard → Workers & Pages → Create → Pages → Connect to Git.
2. Selecione o repositório `AgenciaLoboCo`.
3. Framework preset: **None**. Build command: *(vazio)*. Output directory: **`/`** (raiz).
4. Save and Deploy.

**Opção B: deploy direto via Wrangler** (precisa de login interativo uma vez):

```powershell
npx wrangler login
npx wrangler pages deploy . --project-name agencialoboco
```

O site sai em `https://agencialoboco.pages.dev` (ou o subdomínio que o Pages gerar).

## Domínio próprio (futuro)

No projeto do Pages → Custom domains → adicionar (ex.: `agencialobo.co` ou `www.agencialobo.co`)
e apontar o DNS na Cloudflare (registro `CNAME`/`A` proxied). SSL: **Completo (estrito)**.
Depois, trocar as URLs `agencialoboco.pages.dev` por o domínio final em `index.html`, `sitemap.xml` e `robots.txt`.
