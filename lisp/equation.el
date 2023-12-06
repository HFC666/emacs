(setq xenops-math-latex-process-alist
        '((dvisvgm :programs
                   ("latex" "dvisvgm")
                   :description "dvi > svg" :message "you need to install the programs: latex and dvisvgm." :image-input-type "dvi" :image-output-type "svg" :image-size-adjust
                   (1.7 . 1.5)
                   :latex-compiler
                   ("latex -interaction nonstopmode -shell-escape -output-format dvi -output-directory %o \"\\nonstopmode\\nofiles\\PassOptionsToPackage{active,tightpage,auctex}{preview}\\AtBeginDocument{\\ifx\\ifPreview\\undefined\\RequirePackage[displaymath,floats,graphics,textmath,footnotes]{preview}[2004/11/05]\\fi}\\input\\detokenize{\"%f\"}\" %f")
                   :image-converter
                   ("dvisvgm %f -n -b %B -c %S -o %O"))))

  (defun xenops-aio-subprocess (command &optional _ __)
    "Start asynchronous subprocess; return a promise.

COMMAND is the command to run as an asynchronous subprocess.

Resolve the promise when the process exits. The value function
does nothing if the exit is successful, but if the process exits
with an error status, then the value function signals the error."
    (let* ((promise (aio-promise))
           (name (format "xenops-aio-subprocess-%s"
                         (sha1 (prin1-to-string command))))
           (output-buffer (generate-new-buffer name))
           (sentinel
            (lambda (process event)
              (unless (process-live-p process)
                (aio-resolve
                 promise
                 (lambda ()
                   (if (or (eq 0 (process-exit-status process))
                           (and (eq 1 (process-exit-status process))
                                (not (string-match-p
                                      "^! [^P]"
                                      (with-current-buffer output-buffer
                                        (buffer-string))))))
                       (kill-buffer output-buffer)
                     (signal 'error
                             (prog1 (list :xenops-aio-subprocess-error-data
                                          (list (s-join " " command)
                                                event
                                                (with-current-buffer output-buffer
                                                  (buffer-string))))
                               (kill-buffer output-buffer))))))))))
      (prog1 promise
        (make-process
         :name name
         :buffer output-buffer
         :command command
         :sentinel sentinel))))
  
  (defun eli/xenops-preview-align-baseline (element &rest _args)
    "Redisplay SVG image resulting from successful LaTeX compilation of ELEMENT.

Use the data in log file (e.g. \"! Preview: Snippet 1 ended.(368640+1505299x1347810).\")
to calculate the decent value of `:ascent'. "
    (let* ((inline-p (eq 'inline-math (plist-get element :type)))
           (ov-beg (plist-get element :begin))
           (ov-end (plist-get element :end))
           (colors (xenops-math-latex-get-colors))
           (latex (buffer-substring-no-properties ov-beg
                                                  ov-end))
           (cache-svg (xenops-math-compute-file-name latex colors))
           (cache-log (file-name-with-extension cache-svg "log"))
           (cache-log-exist-p (file-exists-p cache-log))
           (tmp-log (f-join temporary-file-directory "xenops"
                            (concat (f-base cache-svg) ".log")))
           (ov (car (overlays-at (/ (+ ov-beg ov-end) 2) t)))
           (regexp-string "^! Preview:.*\(\\([0-9]*?\\)\\+\\([0-9]*?\\)x\\([0-9]*\\))")
           img new-img ascent bbox log-text log)
      (when (and ov inline-p)
        (if cache-log-exist-p
            (let ((text (f-read-text cache-log)))
              (string-match regexp-string text)
              (setq log (match-string 0 text))
              (setq bbox (mapcar #'(lambda (x)
                                     (* (preview-get-magnification)
                                        (string-to-number x)))
                                 (list
                                  (match-string 1 text)
                                  (match-string 2 text)
                                  (match-string 3 text)))))
          (with-temp-file cache-log
            (insert-file-contents-literally tmp-log)
            (goto-char (point-max))
            (if (re-search-backward regexp-string nil t)
                (progn
                  (setq log (match-string 0))
                  (setq bbox (mapcar #'(lambda (x)
                                         (* (preview-get-magnification)
                                            (string-to-number x)))
                                     (list
                                      (match-string 1)
                                      (match-string 2)
                                      (match-string 3))))))
            (erase-buffer)
            (insert log)))
        (setq ascent (preview-ascent-from-bb (preview-TeX-bb bbox)))
        (setq img (cdr (overlay-get ov 'display)))
        (setq new-img (plist-put img :ascent ascent))
        (overlay-put ov 'display (cons 'image new-img)))))
  (advice-add 'xenops-math-display-image :after
              #'eli/xenops-preview-align-baseline)


(plist-put org-format-latex-options :justify 'right)
(defun eli/xenops-justify-fragment-overlay (element &rest _args)
    (let* ((ov-beg (plist-get element :begin))
           (ov-end (plist-get element :end))
           (ov (car (overlays-at (/ (+ ov-beg ov-end) 2) t)))
           (position (plist-get org-format-latex-options :justify))
           (inline-p (eq 'inline-math (plist-get element :type)))
           width offset)
      (when (and ov
                 (imagep (overlay-get ov 'display)))
        (setq width (car (image-display-size (overlay-get ov 'display))))
        (cond
         ((and (eq 'center position) 
               (not inline-p))
          (setq offset (floor (- (/ fill-column 2)
                                 (/ width 2))))
          (if (< offset 0)
              (setq offset 0))
          (overlay-put ov 'before-string (make-string offset ? )))
         ((and (eq 'right position) 
               (not inline-p))
          (setq offset (floor (- fill-column
                                 width)))
          (if (< offset 0)
              (setq offset 0))
          (overlay-put ov 'before-string (make-string offset ? )))))))
  (advice-add 'xenops-math-display-image :after
              #'eli/xenops-justify-fragment-overlay)


(defun eli/xenops-renumber-environment (orig-func element latex colors
                                                    cache-file display-image)
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
      (when (setq numberp (cdr (assoc (plist-get element :begin) results)))
        (setq latex
              (concat
               (format "\\setcounter{equation}{%s}\n" numberp)
               latex))))
    (funcall orig-func element latex colors cache-file display-image))
  (advice-add 'xenops-math-latex-create-image :around #'eli/xenops-renumber-environment)

;; show `#+name:' while in latex preview.
  (defun eli/org-preview-show-label (orig-fun beg end &rest _args)
  (let* ((beg (save-excursion
                (goto-char beg)
                (if (re-search-forward "#\\+name:" end t)
                    (progn
                      (next-line)
                      (line-beginning-position))
                  beg))))
    (apply orig-fun beg end _args)))
  (advice-add 'org--make-preview-overlay :around #'eli/org-preview-show-label)

(provide `equation)
