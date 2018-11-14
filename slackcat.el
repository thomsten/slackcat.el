;;; slackcat.el --- Easily post messages to Slack

;; Copyright (C) 2018 Thomas Stenersen

;; Author: Thomas Stenersen <stenersen.thomas@gmail.com>
;; Version: 0.1
;; Keywords: speed, convenience
;; URL: https://github.com/thomsten/slackcat.el

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Easily post messages to Slack

;;; Code:

(require 's)
(require 'markdown-mode)
(require 'cl-lib)

(defgroup slackcat nil
  "Customizable group for slackcat"
  :group 'applications)

(defcustom slackcat-bin "slackcat"
  "Command to invoke slackcat."
  :group 'slackcat)

(defcustom slackcat-args ""
  "Default arguments to pass to slackcat."
  :group 'slackcat)

(defcustom slackcat-user-list '()
  "List of available users."
  :group 'slackcat)

(defcustom slackcat-channel-list '()
  "List of available channels."
  :group 'slackcat)

(defvar slackcat--dst-list-hist nil
  "Variable used as a history lookup for users/channels.")

(defconst slackcat--edit-buffer "*slackcat-edit*"
  "Name of buffer used to edit slackcat messages.")

(defconst slackcat--dst-regexp "\\(@\\|#\\)\\([a-zA-Z0-9._-]+\\)"
  "Regular expression to match the destination type (#channel or @user) and name.")

(defconst slackcat-file-mappings
  '(("auto" . "Auto Detect Type")
    ("text" . "Plain Text")
    ("ai" . "Illustrator File")
    ("apk" . "APK")
    ("applescript" . "AppleScript")
    ("binary" . "Binary")
    ("bmp" . "Bitmap")
    ("boxnote" . "BoxNote")
    ("c" . "C")
    ("csharp" . "C#")
    ("cpp" . "C++")
    ("css" . "CSS")
    ("csv" . "CSV")
    ("clojure" . "Clojure")
    ("coffeescript" . "CoffeeScript")
    ("cfm" . "ColdFusion")
    ("d" . "D")
    ("dart" . "Dart")
    ("diff" . "Diff")
    ("doc" . "Word Document")
    ("docx" . "Word document")
    ("dockerfile" . "Docker")
    ("dotx" . "Word template")
    ("email" . "Email")
    ("eps" . "EPS")
    ("epub" . "EPUB")
    ("erlang" . "Erlang")
    ("fla" . "Flash FLA")
    ("flv" . "Flash video")
    ("fsharp" . "F#")
    ("fortran" . "Fortran")
    ("gdoc" . "GDocs Document")
    ("gdraw" . "GDocs Drawing")
    ("gif" . "GIF")
    ("go" . "Go")
    ("gpres" . "GDocs Presentation")
    ("groovy" . "Groovy")
    ("gsheet" . "GDocs Spreadsheet")
    ("gzip" . "GZip")
    ("html" . "HTML")
    ("handlebars" . "Handlebars")
    ("haskell" . "Haskell")
    ("haxe" . "Haxe")
    ("indd" . "InDesign Document")
    ("java" . "Java")
    ("javascript" . "JavaScript/JSON")
    ("jpg" . "JPEG")
    ("keynote" . "Keynote Document")
    ("kotlin" . "Kotlin")
    ("latex" . "LaTeX/TeX")
    ("lisp" . "Lisp")
    ("lua" . "Lua")
    ("m4a" . "MPEG 4 audio")
    ("markdown" . "Markdown (raw)")
    ("matlab" . "MATLAB")
    ("mhtml" . "MHTML")
    ("mkv" . "Matroska video")
    ("mov" . "QuickTime video")
    ("mp3" . "mp4")
    ("mp4" . "MPEG 4 video")
    ("mpg" . "MPEG video")
    ("mumps" . "MUMPS")
    ("numbers" . "Numbers Document")
    ("nzb" . "NZB")
    ("objc" . "Objective-C")
    ("ocaml" . "OCaml")
    ("odg" . "OpenDocument Drawing")
    ("odi" . "OpenDocument Image")
    ("odp" . "OpenDocument Presentation")
    ("odd" . "OpenDocument Spreadsheet")
    ("odt" . "OpenDocument Text")
    ("ogg" . "Ogg Vorbis")
    ("ogv" . "Ogg video")
    ("pages" . "Pages Document")
    ("pascal" . "Pascal")
    ("pdf" . "PDF")
    ("perl" . "Perl")
    ("php" . "PHP")
    ("pig" . "Pig")
    ("png" . "PNG")
    ("post" . "Slack Post")
    ("powershell" . "PowerShell")
    ("ppt" . "PowerPoint presentation")
    ("pptx" . "PowerPoint presentation")
    ("psd" . "Photoshop Document")
    ("puppet" . "Puppet")
    ("python" . "Python")
    ("qtz" . "Quartz Composer Composition")
    ("r" . "R")
    ("rtf" . "Rich Text File")
    ("ruby" . "Ruby")
    ("rust" . "Rust")
    ("sql" . "SQL")
    ("sass" . "Sass")
    ("scala" . "Scala")
    ("scheme" . "Scheme")
    ("sketch" . "Sketch File")
    ("shell" . "Shell")
    ("smalltalk" . "Smalltalk")
    ("svg" . "SVG")
    ("swf" . "Flash SWF")
    ("swift" . "Swift")
    ("tar" . "Tarball")
    ("tiff" . "TIFF")
    ("tsv" . "TSV")
    ("vb" . "VB.NET")
    ("vbscript" . "VBScript")
    ("vcard" . "vCard")
    ("velocity" . "Velocity")
    ("verilog" . "Verilog")
    ("wav" . "Waveform audio")
    ("webm" . "WebM")
    ("wmv" . "Windows Media Video")
    ("xls" . "Excel spreadsheet")
    ("xlsx" . "Excel spreadsheet")
    ("xlsb" . "Excel Spreadsheet (Binary, Macro Enabled)")
    ("xlsm" . "Excel Spreadsheet (Macro Enabled)")
    ("xltx" . "Excel template")
    ("xml" . "XML")
    ("yaml" . "YAML")
    ("zip" . "Zip"))
  "All file types known to Slack. Available at https://api.slack.com/types/file.")

(defvar slackcat--temp-window-cfg nil
  "Temporary window configuration variable.")

(defun slackcat--major-mode-p (mode)
  "Return 't if the string MODE is equal to the current major mode."
  (string-equal major-mode mode))

(defun slackcat--get-filetype ()
  "Return the 'file type' argument given the current major mode.
File types are found at https://api.slack.com/types/file."
  (cond
   ((slackcat--major-mode-p "c-mode")
    "c")
   ((slackcat--major-mode-p "magit-diff-mode")
    "diff")
   ((slackcat--major-mode-p "python-mode")
    "python")
   (t "auto")))

(defun slackcat--remove-duplicates (lst)
  "Remove duplicates from LST."
  (if (> (length lst) 1)
      (cl-remove-duplicates lst :test 'string= :from-end t)
    lst))

(defun slackcat--escape-chars (s)
  "TODO: Search to string S and escape characters."
  s)

(defun slackcat--dst-to-arg (dst)
  "Return command line argument from DST."
  (let ((matches (s-match slackcat--dst-regexp dst)))
    (when (and matches (= 3 (length matches)))
      (cond
       ((string-equal "#" (nth 1 matches))
        (concat "-c " (nth 2 matches)))
       ((string-equal "@" (nth 1 matches))
        (concat "-u " (nth 2 matches)))))))

(defun slackcat--pop-dst ()
  "Get the destination channel/user from the current buffer."
  (save-excursion
    (goto-char (point-min))
    (let* ((dst-line (buffer-substring-no-properties (point-min) (point-at-eol)))
           (slackcat--dst-to-arg dst-line)))))

(defun slackcat--kill-and-restore ()
  "Kill the slackcat buffer and restore window configuration."
  (when slackcat--temp-window-cfg
    (set-window-configuration slackcat--temp-window-cfg))

  (when (get-buffer slackcat--edit-buffer)
    (kill-buffer (get-buffer slackcat--edit-buffer))))

(defun slackcat--send-buffer ()
  "Sends the content of the current buffer to Slack."
  (interactive)
  (let ((temp-buffer (current-buffer))
        (dst-arg (slackcat--pop-dst)))
    (if dst-arg
        (progn
          (goto-char (point-min))
          (kill-line)
          (shell-command-on-region (point-min) (point-max) (format "%s %s -p" slackcat-bin dst-arg))))
    (slackcat--kill-and-restore)))

(defun slackcat-file (&optional b e)
  "Upload contents of region (B E) to slack chat."
  (interactive "r")
  (let* ((slackcat-args-tmp (concat "-t " (slackcat--get-filetype) " "))
         (dst-list (append (mapcar (lambda (name) (concat "@" name)) slackcat-user-list)
                           (mapcar (lambda (chan) (concat "#" chan)) slackcat-channel-list)))
         (dst (completing-read "User/channel: " 'dst-list 'nil 'nil 'nil 'slackcat--dst-list-hist)))

    (setq slackcat--dst-list-hist
          (slackcat--remove-duplicates slackcat--dst-list-hist))

    (shell-command-on-region
     b e
     (read-from-minibuffer "Slackcat command: "
      (format "%s -t %s %s"
              slackcat-bin
              (slackcat--get-filetype)
              (slackcat--dst-to-arg dst))))))

(defun slackcat--abort ()
  "Kill the slack buffer and abort the message."
  (interactive)
  (message "Slackcat aborted")
  (slackcat--kill-and-restore))

(defun slackcat (&optional b e)
  "Sends a message to a slack user/channel.
Optionally, it will insert the marked region (B E) as verbatim."
  (interactive "r")
  (let* ((msg "")
         (dst-list (append (mapcar (lambda (name) (concat "@" name)) slackcat-user-list)
                           (mapcar (lambda (chan) (concat "#" chan)) slackcat-channel-list)))
         (dst (completing-read "User/channel: " 'dst-list 'nil 'nil 'nil 'slackcat--dst-list-hist)))

    (setq slackcat--dst-list-hist
          (cl-remove-duplicates (list 'slackcat--dst-list-hist) :test 'string= :from-end t))

    (if (region-active-p)
        (setq msg (format "```\n%s\n```\n" (slackcat--escape-chars (buffer-substring b e)))))

    (setq slackcat--temp-window-cfg (current-window-configuration))
    (with-current-buffer (get-buffer-create slackcat--edit-buffer)
      (erase-buffer)
      (insert (format "<!-- TO: %s -->\n" dst))
      (insert msg)
      (pop-to-buffer (current-buffer))
      (local-set-key (kbd "C-c C-c") 'slackcat--send-buffer)
      (local-set-key (kbd "C-c C-k") 'slackcat--abort))))

(provide 'slackcat)

;;; slackcat.el ends here
