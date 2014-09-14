;; ------------------------------------------------------------------------------
;; ~/.emacs.d/site-lisp
;; ------------------------------------------------------------------------------
(if (fboundp 'normal-top-level-add-to-load-path)
    (let* ((my-lisp-dir "~/.emacs.d/site-lisp/")
           (default-directory my-lisp-dir))
      (progn
        (setq load-path
              (append
               (loop for dir in (directory-files my-lisp-dir)
                     unless (string-match "^\\." dir)
                     collecting (expand-file-name dir))
               load-path)))))
(require 'bytecomp)
;; ------------------------------------------------------------------------------
;; package.el configuration
;; ------------------------------------------------------------------------------
(require 'package)

;; Patch up annoying package.el quirks
(defadvice package-generate-autoloads (after close-autoloads (name pkg-dir) activate)
  "Stop package.el from leaving open autoload files lying around."
  (let ((path (expand-file-name (concat name "-autoloads.el") pkg-dir)))
    (with-current-buffer (find-file-existing path)
      (kill-buffer))))

;; Add support to package.el for pre-filtering available packages

(defvar package-filter-function nil
  "Optional predicate function used to internally filter packages used by package.el.

The function is called with the arguments PACKAGE VERSION ARCHIVE, where
PACKAGE is a symbol, VERSION is a vector as produced by `version-to-list', and
ARCHIVE is the string name of the package archive.")

(defadvice package--add-to-archive-contents
  (around filter-packages (package archive) activate)
  "Add filtering of available packages using `package-filter-function', if non-nil."
  (when (or (null package-filter-function)
            (funcall package-filter-function
                     (car package)
                     (funcall (if (fboundp 'package-desc-version)
                                  'package--ac-desc-version
                                'package-desc-vers)
                              (cdr package))
                     archive))
    ad-do-it))

(defun require-package (package &optional min-version no-refresh)
  "Ask elpa to install given PACKAGE.
If the version is older than MIN-VERSION, update PACKAGE; if NO-REFRESH is
non-nil, refresh package contents to get the latest `package-archive-contents'"
  (if (package-installed-p package min-version)
      t
    (if (or (assoc package package-archive-contents) no-refresh)
        (package-install package)
      (progn
        (package-refresh-contents)
        (require-package package min-version t)))))

(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))

(defvar melpa-exclude-packages
  '(slime)
  "Don't install Melpa versions of these packages.")

;; Don't take Melpa versions of certain packages
(setq package-filter-function
      (lambda (package version archive)
        (and
         (not (memq package '(eieio)))
         (or (not (string-equal archive "melpa"))
             (not (memq package melpa-exclude-packages))))))

;; ------------------------------------------------------------------------------
;; Fire up package.el and ensure the following packages are installed.
;;------------------------------------------------------------------------------

(package-initialize)
(require-package 'session)
(require-package 'smex)
(require-package 'autopair)
(require-package 'ibuffer-vc)
(require-package 'pointback)
(require-package 'undo-tree) ;; evil mode needs it!
(require-package 'ido-ubiquitous)
(require-package 'info+)
(require-package 'wgrep)
(require-package 'popup-kill-ring)
;; (require-package 'crontab-mode)
;; (require-package 'xml-rpc)
;; (require-package 'regex-tool)

;; ------------------------------------------------------------------------------
;; vim like editing
;; ------------------------------------------------------------------------------
(require-package 'evil)
(require-package 'evil-leader)
(require-package 'surround)

;;------------------------------------------------------------------------------
;; version control
;;------------------------------------------------------------------------------
;; git
(require-package 'magit)
(require-package 'magit-svn)
(require-package 'github-browse-file)
(require-package 'git-commit-mode)
(require-package 'gitignore-mode)
(require-package 'gitconfig-mode)
;; svn
;; (require-package 'dsvn)

;;------------------------------------------------------------------------------
;; writings
;;------------------------------------------------------------------------------
(require-package 'auctex)
(require-package 'auctex-latexmk)
(require-package 'ac-math)
(require-package 'latex-extra)
(require-package 'latex-pretty-symbols)
;; (require-package 'gnuplot)
(require-package 'markdown-mode)
;; org
(require-package 'cdlatex)
(require-package 'org-plus-contrib)
(require-package 'htmlize)
(require-package 'graphviz-dot-mode)

;;------------------------------------------------------------------------------
;; development
;;------------------------------------------------------------------------------
(require-package 'find-file-in-project)
(require-package 'inflections) ;; required by jump
(require-package 'jump)
;; required by jump, surprisingly this package from elpa contains jump and inflections
(require-package 'findr)
(require-package 'flymake-cursor) ;;show flymake errors in minibuffer
;; snippets
(require-package 'dropdown-list)
(require-package 'yasnippet)

;; auto-complete
(require-package 'fuzzy) ;auto-complete depends on fuzzy
(require-package 'auto-complete)
(require-package 'pos-tip)

;; shell
(require-package 'flymake-shell) ;; require flymake-easy

;; python
(require-package 'elpy)

;; javascript
;; (require-package 'json)
;; (require-package 'js3-mode)
;; (require-package 'js2-mode)
;; (require-package 'js-comint)
;; (require-package 'flymake-jslint)

;; coffeescript
;; (require-package 'coffee-mode)
;; (require-package 'flymake-coffee)

;; pages and styles
;; (require-package 'haml-mode)
;; (require-package 'flymake-haml)
;; (require-package 'sass-mode)
;; (require-package 'flymake-sass)
;; (require-package 'scss-mode)
;; (require-package 'less-css-mode)
(require-package 'pretty-mode)
;; (require-package 'smarty-mode) ;; html templates
;; (require-package 'zencoding-mode)

;; (require-package 'tidy)
;; (require-package 'flymake-css)
(require-package 'rainbow-mode)
(require-package 'rainbow-delimiters)

(require-package 'yaml-mode)

;; lisp
(require-package 'hl-sexp)
(require-package 'paredit)

(require-package 's)

(byte-recompile-directory "~/.emacs.d/site-lisp" 0)

(provide 'init-elpa)
