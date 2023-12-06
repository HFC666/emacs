(use-package pdf-tools
  :ensure t
  :config
  (pdf-tools-install))
(use-package epresent
  :ensure t)
(provide `init-pdf)
;;(setq doc-view-resolution 600)
(pdf-tools-install)
(when (featurep 'pdf-tools)
  (setq auto-mode-alist
        (append '(("\\.pdf\\'" . pdf-view-mode))
                auto-mode-alist)))


