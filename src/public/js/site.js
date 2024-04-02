const menuOpen = document.getElementById("menu-open");
const menuClose = document.getElementById("menu-close");
const siteNavigation = document.getElementById("primary-navigation");
const dim = document.getElementById("dim");

menuOpen.addEventListener("click", () => {
    // let isOpened = menuOpen.getAttribute('aria-expanded') === "true";

    openMenu();
});

menuClose.addEventListener("click", () => {
    closeMenu();
});

dim.addEventListener("click", () => {
    closeMenu();

});


function openMenu() {
    menuOpen.setAttribute('aria-expanded', 'true');
    siteNavigation.setAttribute("data-state", "opened");
}

function closeMenu() {
    menuOpen.setAttribute('aria-expanded', 'false');
    siteNavigation.setAttribute("data-state", "closing");

    siteNavigation.addEventListener("animationend",() => {
        if (siteNavigation.getAttribute('data-state') === "closing") {
            siteNavigation.setAttribute('data-state', 'closed');
        }
    }, {once:true});
}