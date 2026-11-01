document.addEventListener("DOMContentLoaded", () => {
  const toggle = document.getElementById("menuToggle"), nav = document.getElementById("mainNav");
  if (toggle && nav) toggle.addEventListener("click", () => nav.classList.toggle("open"));
  const year = document.getElementById("year"); if (year) year.textContent = new Date().getFullYear();
  document.querySelectorAll("[data-auth-status]").forEach(async el => {
    if (!window.db) { el.textContent = "Supabase not configured"; return; }
    const { data } = await db.auth.getUser(); el.textContent = data.user ? `Signed in as ${data.user.email}` : "Not signed in";
  });
});