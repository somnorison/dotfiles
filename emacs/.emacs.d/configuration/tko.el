;;; tko.el --- small ticket browser -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'project)
(require 'subr-x)

(cl-defstruct rosin-tko-ticket id status parent title file)

(defvar-local rosin-tko--root nil)
(defvar-local rosin-tko--active-only t)

(defvar rosin-tko-active-statuses '("open" "in_progress"))

(defface rosin-tko-in-progress-face
  '((t :inherit font-lock-keyword-face))
  "Face for in-progress tko tickets.")

(defface rosin-tko-closed-face
  '((t :inherit shadow))
  "Face for closed tko tickets.")

(defface rosin-tko-parent-face
  '((t :inherit success))
  "Face for parent ticket IDs.")

(defvar rosin-tko-tickets-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET") #'rosin-tko-visit-ticket)
    (define-key map (kbd "g") #'rosin-tko-refresh)
    (define-key map (kbd "a") #'rosin-tko-toggle-active)
    map))

(define-derived-mode rosin-tko-tickets-mode special-mode "TKO"
  "Mode for browsing tko tickets.")

(defun rosin-tko--project-root (&optional directory)
  (let ((default-directory (or directory default-directory)))
    (let ((project-root (when-let ((project (project-current nil)))
                          (project-root project))))
      (if (and project-root
               (file-directory-p (expand-file-name ".tickets" project-root)))
          project-root
        (locate-dominating-file default-directory ".tickets")))))

(defun rosin-tko--tickets-dir (root)
  (when root
    (let ((tickets-dir (expand-file-name ".tickets" root)))
      (when (file-directory-p tickets-dir)
        tickets-dir))))

(defun rosin-tko--ticket-files (root)
  (when-let ((tickets-dir (rosin-tko--tickets-dir root)))
    (sort (cl-remove-if-not
           #'file-regular-p
           (directory-files tickets-dir t "\\.org\\'"))
          (lambda (a b)
            (time-less-p (file-attribute-modification-time (file-attributes b))
                         (file-attribute-modification-time (file-attributes a)))))))

(defun rosin-tko--field (key)
  (goto-char (point-min))
  (when (re-search-forward
         (format "^:%s:[ \t]*\\(.*\\)$" (regexp-quote key))
         nil t)
    (string-trim (match-string 1))))

(defun rosin-tko--title ()
  (goto-char (point-min))
  (when (re-search-forward "^\\*+[ \t]+\\(.+\\)$" nil t)
    (string-trim (match-string 1))))

(defun rosin-tko--read-ticket (file)
  (with-temp-buffer
    (insert-file-contents file)
    (make-rosin-tko-ticket
     :id (or (rosin-tko--field "TK_ID")
             (file-name-base file))
     :status (or (rosin-tko--field "TK_STATUS") "open")
     :parent (rosin-tko--field "TK_PARENT")
     :title (or (rosin-tko--title) "Untitled")
     :file file)))

(defun rosin-tko--tickets (root active-only)
  (let ((tickets (mapcar #'rosin-tko--read-ticket
                         (rosin-tko--ticket-files root))))
    (if active-only
        (cl-remove-if-not
         (lambda (ticket)
           (member (rosin-tko-ticket-status ticket) rosin-tko-active-statuses))
         tickets)
      tickets)))

(defun rosin-tko--line (ticket)
  (let ((face (rosin-tko--status-face (rosin-tko-ticket-status ticket))))
    (concat
     (rosin-tko--propertize-status-segment
      (format "%s %s :: "
              (rosin-tko--status-marker (rosin-tko-ticket-status ticket))
              (rosin-tko-ticket-id ticket))
      face)
     (rosin-tko--title-with-parent ticket face))))

(defun rosin-tko--propertize-status-segment (text face)
  (if face
      (propertize text 'face face)
    text))

(defun rosin-tko--title-with-parent (ticket &optional face)
  (if-let ((parent (rosin-tko-ticket-parent ticket)))
      (concat
       (propertize (format "[%s]" parent) 'face 'rosin-tko-parent-face)
       (rosin-tko--propertize-status-segment
        (format " %s" (rosin-tko-ticket-title ticket))
        face))
    (rosin-tko--propertize-status-segment (rosin-tko-ticket-title ticket) face)))

(defun rosin-tko--status-marker (status)
  (pcase status
    ("open" "[ ]")
    ("in_progress" "[/]")
    ("closed" "[X]")
    (_ "[?]")))

(defun rosin-tko--status-face (status)
  (pcase status
    ("in_progress" 'rosin-tko-in-progress-face)
    ("closed" 'rosin-tko-closed-face)
    (_ nil)))

(defun rosin-tko--insert-ticket (ticket)
  (let ((start (point)))
    (insert (rosin-tko--line ticket) "\n")
    (add-text-properties
     start (point)
     `(rosin-tko-file ,(rosin-tko-ticket-file ticket)
                      mouse-face highlight
                      help-echo ,(rosin-tko-ticket-file ticket)))))

(defun rosin-tko--render (root active-only)
  (let ((inhibit-read-only t)
        (tickets (rosin-tko--tickets root active-only)))
    (erase-buffer)
    (setq rosin-tko--root root)
    (setq rosin-tko--active-only active-only)
    (if tickets
        (mapc #'rosin-tko--insert-ticket tickets)
      (insert (format "No %stko tickets in %s\n"
                      (if active-only "active " "")
                      (expand-file-name ".tickets" root))))
    (goto-char (point-min))))

(defun rosin-tko-refresh ()
  (interactive)
  (unless rosin-tko--root
    (user-error "No tko ticket root recorded for this buffer"))
  (rosin-tko--render rosin-tko--root rosin-tko--active-only))

(defun rosin-tko-toggle-active ()
  (interactive)
  (unless rosin-tko--root
    (user-error "No tko ticket root recorded for this buffer"))
  (rosin-tko--render rosin-tko--root (not rosin-tko--active-only)))

(defun rosin-tko-visit-ticket ()
  (interactive)
  (let ((file (get-text-property (line-beginning-position) 'rosin-tko-file)))
    (unless file
      (user-error "No ticket on this line"))
    (find-file file)))

(defun rosin-tko-tickets (&optional all)
  "Show tko tickets for the current project.
With prefix argument ALL, include closed tickets."
  (interactive "P")
  (let* ((root (rosin-tko--project-root))
         (active-only (not all)))
    (unless (rosin-tko--tickets-dir root)
      (user-error "No .tickets directory found"))
    (let ((buffer (get-buffer-create
                   (format "*tko tickets: %s*"
                           (file-name-nondirectory
                            (directory-file-name root))))))
      (with-current-buffer buffer
        (rosin-tko-tickets-mode)
        (rosin-tko--render root active-only))
      (pop-to-buffer buffer))))

(with-eval-after-load 'project
  (add-to-list 'project-switch-commands '(rosin-tko-tickets "Tickets" ?k) t))

(provide 'tko)
