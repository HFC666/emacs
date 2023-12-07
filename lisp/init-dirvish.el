(use-package dirvish
  :ensure t
  :commands (dirvish dirvish-mode))

(use-package all-the-icons-dired
  :ensure t
  :config
  (add-hook 'dired-mode-hook 'all-the-icons-dired-mode))

(dirvish-override-dired-mode)
(provide `init-dirvish)
