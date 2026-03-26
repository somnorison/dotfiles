;;; delete package.el init
;;; (require 'package)
;;; (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;;; (package-initialize)

;;; (unless (package-installed-p 'use-package)
;;;   (package-refresh-contents)
;;;   (package-install 'use-package))
;;; (require 'use-package)

(defvar bootstrap-version)
  (let ((bootstrap-file
         (expand-file-name
          "straight/repos/straight.el/bootstrap.el"
          (or (bound-and-true-p straight-base-dir)
              user-emacs-directory)))
        (bootstrap-version 7))
    (unless (file-exists-p bootstrap-file)
      (with-current-buffer
          (url-retrieve-synchronously
           "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
           'silent 'inhibit-cookies)
        (goto-char (point-max))
        (eval-print-last-sexp)))
    (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("7478bc74ae421ad2103d4239176f71e6d55ef0be4eb874c328b862af5b93a857"
     "8363207a952efb78e917230f5a4d3326b2916c63237c1f61d7e5fe07def8d378"
     "e0b5fb579ff4c574f82b554cddd35810c2a579b4035769da41d1a9a807e12516"
     "a5b8812270156398a2d93358c0ffd9525fc4fcc4ecb9844aa040e54613146a24" default))
 '(fill-column 100)
 '(markdown-command "pandoc")
 '(org-agenda-files nil)
 '(package-vc-selected-packages 'nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )




;; emacs nicer init


;; backup stuff
(make-directory "~/.emacs.d/autosaves/" t)
(make-directory "~/.emacs.d/backups/" t)

(setq
 backup-by-copying t
 backup-directory-alist '(("." . "~/.emacs.d/backups/"))
 delete-old-versions t
 kept-new-versions 6
 kept-old-version 2
 version-control t)

(setq
 fill-buffer-delete-auto-save-files t
 auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves" t)))

; (load-file "~/.emacs.d/evil.el")

(menu-bar-mode -1)


(setq tab-always-indent 'complete)

(use-package interaction-log)

(use-package jq-mode )


;; this makes it possible to set the width for org images with
;; +ATTR_ORG :width <number>
(setq org-image-actual-width '(768))

(use-package vterm
  :bind (:map project-prefix-map
              ("t" . project-vterm))
  :after '(project)
  :preface
  (defun project-vterm ()
    (interactive)
    (defvar vterm-buffer-name)
    (let* ((default-directory (project-root (project-current t)))
           (vterm-buffer-name (project-prefixed-buffer-name "vterm"))
           (vterm-buffer (get-buffer vterm-buffer-name)))
      (if (and vterm-buffer (not current-prefix-arg))
          (pop-to-buffer vterm-buffer (bound-and-true-p display-comint-buffer-action))
        (vterm))))
  :init
  (add-to-list 'project-switch-commands '(project-vterm "Vterm") t)
  (add-to-list 'project-kill-buffer-conditions '(major-mode . vterm-mode))
  :config
  (setq vterm-copy-exclude-prompt t)
  (setq vterm-max-scrollback 100000)
  (setq vterm-tramp-shells '(("ssh" "/bin/bash"))))

(use-package fuel
  :config
  (setq fuel-factor-root-dir "~/projects/others/factor"))

(use-package xclip
  :config
  (xclip-mode 1))

(use-package markdown-mode )

(use-package exotica-theme
  :config
					;(load-theme 'exotica t)
  )


(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture) ; how do I change the capture locations?

(add-to-list 'custom-theme-load-path '"~/.emacs.d/themes/")


(defun toggle-wk-toplevel ()
  (interactive)
				 (if
				     (get-buffer-window " *which-key*")
				     (kill-buffer " *which-key*")
				     (which-key-show-top-level)))
(use-package which-key
  :config
  (which-key-mode)
  (which-key-setup-side-window-bottom)
    (keymap-set global-map "C-x w" 'toggle-wk-toplevel))

(use-package marginalia
  :config
  (marginalia-mode))

(use-package embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings)))

(defun vterm-buffers ()
  (cl-remove-if-not (lambda (bufname)
                      (eq (with-current-buffer bufname major-mode) 'vterm-mode))
                    (cl-map 'list #'buffer-name (buffer-list))))

(defvar consult-source-vterm
  `(:name "VTerm"
          :narrow ?v
          :category buffer
          :face consult-buffer
          :default t
          :items ,#'vterm-buffers))

(use-package consult
  :bind
  ("C-x b" . consult-buffer)
  ("C-y" . consult-yank-from-kill-ring)
  ("C-c f f" . consult-fd)
  ("C-c f l" . consult-find)
  ("C-c f b" . consult-buffer)
  :config
  (unless (member 'consult-source-vterm consult-source-vterm)
    (add-to-list 'consult-buffer-sources 'consult-source-vterm)))

(use-package magit
  :bind
  (:map magit-file-section-map
	      ("RET" . magit-diff-visit-file-other-window)
	      :map magit-hunk-section-map
	      ("RET" . magit-diff-visit-file-other-window)))



;; C-x (something) means
;; "Emacs is going to turn into another program, now"
;; The leader keys really make sense to me in terms of a text-editing context

(recentf-mode)
;; Leader key thing

(use-package rg)

(use-package org-roam
  :custom
  (org-roam-directory (file-truename "~/zetta"))
  :bind
  ("C-c n l" . org-roam-buffer-toggle)
  ("C-c n f" . org-roam-node-find)
  ("C-c n g" . org-roam-graph)
  ("C-c n i" . org-roam-node-insert)
  ("C-c n c" . org-roam-capture)
  ("C-c n j" . org-roam-dailies-capture-today)
  ("C-c n t" . org-roam-dailies-goto-today)
  :config
  (org-roam-db-autosync-mode))


;; minibuffer stuff
(keymap-set minibuffer-local-must-match-map "C-j" 'minibuffer-next-completion)
(keymap-set minibuffer-local-map "C-l" 'minibuffer-complete-and-exit)
(keymap-set minibuffer-local-map "C-k" 'minibuffer-previous-completion)
;;(keymap-set minibuffer-local-map "C-w" 'evil-delete-backward-word)
;; (evil-define-key '(normal motion) 'global "," 'evil-jump-backward)
;; (evil-define-key '(normal motion) 'global "." 'evil-jump-forward)

(use-package sly
  :config
  (require 'sly)
  (setq inferior-lisp-program "sbcl"))
; (when (file-exists-p "~/quicklisp/slime-helper.el") 
;   (load (expand-file-name "~/quicklisp/slime-helper.el"))
;   (setq inferior-lisp-program "sbcl"))
;; Replace "sbcl" with the path to your implementation

(use-package embark-consult )

(load-file "~/.emacs.d/configuration/org.el")

(use-package pomm
  :straight t
  :commands (pomm-third-time)
  :config
  (make-directory "~/zetta/data" t)
  (setq pomm-third-time-csv-history-file "~/zetta/data/time.csv")
  (setq alert-default-style 'libnotify
	pomm-audio-enabled t
	pomm-audio-tick-enabled nil
	pomm-audio-player-executable "aplay")
  (pomm-mode-line-mode)
  :bind
  ("C-c p" . pomm-third-time))

;; https://yiufung.net/post/emacs-key-binding-conventions-and-why-you-should-try-it/

;; Keybind Conventions
;; C-x: system commands, these should be globally available.
;; C-c C-{something}: major mode
;; C-c {something}: minor mode

(setq dired-guess-shell-alist-user
      '(("\\.\\(png\\|jpe?g\\|tiff\\)$" "feh" "xdg-open")
	("\\.\\(mp[34]\\|m4a\\|ogg\\|flac\\|webm\\|mkv\\)" "mpv" "xdg-open")
	(".*" "xdg-open")))

(set-display-table-slot standard-display-table 'vertical-border (make-glyph-code ?│))
(setq mode-line-end-spaces nil)

(load-file "~/.emacs.d/configuration/org.el")
(load-file "~/.emacs.d/configuration/ticktock.el")
;; TODO: create a straight.el recipe to load ticktock
;; only after we've installed/loaded pomm and org-roam
;; https://github.com/radian-software/straight.el
;; Another idea would be creating a dummy-target recipe
;; and using that to load a configuration file
;; This doesn't work, sadge
;; (straight-use-package '(dummy :type nil) t t)
;; (use-package t
;;   :no-require t
;;   :after (org-roam pomm)
;;   :config (load-file "~/.emacs.d/configuration/ticktock.el"))

;; (load-theme "wheatgrass")
(setq initial-buffer-choice 'scratch-buffer)
(add-hook 'after-init-hook (lambda () (load-theme 'wheatgrass)))

;; skinny-only
(defun on-workhorse-p ()
  (string-equal "skinny" (shell-command-to-string "echo -n $HOST")))

(use-package mise
  :config
  (add-hook 'after-init-hook #'global-mise-mode))

; (use-package kubed
;   :if (on-workhorse-p)
;   :config
;   (keymap-global-set "C-c k" 'kubed-prefix-map)
;   (setq kubed-kubectl-program
; 	(string-trim (shell-command-to-string "mise which kubectl"))))

; (defun mise-cmd (name)
;   (string-trim (shell-command-to-string (format "dirname $(mise which %s)" name))))


; (mise-cmd "kubelogin")
; (mise-cmd "az")
; (add-to-list 'exec-path (mise-cmd "kubelogin"))
; (add-to-list 'exec-path (mise-cmd "az"))

(setq-default indent-tabs-mode nil)
(global-set-key (kbd "M-,") #'previous-buffer)
(global-set-key (kbd "M-.") #'next-buffer)
(use-package forth-mode)
