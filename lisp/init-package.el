;;个别时候会出现签名检验失败
(setq package-check-signature nil) 

;; 初始化软件包管理器
(require 'package)
(unless (bound-and-true-p package--initialized)
    (package-initialize))

;; 刷新软件源索引
(unless package-archive-contents
    (package-refresh-contents))

;; 第一个扩展插件：use-package，用来批量统一管理软件包
(unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))
;; `use-package-always-ensure' 避免每个软件包都需要加 ":ensure t" 
;; `use-package-always-defer' 避免每个软件包都需要加 ":defer t" 
(setq use-package-always-ensure t
      use-package-always-defer t
      use-package-enable-imenu-support t
      use-package-expand-minimally t)

(require `use-package)
(use-package all-the-icons
  :if (display-graphic-p))
(provide `init-package)

;; 关于org-mode的插件
(use-package org-bullets
  :ensure t
  :init
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(use-package org-indent
  :ensure nil
  :hook (org-mode . org-indent-mode))


(package-install 'vertico)
(vertico-mode t)

(package-install 'orderless)
(use-package xenops
  :ensure t)
(add-hook 'latex-mode-hook #'xenops-mode)
(add-hook 'LaTeX-mode-hook #'xenops-mode)
(setq completion-styles '(orderless))
;; 自动补全
(use-package company
  :hook (after-init . global-company-mode)
  :config (setq company-minimum-prefix-length 1
                company-show-quick-access t))

;; 语法检查
(use-package flymake
  :hook (prog-mode . flymake-mode)
  :config
  (global-set-key (kbd "M-n") #'flymake-goto-next-error)
  (global-set-key (kbd "M-p") #'flymake-goto-prev-error))
;; 窗口切换
(use-package ace-window 
             :bind (("M-o" . 'ace-window)))
