{ ... }:
let
  language_locale = "en_GB.UTF-8";
  actual_locale = "nl_NL.UTF-8";
  extraLocales = map (l: "${l}/UTF-8") ([ actual_locale ] ++ [ "pl_PL.UTF-8" ]);
in
{
  i18n = {
    defaultLocale = language_locale;
    extraLocales = extraLocales;
    extraLocaleSettings = {
      LC_CTYPE = language_locale;
      LC_ADDRESS = actual_locale;
      LC_MESSAGES = language_locale;
      LC_MONETARY = actual_locale;
      LC_NAME = actual_locale;
      LC_NUMERIC = actual_locale;
      LC_PAPER = actual_locale;
      LC_TELEPHONE = actual_locale;
      LC_TIME = actual_locale;
      LC_COLLATE = actual_locale;
    };
  };
}
