
(toggle-frame-maximized)
;(toggle-frame-fullscreen)
(setq inhibit-startup-message t)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 0)

(eval-and-compile
  (customize-set-variable
   'package-archives '(("org" . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu" . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package)))
(require 'use-package)
(setq use-package-always-ensure t)

;; Keep machine-local Custom settings and secrets out of git.
(setq custom-file (expand-file-name "local/custom.el" user-emacs-directory))
(make-directory (file-name-directory custom-file) t)
(load custom-file 'noerror 'nomessage)

(require 'json)

(defun my/npm-project-scripts ()
  (let* ((root (locate-dominating-file default-directory "package.json"))
         (package-json (and root (expand-file-name "package.json" root))))
    (when (and package-json (file-readable-p package-json))
      (condition-case nil
          (with-temp-buffer
            (insert-file-contents package-json)
            (let* ((json-object-type 'alist)
                   (json-array-type 'list)
                   (json-key-type 'string)
                   (data (json-read))
                   (scripts (alist-get "scripts" data nil nil #'string=)))
              (and (listp scripts) scripts)))
        (error nil)))))

(defun my/js-package-manager ()
  (let ((root (locate-dominating-file default-directory "package.json")))
    (cond
     ((not root) nil)
     ((file-exists-p (expand-file-name "pnpm-lock.yaml" root)) 'pnpm)
     ((file-exists-p (expand-file-name "yarn.lock" root)) 'yarn)
     ((or (file-exists-p (expand-file-name "package-lock.json" root))
          (file-exists-p (expand-file-name "npm-shrinkwrap.json" root)))
      'npm)
     (t 'npm))))

(defun my/js-run-script-command (script)
  (pcase (my/js-package-manager)
    ('pnpm (format "pnpm %s" script))
    ('yarn (format "yarn %s" script))
    (_ (format "npm run %s" script))))

(defun my/npm-default-compile-command ()
  (let ((scripts (my/npm-project-scripts)))
    (cond
     ((assoc "dev" scripts) (my/js-run-script-command "dev"))
     ((assoc "start" scripts) (my/js-run-script-command "start"))
     ((assoc "build" scripts) (my/js-run-script-command "build"))
     ((assoc "test" scripts) (my/js-run-script-command "test")))))

(defun my/set-js-project-compile-command ()
  (when (and (project-current nil)
             (not (local-variable-p 'compile-command)))
    (let ((cmd (my/npm-default-compile-command)))
      (when cmd
        (setq-local compile-command cmd)))))

(add-hook 'hack-local-variables-hook #'my/set-js-project-compile-command)
(setq project-compilation-buffer-name-function #'project-prefixed-buffer-name)

(defun my/maybe-enable-npm-mode ()
  (when (and default-directory
             (locate-dominating-file default-directory "package.json"))
    (npm-mode 1)))

(column-number-mode)
(global-display-line-numbers-mode t)

(dolist (mode '(org-mode-hook
		term-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(find-file (expand-file-name "init.el" user-emacs-directory))
(switch-to-buffer-other-window "*Messages*")

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.1))

(use-package helpful
  :ensure t)

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x))
  :config
  (dolist (var '("PATH" "MANPATH" "NVM_DIR" "NVM_BIN"))
    (add-to-list 'exec-path-from-shell-variables var))
  (exec-path-from-shell-initialize))

(use-package npm-mode
  :hook ((find-file . my/maybe-enable-npm-mode)
         (dired-mode . my/maybe-enable-npm-mode)))

(use-package markdown-mode
  :hook (markdown-mode . visual-line-mode))

(use-package adaptive-wrap
  :hook (markdown-mode . adaptive-wrap-prefix-mode))

(require 'color)

(defun my/markdown-refresh-code-block-faces (&rest _)
  (let* ((default-bg (face-background 'default nil t))
         (bg-mode (frame-parameter nil 'background-mode))
         (code-bg (and default-bg
                       (if (eq bg-mode 'dark)
                           (ignore-errors (color-lighten-name default-bg 8))
                         (ignore-errors (color-darken-name default-bg 6))))))
    (custom-set-faces
     `(markdown-code-face ((t (:inherit (fixed-pitch shadow)))))
     `(markdown-pre-face
       ((t (:inherit (fixed-pitch default)
                     ,@(when code-bg (list :background code-bg)))))))))

(add-hook 'markdown-mode-hook #'my/markdown-refresh-code-block-faces)
(advice-add 'load-theme :after #'my/markdown-refresh-code-block-faces)

(defun my/magit-refresh-diff-heading-faces (&rest _)
  (when (facep 'magit-diff-file-heading-highlight)
    (let ((fg (face-foreground 'default nil t)))
      (when fg
        (set-face-attribute 'magit-diff-file-heading-highlight nil
                            :foreground fg
                            :weight 'bold)))))

(with-eval-after-load 'magit-diff
  (my/magit-refresh-diff-heading-faces))
(advice-add 'load-theme :after #'my/magit-refresh-diff-heading-faces)

(use-package modus-themes
  :ensure nil
  :defer t)

(use-package spacemacs-theme
  :defer t)

(use-package doom-themes
  :defer t)

(use-package magit
  :bind (("C-x g" . magit-status)))

(load-theme 'spacemacs-dark t)
