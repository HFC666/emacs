(setq org-latex-create-formula-image-program 'dvipng)
(add-hook 'org-mode-hook 'org-latex-preview)
;;(setq org-startup-with-latex-preview t)

;; Vertically align LaTeX preview in org mode
  (defun my-org-latex-preview-advice (beg end &rest _args)
    (let* ((ov (car (overlays-at (/ (+ beg end) 2) t)))
           (img (cdr (overlay-get ov 'display)))
           (new-img (plist-put img :ascent 95)))
      (overlay-put ov 'display (cons 'image new-img))))
  (advice-add 'org--make-preview-overlay
              :after #'my-org-latex-preview-advice)
  
  ;; from: https://kitchingroup.cheme.cmu.edu/blog/2016/11/06/
  ;; Justifying-LaTeX-preview-fragments-in-org-mode/
  ;; specify the justification you want
  (plist-put org-format-latex-options :justify 'right)

  (defun eli/org-justify-fragment-overlay (beg end image imagetype)
    (let* ((position (plist-get org-format-latex-options :justify))
           (img (create-image image 'svg t))
           (ov (car (overlays-at (/ (+ beg end) 2) t)))
           (width (car (image-display-size (overlay-get ov 'display))))
           offset)
      (cond
       ((and (eq 'center position) 
             (= beg (line-beginning-position)))
        (setq offset (floor (- (/ fill-column 2)
                               (/ width 2))))
        (if (< offset 0)
            (setq offset 0))
        (overlay-put ov 'before-string (make-string offset ? )))
       ((and (eq 'right position) 
             (= beg (line-beginning-position)))
        (setq offset (floor (- fill-column
                               width)))
        (if (< offset 0)
            (setq offset 0))
        (overlay-put ov 'before-string (make-string offset ? ))))))
  (advice-add 'org--make-preview-overlay
              :after 'eli/org-justify-fragment-overlay)
  
  ;; from: https://kitchingroup.cheme.cmu.edu/blog/2016/11/07/
  ;; Better-equation-numbering-in-LaTeX-fragments-in-org-mode/
  (defun org-renumber-environment (orig-func &rest args)
    (let ((results '()) 
          (counter -1)
          (numberp))
      (setq results (cl-loop for (begin .  env) in 
                             (org-element-map (org-element-parse-buffer)
                                 'latex-environment
                               (lambda (env)
                                 (cons
                                  (org-element-property :begin env)
                                  (org-element-property :value env))))
                             collect
                             (cond
                              ((and (string-match "\\\\begin{equation}" env)
                                    (not (string-match "\\\\tag{" env)))
                               (cl-incf counter)
                               (cons begin counter))
                              ((and (string-match "\\\\begin{align}" env)
                                    (string-match "\\\\notag" env))
                               (cl-incf counter)
                               (cons begin counter))
                              ((string-match "\\\\begin{align}" env)
                               (prog2
                                   (cl-incf counter)
                                   (cons begin counter)                          
                                 (with-temp-buffer
                                   (insert env)
                                   (goto-char (point-min))
                                   ;; \\ is used for a new line. Each one leads
                                   ;; to a number
                                   (cl-incf counter (count-matches "\\\\$"))
                                   ;; unless there are nonumbers.
                                   (goto-char (point-min))
                                   (cl-decf counter
                                            (count-matches "\\nonumber")))))
                              (t
                               (cons begin nil)))))
      (when (setq numberp (cdr (assoc (point) results)))
        (setf (car args)
              (concat
               (format "\\setcounter{equation}{%s}\n" numberp)
               (car args)))))
    (apply orig-func args))
  (advice-add 'org-create-formula-image :around #'org-renumber-environment)

(provide `init-org)
