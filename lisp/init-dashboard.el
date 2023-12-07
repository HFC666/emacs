(use-package nerd-icons
  ;; :custom
  ;; The Nerd Font you want to use in GUI
  ;; "Symbols Nerd Font Mono" is the default and is recommended
  ;; but you can use any other Nerd Font if you want
  ;; (nerd-icons-font-family "Symbols Nerd Font Mono")
  )

;; use-package with package.el:
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook))
(dashboard-setup-startup-hook)
(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
(setq dashboard-banner-logo-title "Have a nice day!")
;; Set the banner
;; Value can be
;; - nil to display no banner
;; - 'official which displays the official emacs logo
;; - 'logo which displays an alternative emacs logo
;; - 1, 2 or 3 which displays one of the text banners
;; - "path/to/your/image.gif", "path/to/your/image.png", "path/to/your/text.txt" or "path/to/your/image.xbm" which displays whatever gif/image/text/xbm you would prefer
;; - a cons of '("path/to/your/image.png" . "path/to/your/text.txt")
;; Content is not centered by default. To center, set
(setq dashboard-center-content t)
;; To disable shortcut "jump" indicators for each section, set
(setq dashboard-show-shortcuts nil)
(setq dashboard-display-icons-p t) ;; display icons on both GUI and terminal
(setq dashboard-icon-type 'nerd-icons) ;; use `nerd-icons' package
(setq dashboard-footer-messages '("Go ahead!"))
(dashboard-modify-heading-icons '((recents . "nf-oct-file_text")
                                  (bookmarks . "nf-oct-book")))
(setq dashboard-set-navigator t)
;; Format: "(icon title help action face prefix suffix)"
(provide `init-dashboard)
