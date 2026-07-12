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
