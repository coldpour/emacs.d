
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

(defun my/set-js-project-compile-command ()
  (when (and (project-current nil)
             (not (local-variable-p 'compile-command))
             (locate-dominating-file default-directory "package.json"))
    (setq-local compile-command "npm run dev")))

(add-hook 'hack-local-variables-hook #'my/set-js-project-compile-command)

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

(use-package magit
  :bind (("C-x g" . magit-status)))
