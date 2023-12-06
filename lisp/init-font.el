;; 设置字体
(set-face-attribute 'default nil :font "Noto Sans Mono 12")

;; 设置中文字体
(dolist (charset '(kana han symbol cjk-misc bopomofo))
  (set-fontset-font (frame-parameter nil 'font) charset
                    (font-spec :family "Noto Sans Mono" :size 14)))

;; 启用抗锯齿
(setq-default frame-title-format '("%b - Emacs"))
(setq x-underline-at-descent-line t)
(set-face-attribute 'default nil :height 120)

(provide `init-font)
