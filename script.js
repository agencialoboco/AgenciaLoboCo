// Agência Lobo & Co — interações leves (sem dependências externas)
(function () {
  "use strict";

  // Ano dinâmico no rodapé
  var anoEl = document.getElementById("ano");
  if (anoEl) anoEl.textContent = String(new Date().getFullYear());

  // Menu mobile acessível
  var toggle = document.querySelector(".nav__toggle");
  var menu = document.getElementById("menu");

  if (toggle && menu) {
    function closeMenu() {
      menu.classList.remove("is-open");
      toggle.setAttribute("aria-expanded", "false");
      toggle.setAttribute("aria-label", "Abrir menu");
    }

    toggle.addEventListener("click", function () {
      var isOpen = menu.classList.toggle("is-open");
      toggle.setAttribute("aria-expanded", String(isOpen));
      toggle.setAttribute("aria-label", isOpen ? "Fechar menu" : "Abrir menu");
    });

    // Fecha o menu ao clicar num link
    menu.addEventListener("click", function (e) {
      if (e.target.tagName === "A") closeMenu();
    });

    // Fecha com Esc
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape") closeMenu();
    });
  }

  // ------- Formulários → WhatsApp da agência (sem backend) -------
  var WHATS = "5521979716810";

  function abrirWhatsApp(linhas) {
    var texto = linhas.filter(Boolean).join("\n");
    window.open("https://wa.me/" + WHATS + "?text=" + encodeURIComponent(texto), "_blank", "noopener");
  }

  function validar(form) {
    var ok = true;
    form.querySelectorAll("[required]").forEach(function (campo) {
      var vazio = campo.type === "checkbox" ? !campo.checked : !campo.value.trim();
      campo.classList.toggle("is-invalid", vazio);
      if (vazio) ok = false;
    });
    if (!ok) {
      var primeiro = form.querySelector(".is-invalid");
      if (primeiro) primeiro.focus();
    }
    return ok;
  }

  // Form 1: Deixe sua mensagem (+ botão de desconto por divulgação)
  var formMsg = document.getElementById("form-mensagem");
  var btnDivulgacao = document.getElementById("btn-divulgacao");
  var promoNote = document.getElementById("promo-note");
  var veioDeDivulgacao = false;

  if (btnDivulgacao && formMsg) {
    btnDivulgacao.addEventListener("click", function () {
      veioDeDivulgacao = !veioDeDivulgacao;
      btnDivulgacao.setAttribute("aria-pressed", String(veioDeDivulgacao));
      if (promoNote) promoNote.hidden = !veioDeDivulgacao;
      var radioDivulgacao = formMsg.querySelector('input[name="origem"][value="Divulgação"]');
      if (radioDivulgacao) radioDivulgacao.checked = veioDeDivulgacao;
    });
  }

  if (formMsg) {
    formMsg.addEventListener("submit", function (e) {
      e.preventDefault();
      if (!validar(formMsg)) return;
      var origem = formMsg.querySelector('input[name="origem"]:checked');
      abrirWhatsApp([
        "*Mensagem pelo site da Lobo & Co* 🐺",
        "",
        "*Nome:* " + formMsg.nome.value.trim(),
        "*WhatsApp:* " + formMsg.whatsapp.value.trim(),
        formMsg.email.value.trim() ? "*E-mail:* " + formMsg.email.value.trim() : "",
        "*O que deseja:* " + formMsg.desejo.value.trim(),
        origem ? "*Veio por:* " + origem.value : "",
        veioDeDivulgacao ? "🎁 *Acessou via DIVULGAÇÃO — desconto!*" : ""
      ]);
    });
  }

  // Form 2: Solicite uma proposta
  var formProp = document.getElementById("form-proposta");
  if (formProp) {
    formProp.addEventListener("submit", function (e) {
      e.preventDefault();
      if (!validar(formProp)) return;
      abrirWhatsApp([
        "*Solicitação de proposta — site Lobo & Co* 🐺",
        "",
        "*Nome:* " + formProp.nome.value.trim(),
        "*Telefone:* " + formProp.telefone.value.trim(),
        "*E-mail:* " + formProp.email.value.trim(),
        formProp.empresa.value.trim() ? "*Empresa:* " + formProp.empresa.value.trim() : "",
        "*Preferência de contato:* " + formProp.preferencia.value,
        "*Buscando:* " + formProp.busca.value,
        "*Nos encontrou por:* " + formProp.como.value,
        formProp.mensagem.value.trim() ? "*Mensagem:* " + formProp.mensagem.value.trim() : "",
        "✅ Aceitou os termos de uso e política de dados"
      ]);
    });
  }

  // Hook de tracking: dispara evento no dataLayer se houver GTM/GA no futuro.
  // Não coleta nada por conta própria; só padroniza os cliques de conversão.
  document.querySelectorAll("[data-cta]").forEach(function (el) {
    el.addEventListener("click", function () {
      if (window.dataLayer && typeof window.dataLayer.push === "function") {
        window.dataLayer.push({ event: "cta_click", cta_id: el.getAttribute("data-cta") });
      }
    });
  });
})();
