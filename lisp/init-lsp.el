(use-package eglot
  :hook ((c-mode
          c++-mode
          go-mode
          java-mode
          js-mode
;;          python-mode
          rust-mode
          web-mode) . eglot-ensure)
  :bind (("C-c e f" . #'eglot-format)
         ("C-c e a" . #'eglot-code-actions)
         ("C-c e i" . #'eglot-code-action-organize-imports)
         ("C-c e q" . #'eglot-code-action-quickfix))
  :config
  ;; (setq eglot-ignored-server-capabilities '(:documentHighlightProvider))
  (add-to-list 'eglot-server-programs '(web-mode "vls"))
  (defun eglot-actions-before-save()
    (add-hook 'before-save-hook
              (lambda ()
                (call-interactively #'eglot-format)
                (call-interactively #'eglot-code-action-organize-imports))))
  (add-hook 'eglot--managed-mode-hook #'eglot-actions-before-save))
(provide `init-lsp)
