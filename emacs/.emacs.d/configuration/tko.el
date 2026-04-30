;;; tko.el --- small ticket browser -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'project)
(require 'subr-x)
(require 'xref)

(cl-defstruct rosin-tko-ticket id status parent title file)

(defvar-local rosin-tko--root nil)
(defvar-local rosin-tko--active-only t)

(defvar rosin-tko-active-statuses '("open" "in_progress"))

(defvar rosin-tko-status-cycle '("open" "in_progress" "closed"))

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
    (define-key map (kbd "r") #'rosin-tko-rotate-status)
    (define-key map (kbd "n") #'rosin-tko-add-note)
    (define-key map (kbd "c") #'rosin-tko-create-ticket)
    map))

(defvar rosin-tko-ticket-prefix-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "k") #'rosin-tko-tickets)
    (define-key map (kbd "r") #'rosin-tko-rotate-status)
    (define-key map (kbd "n") #'rosin-tko-add-note)
    (define-key map (kbd "c") #'rosin-tko-create-ticket)
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

(defun rosin-tko--set-field (key value)
  (goto-char (point-min))
  (cond
   ((re-search-forward
     (format "^:%s:[ \t]*\\(.*\\)$" (regexp-quote key))
     nil t)
    (replace-match value t t nil 1))
   ((progn
      (goto-char (point-min))
      (re-search-forward "^:PROPERTIES:$" nil t))
    (unless (re-search-forward "^:END:$" nil t)
      (user-error "Malformed ticket property drawer"))
    (beginning-of-line)
    (insert (format ":%s: %s\n" key value)))
   (t
    (goto-char (point-min))
    (insert (format ":PROPERTIES:\n:%s: %s\n:END:\n\n" key value)))))

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

(defun rosin-tko--next-status (status)
  (let* ((cycle rosin-tko-status-cycle)
         (index (cl-position status cycle :test #'string=)))
    (nth (mod (1+ (or index -1)) (length cycle)) cycle)))

(defun rosin-tko--ticket-file-p (file)
  (and file
       (string= (file-name-extension file) "org")
       (string= (file-name-nondirectory
                 (directory-file-name (file-name-directory file)))
                ".tickets")))

(defun rosin-tko--ticket-file-at-point ()
  (or (get-text-property (line-beginning-position) 'rosin-tko-file)
      (when (rosin-tko--ticket-file-p buffer-file-name)
        buffer-file-name)))

(defun rosin-tko--current-status ()
  (or (save-excursion (rosin-tko--field "TK_STATUS")) "open"))

(defun rosin-tko--rotate-status-in-buffer ()
  (let* ((old-status (rosin-tko--current-status))
         (new-status (rosin-tko--next-status old-status)))
    (rosin-tko--set-field "TK_STATUS" new-status)
    (cons old-status new-status)))

(defun rosin-tko--rotate-status-in-file (file)
  (if-let ((buffer (find-buffer-visiting file)))
      (with-current-buffer buffer
        (when (buffer-modified-p)
          (user-error "Ticket buffer has unsaved changes: %s" file))
        (let ((statuses (rosin-tko--rotate-status-in-buffer)))
          (save-buffer)
          statuses))
    (with-temp-buffer
      (insert-file-contents file)
      (let ((statuses (rosin-tko--rotate-status-in-buffer)))
        (write-region (point-min) (point-max) file nil 'silent)
        statuses))))

(defun rosin-tko-rotate-status ()
  (interactive)
  (let ((file (rosin-tko--ticket-file-at-point)))
    (unless file
      (user-error "No tko ticket here"))
    (if (derived-mode-p 'rosin-tko-tickets-mode)
        (pcase-let ((`(,old-status . ,new-status)
                     (rosin-tko--rotate-status-in-file file)))
          (message "%s: %s -> %s"
                   (file-name-base file) old-status new-status)
          (rosin-tko-refresh))
      (pcase-let ((`(,old-status . ,new-status)
                   (rosin-tko--rotate-status-in-buffer)))
        (message "%s: %s -> %s"
                 (file-name-base file) old-status new-status)))))

(defun rosin-tko--insert-note (title)
  (require 'org)
  (goto-char (point-max))
  (unless (bolp)
    (insert "\n"))
  (unless (or (bobp)
              (save-excursion
                (forward-line -1)
                (looking-at-p "^$")))
    (insert "\n"))
  (let ((start (point)))
    (insert "*** ")
    (org-insert-time-stamp (current-time) t t)
    (insert (format " %s\n" title))
    (goto-char start)))

(defun rosin-tko-add-note (title)
  (interactive "sNote title: ")
  (when (string-empty-p (string-trim title))
    (user-error "Note title is required"))
  (let ((file (rosin-tko--ticket-file-at-point)))
    (unless file
      (user-error "No tko ticket here"))
    (unless (derived-mode-p 'rosin-tko-tickets-mode)
      (unless (equal (file-truename file)
                     (file-truename (or buffer-file-name "")))
        (user-error "Current buffer is not visiting %s" file)))
    (when (derived-mode-p 'rosin-tko-tickets-mode)
      (find-file file))
    (rosin-tko--insert-note title)
    (message "Added note to %s" (file-name-base file))))

(defun rosin-tko--root-for-command ()
  (or (and (derived-mode-p 'rosin-tko-tickets-mode)
           rosin-tko--root)
      (rosin-tko--project-root)))

(defun rosin-tko--project-prefix (root)
  (let* ((name (file-name-nondirectory (directory-file-name root)))
         (words (split-string name "[-_ ]+" t))
         (prefix (mapconcat (lambda (word) (substring word 0 1)) words "")))
    (if (< (length prefix) 2)
        (substring name 0 (min 3 (length name)))
      prefix)))

(defun rosin-tko--random-id-suffix ()
  (let ((chars "abcdefghijklmnopqrstuvwxyz0123456789")
        (suffix ""))
    (dotimes (_ 4 suffix)
      (setq suffix
            (concat suffix
                    (string (aref chars (random (length chars)))))))))

(defun rosin-tko--generate-id (root)
  (let* ((prefix (rosin-tko--project-prefix root))
         (tickets-dir (rosin-tko--tickets-dir root))
         id file)
    (unless tickets-dir
      (user-error "No .tickets directory found"))
    (while (progn
             (setq id (format "%s-%s" prefix (rosin-tko--random-id-suffix)))
             (setq file (expand-file-name (format "%s.org" id) tickets-dir))
             (file-exists-p file)))
    (cons id file)))

(defun rosin-tko--iso-now ()
  (format-time-string "%Y-%m-%dT%H:%M:%SZ" (current-time) t))

(defun rosin-tko--ticket-template (id title)
  (format ":PROPERTIES:
:TK_ID: %s
:TK_STATUS: open
:TK_DEPS: []
:TK_LINKS: []
:TK_CREATED: %s
:TK_TYPE: task
:TK_PRIORITY: 2
:END:

* %s
" id (rosin-tko--iso-now) title))

(defun rosin-tko--write-new-ticket (root title)
  (pcase-let ((`(,id . ,file) (rosin-tko--generate-id root)))
    (write-region (rosin-tko--ticket-template id title) nil file nil 'silent)
    (cons id file)))

(defun rosin-tko-create-ticket (title)
  (interactive "sTicket title: ")
  (let ((title (string-trim title)))
    (when (string-empty-p title)
      (user-error "Ticket title is required"))
    (let* ((viewer-buffer (when (derived-mode-p 'rosin-tko-tickets-mode)
                            (current-buffer)))
           (root (rosin-tko--root-for-command)))
      (unless (rosin-tko--tickets-dir root)
        (user-error "No .tickets directory found"))
      (pcase-let ((`(,id . ,file) (rosin-tko--write-new-ticket root title)))
        (when (buffer-live-p viewer-buffer)
          (with-current-buffer viewer-buffer
            (rosin-tko-refresh)))
        (find-file file)
        (message "Created ticket %s" id)))))

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

(defun rosin-tko--ticket-id-bounds-at-point ()
  (save-excursion
    (skip-chars-backward "[:alnum:]_-")
    (let ((start (point)))
      (skip-chars-forward "[:alnum:]_-")
      (let ((end (point)))
        (when (< start end)
          (let ((text (buffer-substring-no-properties start end)))
            (when (string-match-p
                   "\\`[[:alnum:]][[:alnum:]_-]*-[[:alnum:]][[:alnum:]_-]*\\'"
                   text)
              (cons start end))))))))

(defun rosin-tko--ticket-id-at-point ()
  (when-let ((bounds (rosin-tko--ticket-id-bounds-at-point)))
    (buffer-substring-no-properties (car bounds) (cdr bounds))))

(defun rosin-tko--ticket-file-for-id (id &optional root)
  (when-let ((root (or root (rosin-tko--project-root))))
    (let ((exact (expand-file-name (format ".tickets/%s.org" id) root)))
      (or (when (file-regular-p exact)
            exact)
          (cl-find-if
           (lambda (file)
             (with-temp-buffer
               (insert-file-contents file)
               (string= id (or (rosin-tko--field "TK_ID")
                               (file-name-base file)))))
           (rosin-tko--ticket-files root))))))

(defun rosin-tko--xref-root ()
  (when (derived-mode-p 'org-mode)
    (when-let ((root (rosin-tko--project-root)))
      (when (rosin-tko--tickets-dir root)
        root))))

(defun rosin-tko-xref-backend ()
  (when (and (rosin-tko--xref-root)
             (rosin-tko--ticket-id-at-point))
    'rosin-tko))

(cl-defmethod xref-backend-identifier-at-point ((_backend (eql rosin-tko)))
  (rosin-tko--ticket-id-at-point))

(cl-defmethod xref-backend-definitions ((_backend (eql rosin-tko)) identifier)
  (when-let ((file (rosin-tko--ticket-file-for-id identifier)))
    (list (xref-make identifier (xref-make-file-location file 1 0)))))

(defun rosin-tko--xref-reference-regexp (identifier)
  (format "\\(?:\\`\\|[^[:alnum:]_-]\\)\\(%s\\)\\(?:\\'\\|[^[:alnum:]_-]\\)"
          (regexp-quote identifier)))

(defun rosin-tko--xref-references-in-file (identifier file)
  (let ((regexp (rosin-tko--xref-reference-regexp identifier))
        references)
    (with-temp-buffer
      (insert-file-contents file)
      (goto-char (point-min))
      (while (re-search-forward regexp nil t)
        (let* ((pos (match-beginning 1))
               (line-text (string-trim
                           (buffer-substring-no-properties
                            (line-beginning-position)
                            (line-end-position))))
               (line (line-number-at-pos pos))
               (column (save-excursion
                         (goto-char pos)
                         (current-column))))
          (push (xref-make line-text
                           (xref-make-file-location file line column))
                references))))
    (nreverse references)))

(cl-defmethod xref-backend-references ((_backend (eql rosin-tko)) identifier)
  (when-let ((root (rosin-tko--xref-root)))
    (apply #'append
           (mapcar (lambda (file)
                     (rosin-tko--xref-references-in-file identifier file))
                   (rosin-tko--ticket-files root)))))

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

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c k") rosin-tko-ticket-prefix-map)
  (add-hook 'org-mode-hook
            (lambda ()
              (add-hook 'xref-backend-functions
                        #'rosin-tko-xref-backend nil t))))

(provide 'tko)
