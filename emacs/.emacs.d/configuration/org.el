(org-babel-do-load-languages
 'org-babel-load-languages
 '((calc . t)
   (lisp . t)
   (shell . t)
   (lua . t)
   (forth . t)))

(setq org-babel-lisp-eval-fn #'sly-eval)
; https://orgmode.org/manual/Results-of-Evaluation.html
(setq org-babel-default-header-args '((:results . "output drawer replace")))

