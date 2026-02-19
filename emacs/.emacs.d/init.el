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
     "a5b8812270156398a2d93358c0ffd9525fc4fcc4ecb9844aa040e54613146a24"
     default))
 '(markdown-command "pandoc")
 '(package-selected-packages
   '(consult embark embark-consult evil evil-collection interaction-log
	     jq-mode json-mode magit marginalia markdown-mode md-babel
	     org-roam sly vterm which-key xclip)))
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

(use-package evil
  :init
  (setq evil-want-C-u-delete t)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-d-scroll t)
  :config
  (require 'evil)
  (evil-mode 1)
  (evil-set-leader '(normal motion) (kbd "SPC"))
  (evil-define-key '(normal motion) 'global (kbd "<leader>u") 'universal-argument))

; too heavyweight
(use-package evil-collection
  :after (evil magit)
  :config
  (evil-collection-help-setup)
  (evil-collection-info-setup)
  (evil-collection-dired-setup)
  (evil-collection-magit-setup))

(evil-define-key 'normal 'global (kbd "<leader> l t") 'interaction-log-mode)
(evil-define-key 'normal 'global (kbd "<leader> l b") 'ilog-show-in-new-frame)
(setq tab-always-indent 'complete)
(evil-define-key 'normal 'global (kbd "<leader> f i")
  (lambda () (interactive) (find-file "~/.emacs.d/init.el")))

; (evil-define-key 'insert 'global (kbd "<tab>") 'completion-at-point)
; (evil-define-key 'insert vterm-mode-map (kbd "<tab>") 'vterm-send-tab)
; (add-hook 'vterm-mode-hook (lambda () (evil-local-set-key 'insert (kbd "<tab>") 'vterm-send-tab)))


(use-package interaction-log)

(use-package jq-mode )


;; this makes it possible to set the width for org images with
;; +ATTR_ORG :width <number>
(setq org-image-actual-width '(768))

(use-package vterm)

(use-package xclip
  :config
  (xclip-mode 1))

(use-package markdown-mode )

(use-package exotica-theme
  :config
  (load-theme 'exotica t))


;; general
(evil-define-key 'insert 'global (kbd "C-j") 'evil-normal-state)


;(evil-define-key 'normal org-mode-map "zo" 'org-fold-show-children)
;(evil-define-key 'normal org-mode-map "zO" 'org-fold-show-all)
(evil-define-key 'normal org-mode-map "zz" 'org-cycle)
(evil-define-key 'normal 'global (kbd "<leader>bru") 'rename-uniquely)
(evil-define-key 'normal 'global (kbd "<leader>brr") 'rename-buffer)
(evil-define-key 'normal 'global "-" 'dired-jump)
(evil-define-key 'normal dired-mode-map "-" 'dired-up-directory)
(evil-define-key 'normal dired-mode-map "v" 'evil-visual-state)
(evil-define-key 'normal dired-mode-map "%" 'dired-create-empty-file)
(evil-define-key 'normal dired-mode-map "d" 'dired-create-directory)

(evil-define-key 'normal markdown-mode-map (kbd "<leader>z") 'markdown-table-align)

;; vterm bindings
(evil-define-key 'normal vterm-mode-map "h" '(lambda () (interactive) (vterm-send "<left>")))
(evil-define-key 'normal vterm-mode-map "l" '(lambda () (interactive) (vterm-send "<right>")))
(evil-define-key 'normal vterm-mode-map (kbd "<leader>k") '(lambda () (interactive) (vterm-send "<up>")))
(evil-define-key 'normal vterm-mode-map (kbd "<leader>j") '(lambda () (interactive) (vterm-send "<down>")))
(evil-define-key 'normal vterm-mode-map (kbd "<leader><escape>") 'vterm-send-escape)
(evil-define-key 'normal vterm-mode-map "b" '(lambda () (interactive) (vterm-send "M-b")))
(evil-define-key 'normal vterm-mode-map "e" '(lambda () (interactive) (vterm-send "M-f")))
(evil-define-key 'normal vterm-mode-map "x" 'vterm-send-delete)
(evil-define-key 'normal vterm-mode-map "<backspace>" 'vterm-send-backspace)
(evil-define-key 'normal vterm-mode-map "db" '(lambda () (interactive) (vterm-send "C-w")))
(evil-define-key 'normal vterm-mode-map "dw" '(lambda () (interactive) (vterm-send "M-d")))
(evil-define-key 'normal vterm-mode-map "p" 'vterm-yank)
(evil-define-key 'normal vterm-mode-map "P" '(lambda ()
                                               (interactive)
                                               (vterm-send-C-b)
                                               (vterm-yank)))

(evil-define-key '(insert normal) vterm-mode-map (kbd "M-RET") 'vterm-send-next-key)

;; Buffer menu things
(evil-define-key 'motion Buffer-menu-mode-map (kbd "RET") 'Buffer-menu-this-window)
(evil-define-key 'motion Buffer-menu-mode-map ">" 'Buffer-menu-other-window)
(evil-define-key 'motion Buffer-menu-mode-map "q" 'quit-window)
(evil-define-key 'motion Buffer-menu-mode-map "." 'Buffer-menu-select)
(evil-define-key 'motion Buffer-menu-mode-map "m" 'Buffer-menu-mark)
(evil-define-key 'motion Buffer-menu-mode-map "u" 'Buffer-menu-unmark)



(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture) ; how do I change the capture locations?

(evil-define-key 'motion 'Info-mode-map "gn" 'Info-next)
(evil-define-key 'motion 'Info-mode-map "gp" 'Info-prev)
(evil-define-key 'motion 'Info-mode-map "gf" 'Info-follow-nearest-node)

;; would be nice if z-c would detect being at a drawer

(add-to-list 'custom-theme-load-path '"~/.emacs.d/themes/")


(defun toggle-wk-toplevel () (interactive)
				 (if (get-buffer-window " *which-key*")
				     (kill-buffer " *which-key*")
				     (which-key-show-top-level)))
(use-package which-key
  :config
  (which-key-mode)
  (which-key-setup-side-window-bottom)
    (keymap-set global-map "C-x w" 'toggle-wk-toplevel)
    (evil-define-key '(normal motion) 'global (kbd "<leader>w") 'toggle-wk-toplevel))

(use-package marginalia
  :config
  (marginalia-mode))

(use-package embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings)))

(use-package consult
  :bind
  ("C-x b" . consult-buffer)
  ("C-x C-f" . consult-find)
  :config
  (evil-define-key '(normal motion) 'global "gl" 'consult-goto-line))

(use-package magit
  :bind (:map magit-file-section-map
	      ("RET" . magit-diff-visit-file-other-window)
	      :map magit-hunk-section-map
	      ("RET" . magit-diff-visit-file-other-window)))



;; C-x (something) means
;; "Emacs is going to turn into another program, now"
;; The leader keys really make sense to me in terms of a text-editing context

(recentf-mode)
;; Leader key thing

(use-package rg)

(defun nremap (key-seq fun) (evil-define-key '(normal motion) 'global (kbd key-seq) fun))

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
  :config
  (org-roam-db-autosync-mode))
  

(nremap "gt" 'tab-bar-switch-to-next-tab)
(nremap "gT" 'tab-bar-switch-to-prev-tab)
(evil-define-key '(normal motion) 'global "gt" 'tab-bar-switch-to-next-tab)
(evil-define-key '(normal motion) 'global "gt" 'tab-bar-switch-to-next-tab)
(evil-define-key '(normal motion) 'global (kbd "<leader>fl") 'consult-goto-line)
(evil-define-key '(normal motion) 'global (kbd "<leader>ff") 'consult-find)
(evil-define-key '(normal motion) 'global (kbd "<leader>fb") 'consult-buffer)
(evil-define-key '(normal motion) 'global (kbd "<leader>fpb") 'project-list-buffers)
(evil-define-key '(normal motion) 'global (kbd "<leader>fpf") 'consult-project-buffer)
(evil-define-key '(normal motion) 'global (kbd "<leader>fpp") 'project-switch-project)

(evil-define-key '(normal motion visual) 'global (kbd "M-.")
  (lambda () (interactive) (repeat-complex-command 0) (minibuffer-complete-and-exit)))


(evil-define-key '(normal motion) 'emacs-lisp-mode (kbd "<leader>ef") 'load-file)
;(evil-define-key '(normal motion) 'emacs-lisp-mode (kbd "<leader>eb") 'eval-buffer)
(evil-define-key '(normal motion) 'lisp-data-mode (kbd "<leader>ef") 'load-file)
;(evil-define-key '(normal motion) 'lisp-data-mode (kbd "<leader>eb") 'eval-buffer)
(setf minibuffer-visible-completions nil) ; this fixes the annoying minibuffer error popup?


(evil-define-key 'normal 'global (kbd "C-h C-c") (lambda () (interactive) (message "never again")))
(evil-define-key '(normal motion) 'global (kbd "<leader> d SPC") (lambda () (interactive) (message "haha ha!")))
(evil-define-key '(normal motion) 'emacs-lisp-mode (kbd "<leader> e SPC") 'eval-defun)
(evil-define-key '(normal) 'common-lisp-mode (kbd "<leader> e SPC") 'sly-eval-defun)
;; to leader key or not to leader key?
;; basically whatever I do will end up feeling natural, so just go for it
;; My basic idiom is <leader><key><leader> does "the obvious thing"
;; my modal zap. Repetitions should zap things in obvious ways.

;; minibuffer stuff
(keymap-set minibuffer-local-must-match-map "C-j" 'minibuffer-next-completion)
(keymap-set minibuffer-local-map "C-l" 'minibuffer-complete-and-exit)
(keymap-set minibuffer-local-map "C-k" 'minibuffer-previous-completion)
(keymap-set minibuffer-local-map "C-w" 'evil-delete-backward-word)
(evil-define-key '(normal motion) 'global "," 'evil-jump-backward)
(evil-define-key '(normal motion) 'global "." 'evil-jump-forward)

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
  :commands (pomm pomm-third-time)
  :config
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
