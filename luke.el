(eval-and-compile
  (customize-set-variable
   'package-archives '(("org" . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu" . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package)))

;; Built-in project package
(require 'project)
(global-set-key (kbd "C-x p f") #'project-find-file)

;; Go to next error
(global-set-key (kbd "C-c N") #'flymake-goto-next-error)
;; Go to previous error
(global-set-key (kbd "C-c P") #'flymake-goto-prev-error)

;; General settings
(delete-selection-mode t)
(tool-bar-mode -1)
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024)) ;; 1mb
(setq auto-save-default nil)
(setq make-backup-files nil)
(setq create-lockfiles nil)
(global-display-line-numbers-mode)
(global-prettify-symbols-mode 1)
(global-hl-line-mode 1)

(setq tab-line-close-button-show nil)
(setq tab-line-tabs-function 'tab-line-tabs-mode-buffers)
(global-tab-line-mode t)
(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist '(ns-appearance . dark))

(when (eq window-system 'mac)
	(mac-auto-operator-composition-mode))

(use-package exec-path-from-shell
  :ensure t
  :config
  (exec-path-from-shell-initialize))

(use-package add-node-modules-path
  :ensure t)

(use-package which-key
  :ensure t
  :config
  (which-key-mode))

(use-package expand-region
  :ensure t
  :bind (("C-=" . er/expand-region)
	 ("C--" . er/contract-region)))


;; json-mode
(use-package json-mode
  :ensure t)


;; web-mode
(setq-default tab-width 2)
(setq indent-tabs-mode nil)
(defun mike/webmode-hook ()
	"Webmode hooks."
	(setq web-mode-enable-comment-annotation t)
	(setq web-mode-markup-indent-offset 2)
	(setq web-mode-code-indent-offset 2)
	(setq web-mode-css-indent-offset 2)
	(setq web-mode-attr-indent-offset 0)
	(setq web-mode-enable-auto-indentation t)
	(setq web-mode-enable-auto-closing t)
	(setq web-mode-enable-auto-pairing t)
	(setq web-mode-enable-css-colorization t)
)
(use-package web-mode
  :ensure t
  :mode (("\\.jsx?\\'" . web-mode)
	 ("\\.tsx?\\'" . web-mode)
	 ("\\.html\\'" . web-mode))
  :commands web-mode
	:hook (web-mode . mike/webmode-hook)
	)

;; company
(setq company-minimum-prefix-length 1
      company-idle-delay 0.0)
(use-package company
  :ensure t
  :config (global-company-mode t))


;; magit
(use-package magit
  :ensure t
  :bind (
	 ("C-x g" . magit-status)))


;; theme
(use-package atom-one-dark-theme
  :ensure t
  :config
    (load-theme 'atom-one-dark t))


;; lsp-mode
(setq lsp-log-io nil) ;; Don't log everything = speed
(setq lsp-keymap-prefix "C-c l")
;;(setq lsp-restart 'auto-restart)
(setq lsp-ui-sideline-show-diagnostics t)
(setq lsp-ui-sideline-show-hover t)
(setq lsp-ui-sideline-show-code-actions t)
(setq lsp-diagnostics-provider :flymake)
(setq lsp-ui-doc-enable t)
(setq lsp-ui-doc-position 'at-point)
(global-set-key (kbd "C-.") #'lsp-ui-peek-find-definitions)

(use-package lsp-mode
  :ensure t
  :hook (
	 (web-mode . lsp-deferred)
	 (lsp-mode . lsp-enable-which-key-integration)
	 )
  :commands lsp-deferred)


(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

(defun enable-minor-mode (my-pair)
  "Enable minor mode if filename match the regexp.  MY-PAIR is a cons cell (regexp . minor-mode)."
  (if (buffer-file-name)
      (if (string-match (car my-pair) buffer-file-name)
	  (funcall (cdr my-pair)))))

(use-package prettier-js
  :ensure t)
(add-hook 'web-mode-hook #'(lambda ()
                             (enable-minor-mode
                              '("\\.jsx?\\'" . prettier-js-mode))
			     (enable-minor-mode
                              '("\\.tsx?\\'" . prettier-js-mode))))

(eval-after-load 'web-mode
  '(progn
     (add-hook 'web-mode-hook #'add-node-modules-path)
     (add-hook 'web-mode-hook #'prettier-js-mode)))

(use-package npm-mode
  :ensure t
  :config
  (npm-global-mode))

;; Custom functions
(defun mike/kill-buffer ()
  "Kill the active buffer."
  (interactive)
  (kill-buffer (current-buffer)))

(global-set-key (kbd "C-x K") 'mike/kill-buffer)
