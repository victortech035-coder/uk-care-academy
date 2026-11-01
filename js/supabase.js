(() => {
  const cfg = window.APP_CONFIG || {};
  const ready = window.supabase && cfg.SUPABASE_URL && cfg.SUPABASE_ANON_KEY &&
    !cfg.SUPABASE_URL.includes("YOUR_") && !cfg.SUPABASE_ANON_KEY.includes("YOUR_");
  window.db = ready ? window.supabase.createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY) : null;
  window.authRequiredMessage = "Connect your Supabase project first. See README.md for setup.";
})();