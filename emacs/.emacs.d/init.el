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
 '(org-agenda-files '("~/diurn/get-it-done.org"))
 '(package-vc-selected-packages 'nil)
 '(safe-local-variable-values
   '((org-todo-keywords (sequence "TODO(t)" "READY(r)" "|" "DONE(d)"))
     (org-todo-keywords (sequence "TODO" "READY" "DONE"))
     (org-todo-keywords (sequence "TODO" "READY" "|" "DONE"))
     (org-refile-targets (nil :level . 1) (nil :tag . "tg"))
     (org-refile-targets quote ((:level . 1) (:tag . "tg"))))))
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
              ("t" . project-vterm)
              :map vterm-mode-map
              ("M-," . marx-jump-backward)
              ("M-." . marx-jump-forward))
  :after (project)
  :preface
  (defun project-vterm ()
    (interactive)
    (defvar vterm-buffer-name)
    (let* ((project (project-current t))
           (default-directory (project-root project))
           (vterm-buffer-name (project-prefixed-buffer-name "vterm"))
           (vterm-buffer (get-buffer vterm-buffer-name)))
      (if (and vterm-buffer (not current-prefix-arg))
          (pop-to-buffer vterm-buffer (bound-and-true-p display-comint-buffer-action))
        (if current-prefix-arg
            (vterm (generate-new-buffer-name vterm-buffer-name))
          (vterm)))))
  :init
  (add-to-list 'project-switch-commands '(project-vterm "Vterm") t)
  (add-to-list 'project-kill-buffer-conditions '(major-mode . vterm-mode))
  :config
  (setq vterm-copy-exclude-prompt t)
  (setq vterm-max-scrollback 100000)
  (setq vterm-tramp-shells '(("ssh" "/bin/bash"))))

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

(defvar consult-source-vterm
  `(:name "VTerm"
          :narrow ?v
          :category buffer
          :face consult-buffer
          :history buffer-name-history
          :state ,#'consult--buffer-state
          :action ,#'consult--buffer-action
          :items ,(lambda ()
                    (consult--buffer-query
                     :sort 'visibility
                     :mode 'vterm-mode
                     :as #'consult--buffer-pair))))




(use-package consult
  :bind
  ("C-x b" . consult-buffer)
  ("C-M-y" . consult-yank-from-kill-ring)
  ("C-c f" . consult-fd)
  ("M-RET l" . consult-find)
  ("C-c g" . rg)
  ("M-RET p" . project-switch-project)
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

(use-package zig-mode
  :straight t
  :mode "\\.zig\\'")

(use-package odin-mode
  :straight (:host github :repo "mattt-b/odin-mode")
  :mode "\\.odin\\'")

(use-package eglot
  :straight nil
  :commands (eglot eglot-ensure)
  :preface
  (defun rosin-eglot-if-program (program)
    (when (and buffer-file-name (executable-find program))
      (eglot-ensure)))
  (defun rosin-eglot-zig () (rosin-eglot-if-program "zls"))
  (defun rosin-eglot-odin () (rosin-eglot-if-program "ols"))
  :hook
  ((zig-mode . rosin-eglot-zig))
  ((odin-mode . rosin-eglot-odin))
  :config
  (add-to-list 'eglot-server-programs
               '(zig-mode . ("zls"))
               '(odin-mode . ("ols"))))


(load-file "~/.emacs.d/configuration/tko.el")
(load-file "~/.emacs.d/configuration/marx.el")
(global-set-key (kbd "M-,") #'marx-jump-backward)
(global-set-key (kbd "M-.") #'marx-jump-forward)
(global-set-key (kbd "<f9>") #'previous-buffer)
(global-set-key (kbd "<f10>") #'next-buffer)
(global-set-key (kbd "C-c k") #'rosin-tko-tickets)
(global-set-key (kbd "C-c n j") #'(lambda () (interactive) (find-file "~/diurn/journal.org")))
(global-set-key (kbd "C-c n g") #'(lambda () (interactive) (find-file "~/diurn/get-it-done.org")))
(global-unset-key (kbd "M-;"))
(global-set-key (kbd "C-c d") #'xref-find-definitions)
(global-set-key (kbd "C-c r") #'xref-find-references)
(global-set-key (kbd "C-c a") #'xref-find-apropos)

;; minibuffer stuff
(global-set-key (kbd "M-j") #'minibuffer-next-completion)
(global-set-key (kbd "M-k") #'minibuffer-previous-completion)
(global-set-key (kbd "M-l") #'minibuffer-choose-completion)
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

(unless (char-table-p standard-display-table)
  (setq standard-display-table (make-display-table)))
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

; (use-package mise
;  :config
;  (add-hook 'after-init-hook #'global-mise-mode))

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
(use-package forth-mode
  :straight t)

(use-package verb
  :straight t
  :after org
  :config
  (add-to-list 'org-babel-load-languages '(verb . t))
  (org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages)
  (define-key org-mode-map (kbd "C-c C-r") verb-command-map))

(use-package uxntal-mode
  :straight t
  :config
  (setq uxntal-uxnemu-path "uxn2")
  :bind (("C-c C-c" . uxntal-compile-and-run)
         ("C-c C-d" . uxntal-explain-word)) 
  :hook (uxntal-mode . (lambda () (electric-indent-local-mode -1))))

(global-set-key (kbd "M-p") #'backward-paragraph)
(global-set-key (kbd "M-n") #'forward-paragraph)

(defun rosin-vterm-run (name command)
    (let ((buf (vterm (generate-new-buffer-name name))))
      (with-current-buffer buf
        (vterm-send-string command)
        (vterm-send-return))
      buf))
;    (rosin-vterm-run "pla-gqzj" "docker compose exec -it agent bash
;    cd planning
;    copilot --yolo -i \"$(cat working/pla-gqzj/worker-prompt.md)\"")
;    ; copilot --yolo -i "$(cat working/pla-gqzj/worker-prompt.md)"

; (rosin-vterm-run "*test-vterm*" "echo hello, world")
(setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
(delete-selection-mode)
(winner-mode 1)
(use-package vundo
  :straight t
  :config (setq vundo-glyph-alist vundo-unicode-symbols)
  :bind (("C-x u" . vundo)))

(setq desktop-dirname "~/.emacs.d/")
(setq desktop-path '("~/.emacs.d/"))
(desktop-save-mode 1)
