;; ----------------------------------------------------------------------------
;; c/c++ files
;; ----------------------------------------------------------------------------
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.ixx\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.PH\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.TLH\\'" . c++-mode))
(defun my-rtags-setup ()
  (interactive)
  (require 'rtags)
  (if (fboundp 'evil-mode)
      (progn (evil-define-key 'normal c-mode-base-map "gd" 'rtags-find-symbol-at-point)
             (evil-define-key 'normal c-mode-base-map "gs" 'rtags-set-current-project)
             (evil-define-key 'normal c-mode-base-map "gh" 'rtags-display-summary)
             (evil-define-key 'normal c-mode-base-map "M-`" 'rtags-cycle-overlays-on-screen)
             (evil-define-key 'normal c-mode-base-map "\C-o" 'rtags-location-stack-back)
             (evil-define-key 'normal c-mode-base-map "\C-i" 'rtags-location-stack-forward)
             (evil-define-key 'normal c-mode-base-map "\C-]" 'rtags-find-references-at-point)
             ))
  ;; (setq rtags-completions-timer-interval .5 )
  ;; (rtags-diagnostics-mode 1)
  (setq rtags-tracking t)
  (setq rtags-error-timer-interval .5 )
  (setq rtags-index-js-files t)
  (setq rtags-rc-log-enabled nil)
  (setq rtags-completions-enabled t)
  )

(defun my-cc-mode-keymap-setup ()
  (define-key c-mode-base-map "\C-c\C-\\" nil)
  (define-key c-mode-base-map "\C-c\C-a"  nil)
  (define-key c-mode-base-map "\C-c\C-b"  nil)
  (define-key c-mode-base-map "\C-c\C-c"  nil)
  (define-key c-mode-base-map "\C-c\C-l"  nil)
  (define-key c-mode-base-map "\C-c\C-o"  nil)
  (define-key c-mode-base-map "\C-c\C-q"  nil)
  (define-key c-mode-base-map "\C-c\C-s"  'yas-insert-snippet)
  (define-key c-mode-base-map "\C-c\C-d"  nil)
  (define-key c-mode-base-map "\C-c\C-n"  nil)
  (define-key c-mode-base-map "\C-c\C-p"  nil)
  (define-key c-mode-base-map "\C-c\C-u"  nil)
  (define-key c-mode-base-map "\C-c\C-w"  nil)
  (define-key c-mode-base-map "\C-c\C-e"  nil)
  (define-key c-mode-base-map [Mouse-2] 'rtags-display-summary)
  (define-key c-mode-map "\C-c\C-e"  nil)
  (rtags-enable-standard-keybindings c-mode-base-map "\C-c")
  )

(defun my-cc-mode-edit-setup ()
  (setq
   c-style-variables-are-local-p nil
   ;; NO newline automatically after electric expressions are entered
   c-auto-newline nil
   ;; do not impose restriction that all lines not top-level be indented at least 1
   c-label-minimum-indentation 0)
  (setq comment-start "// " comment-end "")

  (c-toggle-hungry-state 1)

  (google-set-c-style)
  (c-set-style "Google")
  (setq c-default-style "Google")

  (turn-on-auto-fill)

  ;; (doxymacs-mode 1)
  ;; (doxymacs-font-lock)

  (subword-mode 1)
  )

(defun my-cc-mode-hook ()
  (unless buffer-read-only
    (progn
      (my-cc-mode-edit-setup)
      (my-cc-mode-ac-setup)
      (my-cc-mode-keymap-setup)
      )))

(eval-after-load 'cc-mode
  '(progn
     (require 'clang-format)
     ;; (require 'doxymacs)
     (require 'google-c-style)
     (require 'company-rtags)
     (my-rtags-setup)
     ;; (defun my-clang-format-before-save ()
     ;;   (when (member major-mode '(c-mode c++-mode))
     ;;     (condition-case err (clang-format-buffer)
     ;;       (error (message "%s" (error-message-string err))))))
     ;; (add-hook 'before-save-hook 'my-clang-format-before-save)
     ))

(add-hook 'c-mode-hook 'my-cc-mode-hook)
(add-hook 'c++-mode-hook 'my-cc-mode-hook)

;;----------------------------------------------------------------------------
;; llvm
;;----------------------------------------------------------------------------
(add-to-list 'load-path "~/RESEARCH/klee/src/utils/emacs")
(setq auto-mode-alist (append '(("\\.pc$" . klee-pc-mode)) auto-mode-alist))
(autoload 'klee-pc-mode "klee-pc-mode" "klee pc mode" t)
(setq auto-mode-alist (append '(("\\.ll$" . llvm-mode)) auto-mode-alist))
(autoload 'llvm-mode "llvm-mode" "major mode for ll files" t)
(setq auto-mode-alist (append '(("\\.td$" . tablegen-mode)) auto-mode-alist))
(autoload 'tablegen-mode "tablegen-mode" "major mode for tg files" t)
(eval-after-load "llvm-mode" '(require 'llvmize))

;;----------------------------------------------------------------------------
;; flex & bison
;;----------------------------------------------------------------------------
(autoload 'bison-mode "bison-mode")
(add-to-list 'auto-mode-alist '("\\.y$" . bison-mode))
(autoload 'flex-mode "flex-mode")
(add-to-list 'auto-mode-alist '("\\.l$" . flex-mode))

;;----------------------------------------------------------------------------
;; gdb issues
;;----------------------------------------------------------------------------

(setq gdb-many-windows t
      gdb-show-main t
      gud-chdir-before-run nil
      gdb-create-source-file-list nil)

(defun hack-gud-mode ()
  (when (string= major-mode "gud-mode")
    (run-with-timer 0.25 nil (goto-char (point-max)))))
(defadvice switch-to-buffer (after switch-to-buffer-after activate)
  (hack-gud-mode))
(defadvice switch-window (after switch-window-after activate)
  (hack-gud-mode))
(defadvice windmove-do-window-select (after windmove-do-window-select-after activate)
  (hack-gud-mode))
(defadvice yas-expand (after yas-expand-after activate)
  (hack-gud-mode))

(setq gud-mode-hook nil)
(add-hook 'gud-mode-hook (lambda ()
                           ;; (tooltip-mode 1)
                           ;; (gud-tooltip-mode 1)
                           (autopair-mode -1)))

(defadvice gdb-display-source-buffer
    (after ad-hl-line-source-buffer (buffer) activate)
  (with-current-buffer buffer (hl-line-mode 1)))

(eval-after-load "gdb-mi"
  `(progn
     (defun gdb-setup-windows ()
       "Simplified gdb windows"
       (gdb-get-buffer-create 'gdb-stack-buffer)
       (set-window-dedicated-p (selected-window) nil)
       (switch-to-buffer gud-comint-buffer)
       (delete-other-windows)
       (let ((win0 (selected-window))
             (win1 (split-window nil nil 'left))
             (win2 (split-window-below (/ (* (window-height) 3) 4)))
             )
         (select-window win2)
         (gdb-set-window-buffer (gdb-stack-buffer-name))
         (select-window win1)
         (set-window-buffer
          win1
          (if gud-last-last-frame
              (gud-find-file (car gud-last-last-frame))
            (if gdb-main-file
                (gud-find-file gdb-main-file)
              (list-buffers-noselect))))
         (setq gdb-source-window (selected-window))
         (let ((win3 (split-window nil (/ (* (window-height) 3) 4))))
           (gdb-set-window-buffer (gdb-get-buffer-create 'gdb-inferior-io) nil win3))
         (select-window win0)
         ))))

(defun gud-break-remove ()
  "Set/clear breakpoint."
  (interactive)
  (save-excursion
    (if (eq (car (fringe-bitmaps-at-pos (point))) 'breakpoint)
        (gud-remove nil)
      (gud-break nil))))

(defun gdb-or-gud-go ()
  "If gdb isn't running; run gdb, else call gud-go."
  (interactive)
  (if (and gud-comint-buffer
           (buffer-name gud-comint-buffer)
           (get-buffer-process gud-comint-buffer)
           (with-current-buffer gud-comint-buffer (eq gud-minor-mode 'gdba)))
      (funcall (lambda () (gud-call (if gdb-active-process "continue" "run") "")))
    (funcall(lambda () (gdb (gud-query-cmdline 'gdba))))))

(setq auto-mode-alist (append '(("\\.gdb$" . gdb-script-mode)) auto-mode-alist))

(defun gud-get-process-name ()
  (let ((process (get-buffer-process gud-comint-buffer)))
    (if (null process)
        nil
      (process-name process))))

(defun gdb-save-breakpoints ()
  "Save current breakpoint definitions as a script."
  (interactive)
  (let ((gud-process-name (gud-get-process-name)))
    (cond (gud-process-name
           (gud-basic-call
            (format "save breakpoints ~/emacs.d/.gdb/%s-breakpoints.gdb"
                    gud-process-name))))))

(defun gdb-restore-breakpoints ()
  "Restore the saved breakpoint definitions as a script."
  (interactive)
  (let ((breakpoints-file (format "~/emacs.d/.gdb/%s-breakpoints.gdb"
                                  (gud-get-process-name))))
    (if (file-exists-p breakpoints-file)
        (gud-basic-call (format "source %s" breakpoints-file)))))

(defun gud-kill()
  "Kill gdb-buffer."
  (interactive)
  (gdb-save-breakpoints)
  (kill-buffer)
  (delete-window))

(setq gdb-mode-hook nil)
(add-hook 'gdb-mode-hook
          (lambda ()
            (gdb-restore-breakpoints)
            (local-set-key (kbd "C-x k") 'gud-kill)))

(defun my-add-current-compile-commands ()
  (interactive)
  (add-file-local-variable-prop-line 'compile-command compile-command)
  )


(provide 'init-cc-mode)
