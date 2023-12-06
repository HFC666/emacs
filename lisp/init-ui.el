(load-theme `dracula t)
(use-package smart-mode-line
  :init
  (setq sml/no-confirm-load-theme t
        sml/theme 'respectful)
  (sml/setup))
(provide `init-ui)
