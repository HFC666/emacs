(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(require `org)
(setq org-latex-create-formula-image-program 'dvipng)
(setq inhibit-startup-screen t)
(add-to-list 'load-path (expand-file-name (concat user-emacs-directory "lisp")))
(require `init-elpa)
(require `init-ui)
(require `init-package)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(all-the-icons-dired dirvish dashboard nerd-icons company epresent pdf-tools evil-org evil xenops smart-mode-line dracula-theme gruvbox-theme)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;;(require `init-evil)
(defalias `yes-or-no-p `y-or-n-p)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode)
(add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1)))
(require `init-org)
(require `init-font)
(require `init-pdf)
(require `init-lsp)
(require `init-dashboard)
(require `init-dirvish)
